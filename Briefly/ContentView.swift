//
//  ContentView.swift
//  Briefly
//
//  Created by Anestis Archontopoulos on 19/7/25.
//

import SwiftUI
import CoreHaptics
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Tab Type Enum
enum TabType {
    case home
    case leftTab
    case centerChat  // Main center sparkle tab
    case rightTab1
    case calendar
}

// MARK: - Main App Structure
struct ContentView: View {
    @State private var selectedTab: TabType = .home
    @State private var previousTab: TabType = .home
    @State private var isKeyboardActive: Bool = false
    @State private var showSidebar: Bool = false
    
    // Animation state for logo positioning and AI icon visibility
    @State private var logoOffset: CGFloat = 0
    @State private var aiIconOpacity: Double = 0.0
    @State private var sparkleAnim: Bool = false
    @State private var reverseSparkleAnim: Bool = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ZStack {
                    Color.customBackground
                        .ignoresSafeArea(.all)

                    Group {
                        switch selectedTab {
                        case .home:
                            HomeView(
                                logoOffset: $logoOffset,
                                aiIconOpacity: $aiIconOpacity,
                                reverseSparkleAnim: $reverseSparkleAnim,
                                showSidebar: $showSidebar
                            )
                            .transition(.identity)
                        case .centerChat:
                            ChatView(isKeyboardActive: $isKeyboardActive, logoOffset: $logoOffset, aiIconOpacity: $aiIconOpacity, sparkleAnim: $sparkleAnim)
                                .transition(.identity)
                        case .leftTab, .rightTab1, .calendar:
                            ComingSoonView(logoOffset: $logoOffset, aiIconOpacity: $aiIconOpacity)
                                .transition(.identity)
                        }
                    }
                }

                if !isKeyboardActive {
                    CustomTabBarView(selectedTab: $selectedTab)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.35), value: isKeyboardActive)
            
            // Sidebar Overlay
            if showSidebar {
                SidebarView(isPresented: $showSidebar)
                    .zIndex(1000)
                    .transition(.identity)
            }
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            print("Tab changed from \(oldValue) to \(newValue)")
            previousTab = oldValue

            // Handle logo animations based on tab transitions
            handleLogoAnimation(from: oldValue, to: newValue)
        }
        .preferredColorScheme(.light)
    }
    
    // MARK: - Animation Coordination
    private func handleLogoAnimation(from oldTab: TabType, to newTab: TabType) {
        // Update animation states immediately to prevent flicker
        switch (oldTab, newTab) {
            case (_, .centerChat):
                // Transitioning TO chat - animate logo left, show AI icon, and trigger sparkle
                withAnimation(.timingCurve(0.25, 0.1, 0.25, 1.0, duration: 0.8)) {
                    logoOffset = -15
                    aiIconOpacity = 1.0
                }
                // Trigger sparkle animation immediately
                sparkleAnim = true
            case (.centerChat, _):
                // Transitioning FROM chat - animate logo back to center, hide AI icon, and trigger reverse sparkle
                withAnimation(.timingCurve(0.25, 0.1, 0.25, 1.0, duration: 0.8)) {
                    logoOffset = 0
                    aiIconOpacity = 0.0
                }
                // Reset forward sparkle and trigger reverse sparkle animation
                sparkleAnim = false
                reverseSparkleAnim = true
                
                // Auto-reset reverse sparkle after animation completes (match ReverseSparkleHeaderAnimation duration)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    reverseSparkleAnim = false
                }
        default:
            // For all other transitions, ensure logo is centered and AI icon is hidden
            logoOffset = 0
            aiIconOpacity = 0.0
            sparkleAnim = false
            reverseSparkleAnim = false
        }
    }
}

// MARK: - Custom Font Extension
// Satoshi font family support for consistent typography
extension Font {
    static func satoshiRegular(size: CGFloat) -> Font {
        .custom("Satoshi-Regular", size: size)
    }
    
    static func satoshiMedium(size: CGFloat) -> Font {
        .custom("Satoshi-Medium", size: size)
    }
    
    static func satoshiBold(size: CGFloat) -> Font {
        .custom("Satoshi-Bold", size: size)
    }
}

// MARK: - Custom Color Extension
// Custom colors for the app
extension Color {
    static let customBackground = Color(hex: "#D5D5CD")
    static let navbarBackground = Color(hex: "#E3E4E0")
    
    // Chat-specific colors
    static let chatBlue = Color(hex: "#BDB7AB")  // User chat bubble color
    static let chatGray = Color(hex: "#8E8E93")
    static let chatBackground = Color(hex: "#D5D5CD")
    static let assistantBubble = Color(hex: "#E3E4E0")  // AI chat bubble - same as navbar
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Shared Header Component
// Consistent header used across all views with logo positioning
struct SharedHeaderView: View {
    @Binding var logoOffset: CGFloat
    @Binding var aiIconOpacity: Double

    init(logoOffset: Binding<CGFloat> = .constant(0), aiIconOpacity: Binding<Double> = .constant(0)) {
        self._logoOffset = logoOffset
        self._aiIconOpacity = aiIconOpacity
    }

    var body: some View {
        ZStack {
            // Main header row
            HStack {
                Spacer()
                ZStack {
                    // Logo
                    Image("Briefly")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 30)
                        .offset(x: logoOffset)

            // Removed extra sparkle icon
                }
                Spacer()
            }

        }
        .padding(.horizontal, 25)
        .padding(.vertical, 10)
        .background(Color.customBackground)
    }

}

// MARK: - Reverse Sparkle Header Animation
struct ReverseSparkleHeaderAnimation: View {
    @Binding var animate: Bool
    @State private var opacity: Double = 0.0
    @State private var positionProgress: CGFloat = 0.0
    @State private var isAnimating: Bool = false

    var body: some View {
        GeometryReader { geo in
            let iconSize: CGFloat = 24
            let yPos = geo.size.height / 2 // Center vertically in header
            
            // Start position: where forward animation ends (center + 55px right)
            let xStart = geo.size.width / 2 + 55
            // End position: center of the screen for proper alignment with logo
            let xEnd = geo.size.width / 2
            
            // Calculate current position using bezier interpolation
            let currentX = bezierInterpolation(
                progress: positionProgress,
                start: xStart,
                end: xEnd
            )

            Image("sparkle-fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: iconSize, height: iconSize)
                .opacity(opacity)
                .position(x: currentX, y: yPos)
        }
        .frame(height: 30)
        .drawingGroup() // GPU optimization for smoother animation
        .onChange(of: animate) { oldValue, newValue in
            print("ReverseSparkleHeaderAnimation: animate changed from \(oldValue) to \(newValue)")
            if newValue && !oldValue {
                // Starting reverse animation (Chat → Home)
                print("Starting reverse sparkle animation")
                startReverseAnimation()
            } else if !newValue && oldValue {
                // Animation finished, reset state
                print("Reverse sparkle animation finished")
                resetAnimation()
            }
        }
    }
    
    private func startReverseAnimation() {
        isAnimating = true
        opacity = 1.0 // Start fully visible
        positionProgress = 0.0 // Start from forward animation's end position
        print("Reverse animation starting: isAnimating=\(isAnimating), opacity=\(opacity)")
        
        // Animate both position and opacity with smooth bezier timing
        withAnimation(.timingCurve(0.25, 0.1, 0.25, 1.0, duration: 0.6)) {
            positionProgress = 1.0 // Move to end position (left)
        }
        
        // Fade out WAAAAY sooner - finish fading at 0.15s
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // Start at 0.1s
            withAnimation(.easeOut(duration: 0.05)) { // Ultra-quick fade in just 0.05s
                opacity = 0.0
            }
        }
        
        // Reset the animation state after completion
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            resetAnimation()
        }
    }
    
    private func resetAnimation() {
        isAnimating = false
        opacity = 0.0
        positionProgress = 0.0
        print("Reverse animation reset: isAnimating=\(isAnimating), opacity=\(opacity)")
    }
    
    // Bezier interpolation for smooth movement (matching forward animation style)
    private func bezierInterpolation(progress: CGFloat, start: CGFloat, end: CGFloat) -> CGFloat {
        // Use cubic bezier curve for natural movement
        let t = progress
        let cubicProgress = t * t * (3.0 - 2.0 * t) // Smooth step function
        return start + (end - start) * cubicProgress
    }
}

// MARK: - Home/Dashboard Screen
// Clean landing page inspired by Notion's dashboard with Vectal.ai simplicity
struct HomeView: View {
    @Binding var logoOffset: CGFloat
    @Binding var aiIconOpacity: Double
    @Binding var reverseSparkleAnim: Bool
    @Binding var showSidebar: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Header with logo and sidebar icon - custom for home view
            ZStack {
                // Base header with logo
                ZStack {
                    // Main header row
                    HStack {
                        Spacer()
                        ZStack {
                            // Logo
                            Image("Briefly")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 30)
                                .offset(x: logoOffset)
                        }
                        Spacer()
                    }

                    // Left sidebar icon
                    HStack {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showSidebar.toggle()
                            }
                        }) {
                            Image("sidebar")
                                .resizable()
                                .frame(width: 28, height: 28)
                                .foregroundColor(.primary)
                        }
                        .padding(.leading, 8)
                        Spacer()
                    }
                }
                .padding(.horizontal, 25)
                .padding(.vertical, 10)
                .background(Color.customBackground)
                .transition(.identity)

                // Reverse Sparkle Animation: appears from right, moves left and fades out
                ReverseSparkleHeaderAnimation(animate: $reverseSparkleAnim)
            }

            // Empty content area
            Spacer()
        }
        .background(Color.customBackground)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 20, coordinateSpace: .global)
                .onEnded { value in
                    // Only trigger if drag starts near left edge and moves right
                    if value.startLocation.x < 30 && value.translation.width > 60 && !showSidebar {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showSidebar = true
                        }
                    }
                }
        )
    }
}

// MARK: - Coming Soon Screen
struct ComingSoonView: View {
    @Binding var logoOffset: CGFloat
    @Binding var aiIconOpacity: Double
    
    @State private var textOpacity: Double = 0.0
    var body: some View {
        VStack(spacing: 0) {
            // Header with logo - using shared component
            SharedHeaderView(logoOffset: $logoOffset, aiIconOpacity: $aiIconOpacity)

            // Coming soon content
            VStack(spacing: 24) {
                Spacer()

                Image("ComingSoon_construction")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)

                Text("In development")
                    .font(.satoshiBold(size: 24))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .opacity(textOpacity)
                    .onAppear {
                        withAnimation(.timingCurve(0.4, 0.0, 0.2, 1.0, duration: 1.2)) {
                            textOpacity = 1.0
                        }
                    }

                Spacer()
            }
        }
        .background(Color.customBackground)
    }
}

// MARK: - Custom Tab Bar
struct CustomTabBarView: View {
    @Binding var selectedTab: TabType
    @State private var tappedTab: TabType?
    
    // Haptic feedback generators
    #if canImport(UIKit)
    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    #endif
    
    var body: some View {
        let tabs: [TabType] = [.home, .leftTab, .centerChat, .rightTab1, .calendar]
        HStack(spacing: 0) {
            let indices = Array(tabs.indices)
            ForEach(indices, id: \ .self) { idx in
                let tab = tabs[idx]
                let icon: String = {
                    switch tab {
                    case .home: return selectedTab == .home ? "home-fill" : "home"
                    case .leftTab: return selectedTab == .leftTab ? "barricade-fill" : "barricade"
                    case .centerChat: return selectedTab == .centerChat ? "brain-fill" : "brain"
                    case .rightTab1: return selectedTab == .rightTab1 ? "barricade-fill" : "barricade"
                    case .calendar: return selectedTab == .calendar ? "calendar-dots-fill" : "calendar-dots"
                    }
                }()
                #if canImport(UIKit)
                let haptic: UIImpactFeedbackGenerator.FeedbackStyle = (tab == .centerChat) ? .medium : .light
                #else
                let haptic: Int = (tab == .centerChat) ? 1 : 0
                #endif
                TabButton(
                    tab: tab,
                    selectedTab: $selectedTab,
                    tappedTab: $tappedTab,
                    icon: icon,
                    label: "",
                    isSystemIcon: false,
                    isCenter: false,
                    hapticStyle: haptic
                )
                if idx < tabs.count - 1 {
                    Spacer()
                }
            }
        }
        .offset(y: -3.5)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 40)
        .padding(.vertical, 15)
        .padding(.bottom, -30)
        .background(Color.navbarBackground)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.gray.opacity(0.1)),
            alignment: .top
        )
        .frame(height: 60)
    }
}

// MARK: - Tab Button Component
struct TabButton: View {
    let tab: TabType
    @Binding var selectedTab: TabType
    @Binding var tappedTab: TabType?
    let icon: String
    let label: String
    let isSystemIcon: Bool
    let isCenter: Bool
    #if canImport(UIKit)
    let hapticStyle: UIImpactFeedbackGenerator.FeedbackStyle
    
    private var impact: UIImpactFeedbackGenerator {
        UIImpactFeedbackGenerator(style: hapticStyle)
    }
    #else
    let hapticStyle: Int // Placeholder for non-iOS platforms
    #endif
    
    @State private var underlineAppear: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            // Center icon in a fixed-size frame for all tabs
            Button(action: {
                selectedTab = tab
                tappedTab = tab
                #if canImport(UIKit)
                impact.impactOccurred()
                #endif
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.linear(duration: 0.1)) {
                        tappedTab = nil
                    }
                }
            }) {
                ZStack {
                    if isSystemIcon {
                        Image(systemName: icon)
                            .font(.system(size: isCenter ? 28 : 24))
                            .foregroundColor(colorForTab())
                            .opacity(tappedTab == tab ? 0.5 : 1.0)
                    } else if isBrainIcon() {
                        Circle()
                            .fill(Color.black)
                            .frame(width: 44, height: 44)
                        Image(icon)
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 32, height: 32)
                            .foregroundColor(.white)
                    } else {
                        Image(icon)
                            .resizable()
                            .frame(width: tab == .centerChat ? 32 : 24, height: tab == .centerChat ? 32 : 24)
                            .foregroundColor(colorForTab())
                            .opacity(tappedTab == tab ? 0.5 : 1.0)
                    }
                }
                .frame(width: 44, height: 44, alignment: .center)
                .offset(y: -8) // Move icon up
            }
            .frame(maxWidth: .infinity, minHeight: 60, maxHeight: 60)
            .contentShape(Rectangle())
            .animation(.none, value: selectedTab)
            .animation(.linear(duration: 0.1), value: tappedTab)

            // Underline indicator (smaller, closer, not for brain icon)
            if selectedTab == tab && !isBrainIcon() {
                Rectangle()
                    .fill(Color.black)
                    .frame(width: 18, height: 2)
                    .cornerRadius(1)
                    .offset(y: underlineOffset())
                    .opacity(underlineAppear ? 1.0 : 0.0)
                    .animation(tab == .home ? .timingCurve(0.4, 0.0, 0.2, 1.0, duration: 0.5) : .linear(duration: 0.1), value: underlineAppear)
                    .onAppear {
                        if tab == .home {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                withAnimation(.timingCurve(0.4, 0.0, 0.2, 1.0, duration: 0.5)) {
                                    underlineAppear = true
                                }
                            }
                        } else {
                            underlineAppear = true
                        }
                    }
                    .onChange(of: selectedTab) { _, newValue in
                        if tab == .home {
                            underlineAppear = newValue == .home
                        } else {
                            underlineAppear = newValue == tab
                        }
                    }
                    .padding(.top, -19)
            } else {
                // Keep height for layout consistency
                Color.clear.frame(height: 2).padding(.top, -19)
            }
        }
    }

    private func underlineOffset() -> CGFloat {
        // For home tab, animate from below (move up on appear)
        if tab == .home && !underlineAppear {
            return 12
        }
        return 0
    }
    private func isBrainIcon() -> Bool {
        return icon == "brain" || icon == "brain-fill"
    }

    private func colorForTab() -> Color {
        if selectedTab == tab {
            switch tab {
            case .home:
                return .black
            case .centerChat:
                return .orange
            case .leftTab, .rightTab1, .calendar:
                return .red
            }
        } else {
            return .primary
        }
    }
}


// MARK: - Sparkle Bezier Movement Modifier
struct SparkleBezierMove: ViewModifier {
    var offset: CGFloat
    var geo: GeometryProxy

    func body(content: Content) -> some View {
        let start = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
        let end = CGPoint(x: geo.size.width - 25 + offset, y: geo.size.height / 2)
        let control = CGPoint(x: geo.size.width / 2 + offset / 2, y: geo.size.height / 2 - 18)

        return content
            .position(bezierPoint(t: bezierProgress(), start: start, control: control, end: end))
    }

    private func bezierProgress() -> CGFloat {
        let minOffset: CGFloat = 0
        let maxOffset: CGFloat = 55
        return min(max((offset - minOffset) / (maxOffset - minOffset), 0), 1)
    }

    private func bezierPoint(t: CGFloat, start: CGPoint, control: CGPoint, end: CGPoint) -> CGPoint {
        let x = pow(1 - t, 2) * start.x + 2 * (1 - t) * t * control.x + pow(t, 2) * end.x
        let y = pow(1 - t, 2) * start.y + 2 * (1 - t) * t * control.y + pow(t, 2) * end.y
        return CGPoint(x: x, y: y)
    }
}

// MARK: - Previews
#Preview("Main") {
    ContentView()
}
