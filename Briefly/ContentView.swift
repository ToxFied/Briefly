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
    case sparkle
    case comingSoon
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
                    if selectedTab == .comingSoon {
                        ComingSoonView()
                            .transition(.opacity)
                    } else {
                        HomeView()
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
    static let customBackground = Color(hex: "#F0F2F2")
    
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
        NavigationView {
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
                    .background(Color.customBackground)
            }
            .background(Color.customBackground)
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
        .background(Color.customBackground)
    }
}






// MARK: - Coming Soon Screen
struct ComingSoonView: View {
    var body: some View {
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
        HStack(spacing: 100) {
            // Home tab (left)
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    selectedTab = .home
                }
                tappedTab = .home
                lightImpact.impactOccurred()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.linear(duration: 0.1)) {
                        tappedTab = nil
                    }
                }
            }) {
                Image(systemName: selectedTab == .home ? "house.fill" : "house")
                    .font(.system(size: 24))
                    .foregroundColor(selectedTab == .home ? .black : .primary)
                    .opacity(tappedTab == .home ? 0.5 : 1.0)
            }
            .animation(.none, value: selectedTab)
            .animation(.linear(duration: 0.1), value: tappedTab)
            
            // Sparkle tab (center)
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    selectedTab = .sparkle
                }
                tappedTab = .sparkle
                mediumImpact.impactOccurred()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.linear(duration: 0.1)) {
                        tappedTab = nil
                    }
                }
            }) {
                Image(selectedTab == .sparkle ? "sparkle-fill" : "sparkle")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(selectedTab == .sparkle ? .orange : .primary)
                    .opacity(tappedTab == .sparkle ? 0.5 : 1.0)
            }
            .animation(.none, value: selectedTab)
            .animation(.linear(duration: 0.1), value: tappedTab)
            
            // Traffic cone tab (right)
            Button(action: {
                selectedTab = .comingSoon
                tappedTab = .comingSoon
                heavyImpact.impactOccurred()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.linear(duration: 0.1)) {
                        tappedTab = nil
                    }
                }
            }) {
                Image(selectedTab == .comingSoon ? "traffic-cone-fill" : "traffic-cone")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(selectedTab == .comingSoon ? .red : .primary)
                    .opacity(tappedTab == .comingSoon ? 0.5 : 1.0)
            }
            .animation(.none, value: selectedTab)
            .animation(.linear(duration: 0.1), value: tappedTab)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical,30)
        .padding(.bottom, -35) // Safe area padding for tab bar
        .background(Color.white)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.gray.opacity(0.3)),
            alignment: .top
        )
    }
}

// MARK: - Previews
#Preview("Main") {
    ContentView()
}
    
