//
//  ContentView.swift
//  Briefly
//
//  Created by Anestis Archontopoulos on 19/7/25.
//

import SwiftUI

// MARK: - Main App Structure
// Inspired by Notion's clean navigation and Vectal.ai's minimal UI
struct ContentView: View {
    var body: some View {
        ZStack {
            Color.customBackground
                .ignoresSafeArea(.all)
            
            HomeView()
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
                    HStack {
                        // Left invisible spacer to balance the profile icon
                        Button(action: {}) {
                            Image(systemName: "person.circle")
                                .font(.system(size: 24))
                                .foregroundColor(.clear)
                        }
                        .padding(.leading, 8)
                        .disabled(true)
                        
                        Spacer()
                        
                        // Centered logo
                        Image("Briefly")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 30)
                        
                        Spacer()
                        
                        // Right profile icon
                        Button(action: {}) {
                            Image(systemName: "person.circle")
                                .font(.system(size: 24))
                                .foregroundColor(.primary)
                        }
                        .padding(.trailing, 8)
                    }
                }
                .padding(.horizontal, 20)
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






// MARK: - Previews
#Preview("Home") {
    HomeView()
}

#Preview("Main App") {
    ContentView()
}
    