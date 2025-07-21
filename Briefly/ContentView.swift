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
    
    // Animation state for logo positioning and AI icon visibility
    @State private var logoOffset: CGFloat = 0
    @State private var aiIconOpacity: Double = 0.0
    @State private var sparkleAnim: Bool = false
    @State private var reverseSparkleAnim: Bool = false
    
    var body: some View {
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
                            reverseSparkleAnim: $reverseSparkleAnim
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
                    logoOffset = -20
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
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
    @State private var isAnimating: Bool = false

    var body: some View {
        GeometryReader { geo in
            let iconSize: CGFloat = 24
            let yPos = geo.size.height / 2 // Center vertically in header
            let xPos = geo.size.width / 2 + 50  // Stay at the right position (no sliding)

            Image("sparkle-fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: iconSize, height: iconSize)
                .opacity(opacity)
                .position(x: xPos, y: yPos)
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
        print("Reverse animation starting: isAnimating=\(isAnimating), opacity=\(opacity)")
        
        withAnimation(.easeOut(duration: 0.4)) {
            opacity = 0.0 // Fade to invisible
        }
        
        // Reset the animation state after completion
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            resetAnimation()
        }
    }
    
    private func resetAnimation() {
        isAnimating = false
        opacity = 0.0
        print("Reverse animation reset: isAnimating=\(isAnimating), opacity=\(opacity)")
    }
}

// MARK: - Home/Dashboard Screen
// Clean landing page inspired by Notion's dashboard with Vectal.ai simplicity
struct HomeView: View {
    @Binding var logoOffset: CGFloat
    @Binding var aiIconOpacity: Double
    @Binding var reverseSparkleAnim: Bool

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
                        Button(action: {}) {
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
    }
}

// MARK: - Coming Soon Screen
struct ComingSoonView: View {
    @Binding var logoOffset: CGFloat
    @Binding var aiIconOpacity: Double
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with logo - using shared component
            SharedHeaderView(logoOffset: $logoOffset, aiIconOpacity: $aiIconOpacity)
            
            // Coming soon content
            VStack(spacing: 24) {
                Spacer()
                
                Image("coming_soon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                
                Text("In development")
                    .font(.satoshiBold(size: 24))
                    .foregroundColor(.primary)
                
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
        HStack(spacing: 0) {
            // Position 1: Home tab (far left)
            TabButton(
                tab: .home,
                selectedTab: $selectedTab,
                tappedTab: $tappedTab,
                icon: selectedTab == .home ? "home-fill" : "home",
                label: "",
                isSystemIcon: false,
                isCenter: false,
                hapticStyle: {
                    #if canImport(UIKit)
                    return .light
                    #else
                    return 0
                    #endif
                }()
            )
            
            Spacer()
            
            // Position 2: Left tab (barricade)
            TabButton(
                tab: .leftTab,
                selectedTab: $selectedTab,
                tappedTab: $tappedTab,
                icon: selectedTab == .leftTab ? "barricade-fill" : "barricade",
                label: "",
                isSystemIcon: false,
                isCenter: false,
                hapticStyle: {
                    #if canImport(UIKit)
                    return .light
                    #else
                    return 0
                    #endif
                }())
            
            Spacer()
            
            // Position 3: CENTER - Main Chat tab (brain)
            TabButton(
                tab: .centerChat,
                selectedTab: $selectedTab,
                tappedTab: $tappedTab,
                icon: selectedTab == .centerChat ? "brain-fill" : "brain",
                label: "",
                isSystemIcon: false,
                isCenter: false,
                hapticStyle: {
                    #if canImport(UIKit)
                    return .medium
                    #else
                    return 1
                    #endif
                }()
            )
            
            Spacer()
            
            // Position 4: Right tab 1 (barricade)
            TabButton(
                tab: .rightTab1,
                selectedTab: $selectedTab,
                tappedTab: $tappedTab,
                icon: selectedTab == .rightTab1 ? "barricade-fill" : "barricade",
                label: "",
                isSystemIcon: false,
                isCenter: false,
                hapticStyle: {
                    #if canImport(UIKit)
                    return .light
                    #else
                    return 0
                    #endif
                }()
            )
            
            Spacer()
            
            // Position 5: Calendar tab (far right)
            TabButton(
                tab: .calendar,
                selectedTab: $selectedTab,
                tappedTab: $tappedTab,
                icon: selectedTab == .calendar ? "calendar-dots-fill" : "calendar-dots",
                label: "",
                isSystemIcon: false,
                isCenter: false,
                hapticStyle: {
                    #if canImport(UIKit)
                    return .light
                    #else
                    return 0
                    #endif
                }()
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 40)
        .padding(.vertical, 10)
        .padding(.bottom, -30)
        .background(Color.navbarBackground)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.gray.opacity(0.1)),
            alignment: .top
        )
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
    
    var body: some View {
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
            Group {
                if isSystemIcon {
                    Image(systemName: icon)
                        .font(.system(size: isCenter ? 28 : 24))
                } else {
                    Image(icon)
                        .resizable()
                        .frame(width: tab == .centerChat ? 32 : 24, height: tab == .centerChat ? 32 : 24)
                }
            }
            .foregroundColor(colorForTab())
            .opacity(tappedTab == tab ? 0.5 : 1.0)
        }
        .frame(width: 60, height: 60)
        .contentShape(Rectangle())
        .animation(.none, value: selectedTab)
        .animation(.linear(duration: 0.1), value: tappedTab)
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
