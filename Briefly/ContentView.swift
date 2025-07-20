//
//  ContentView.swift
//  Briefly
//
//  Created by Anestis Archontopoulos on 19/7/25.
//

import SwiftUI
import CoreHaptics

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
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Color.customBackground 
                    .ignoresSafeArea(.all)
                
                Group {
                    switch selectedTab {
                    case .home:
                        HomeView()
                            .transition(.opacity)
                    case .centerChat:
                        ComingSoonView() // Will be ChatView later
                            .transition(.opacity)
                    case .leftTab, .rightTab1, .calendar:
                        ComingSoonView()
                            .transition(.opacity)
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: selectedTab)
            }
            
            CustomTabBarView(selectedTab: $selectedTab)
        }
        .preferredColorScheme(.light)
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

// MARK: - Home/Dashboard Screen
// Clean landing page inspired by Notion's dashboard with Vectal.ai simplicity
struct HomeView: View {
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with logo - Notion-inspired clean header
            VStack(spacing: 4) {
                ZStack {
                    // Centered logo
                    HStack {
                        Spacer()
                        Image("Briefly")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 30)
                        Spacer()
                    }
                    
                    // Right profile icon positioned absolutely
                    HStack {
                        Spacer()
                        Button(action: {}) {
                            Image("user-circle")
                                .resizable()
                                .frame(width: 28, height: 28)
                                .foregroundColor(.primary)
                        }
                        .padding(.trailing, 8)
                    }
                }
            }
            .padding(.horizontal, 25)
            .padding(.vertical, 10)
            .background(Color.customBackground)
            
            // Empty content area
            Spacer()
        }
        .background(Color.customBackground)
    }
}






// MARK: - Coming Soon Screen
struct ComingSoonView: View {
    var body: some View {
        VStack(spacing: 0) {
            // Header with logo - keeping consistent structure
            VStack(spacing: 4) {
                ZStack {
                    // Centered logo
                    HStack {
                        Spacer()
                        Image("Briefly")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 30)
                        Spacer()
                    }
                    
                    // Right profile icon positioned absolutely
                    HStack {
                        Spacer()
                        Button(action: {}) {
                            Image("user-circle")
                                .resizable()
                                .frame(width: 28, height: 28)
                                .foregroundColor(.primary)
                        }
                        .padding(.trailing, 8)
                    }
                }
            }
            .padding(.horizontal, 25)
            .padding(.vertical, 10)
            .background(Color.customBackground)
            
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
    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    
    var body: some View {
        HStack(spacing: 0) {
            // Position 1: Home tab (far left)
            TabButton(
                tab: .home,
                selectedTab: $selectedTab,
                tappedTab: $tappedTab,
                icon: selectedTab == .home ? "home-fill" : "home",
                label: "Home",
                isSystemIcon: false,
                isCenter: false,
                hapticStyle: .light
            )
            
            Spacer()
            
            // Position 2: Left tab (barricade)
            TabButton(
                tab: .leftTab,
                selectedTab: $selectedTab,
                tappedTab: $tappedTab,
                icon: selectedTab == .leftTab ? "barricade-fill" : "barricade",
                label: "C/S",
                isSystemIcon: false,
                isCenter: false,
hapticStyle: .light)
            
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
                hapticStyle: .medium
            )
            
            Spacer()
            
            // Position 4: Right tab 1 (barricade)
            TabButton(
                tab: .rightTab1,
                selectedTab: $selectedTab,
                tappedTab: $tappedTab,
                icon: selectedTab == .rightTab1 ? "barricade-fill" : "barricade",
                label: "C/S",
                isSystemIcon: false,
                isCenter: false,
                hapticStyle: .light
            )
            
            Spacer()
            
            // Position 5: Calendar tab (far right)
            TabButton(
                tab: .calendar,
                selectedTab: $selectedTab,
                tappedTab: $tappedTab,
                icon: selectedTab == .calendar ? "calendar-dots-fill" : "calendar-dots",
                label: "Events",
                isSystemIcon: false,
                isCenter: false,
                hapticStyle: .light
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
    let hapticStyle: UIImpactFeedbackGenerator.FeedbackStyle
    
    private var impact: UIImpactFeedbackGenerator {
        UIImpactFeedbackGenerator(style: hapticStyle)
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                selectedTab = tab
            }
            tappedTab = tab
            impact.impactOccurred()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.linear(duration: 0.1)) {
                    tappedTab = nil
                }
            }
        }) {
            VStack(spacing: 5) {
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
                
                if !label.isEmpty {
                    Text(label)
                        .font(.satoshiBold(size: 11))
                        .foregroundColor(.black)
                        .opacity(tappedTab == tab ? 0.5 : 1.0)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .frame(height: 24)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(width: 60)
        }
        .frame(height: 60)
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

// MARK: - Previews
#Preview("Main") {
    ContentView()
}