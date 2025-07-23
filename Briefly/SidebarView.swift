//
//  SidebarView.swift
//  Briefly
//
//  Created by Claude on 23/7/25.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Sidebar Section Model
enum SidebarSection: String, CaseIterable {
    case projects = "Projects"
    case tasks = "Tasks"
    case settings = "Settings"
    case profile = "Account"
    
    var icon: String {
        switch self {
        case .projects:
            return "folder"
        case .tasks:
            return "list.bullet"
        case .settings:
            return "gear-six"
        case .profile:
            return "user-circle"
        }
    }
    
    var isSystemIcon: Bool {
        switch self {
        case .tasks:
            return true
        case .projects, .settings, .profile:
            return false
        }
    }
}

// MARK: - Main Sidebar View
struct SidebarView: View {
    @Binding var isPresented: Bool
    @State private var tappedSection: SidebarSection?
    @State private var liquidAnimationProgress: CGFloat = 0
    @State private var showContent: Bool = false
    @State private var sectionsVisible: [Bool] = Array(repeating: false, count: SidebarSection.allCases.count)
    @State private var closeButtonVisible: Bool = false
    @State private var footerVisible: Bool = false
    
    // Haptic feedback generators
    #if canImport(UIKit)
    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    #endif
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Full-screen background with tap to close
                Color.customBackground
                    .ignoresSafeArea(.all)
                    .onTapGesture {
                        dismissSidebar()
                    }
                
                // Sidebar Content
                VStack(alignment: .leading, spacing: 0) {
                    // Header with close button
                    HStack {
                        Spacer()
                        Button(action: {
                            #if canImport(UIKit)
                            lightImpact.impactOccurred()
                            #endif
                            dismissSidebar()
                        }) {
                            Image("sidebar-fill")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.primary)
                                .offset(x: -10)
                        }
                    }
                    .padding(.horizontal, 35)
                    .padding(.top, geometry.safeAreaInsets.top + 50)
                    .padding(.bottom, 16)
                    .opacity(closeButtonVisible ? 1 : 0)
                    .offset(y: closeButtonVisible ? 0 : -10)
                    
                    // Sidebar Sections
                    VStack(spacing: 8) {
                        ForEach(Array(SidebarSection.allCases.enumerated()), id: \.element) { index, section in
                            SidebarSectionButton(
                                section: section,
                                tappedSection: $tappedSection,
                                action: {
                                    handleSectionTap(section)
                                }
                            )
                            .opacity(sectionsVisible[index] ? 1 : 0)
                            .offset(y: sectionsVisible[index] ? 0 : 20)
                            .animation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0).delay(Double(index) * 0.1), value: sectionsVisible[index])
                        }
                    }
                    .padding(.horizontal, 35)
                    
                    Spacer()
                    
                    // Footer
                    VStack(alignment: .leading, spacing: 8) {
                        Rectangle()
                            .fill(Color.primary.opacity(0.1))
                            .frame(height: 1)
                        
                        HStack {
                            Spacer()
                            Text("Briefly v1.0")
                                .font(.satoshiBold(size: 12))
                                .foregroundColor(.primary.opacity(0.6))
                            Spacer()
                        }
                        .padding(.bottom, geometry.safeAreaInsets.bottom + 20)
                    }
                    .padding(.horizontal, 25)
                    .opacity(footerVisible ? 1 : 0)
                    .offset(y: footerVisible ? 0 : 20)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .clipShape(
                LiquidFillShape(progress: liquidAnimationProgress)
            )
            .drawingGroup() // GPU optimization for smooth animations
            .onAppear {
                startLiquidAnimation()
            }
        }
        .ignoresSafeArea(.all)
    }
    
    private func startLiquidAnimation() {
        // Reset all animation states
        liquidAnimationProgress = 0
        showContent = false
        sectionsVisible = Array(repeating: false, count: SidebarSection.allCases.count)
        closeButtonVisible = false
        footerVisible = false
        
        // Start liquid fill animation
        withAnimation(.timingCurve(0.2, 0.8, 0.2, 1.0, duration: 0.7)) {
            liquidAnimationProgress = 1.0
        }
        
        // Start content animations after liquid reaches 60%
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            startContentAnimations()
        }
    }
    
    private func startContentAnimations() {
        // Animate sections with staggered timing
        for index in 0..<sectionsVisible.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.1) {
                sectionsVisible[index] = true
            }
        }
        
        // Animate close button
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                closeButtonVisible = true
            }
        }
        
        // Animate footer last
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(sectionsVisible.count) * 0.1 + 0.1) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                footerVisible = true
            }
        }
    }
    
    private func dismissSidebar() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isPresented = false
        }
    }
    
    private func handleSectionTap(_ section: SidebarSection) {
        #if canImport(UIKit)
        lightImpact.impactOccurred()
        #endif
        
        // For now, just close the sidebar when any section is tapped
        // In a real app, you would navigate to the appropriate view
        withAnimation(.easeInOut(duration: 0.3)) {
            isPresented = false
        }
        
        // TODO: Add navigation logic for each section
        switch section {
        case .projects:
            print("Navigate to Projects")
        case .tasks:
            print("Navigate to Tasks")
        case .settings:
            print("Navigate to Settings")
        case .profile:
            print("Navigate to Profile")
        }
    }
}

// MARK: - Sidebar Section Button
struct SidebarSectionButton: View {
    let section: SidebarSection
    @Binding var tappedSection: SidebarSection?
    let action: () -> Void
    
    private var isPressed: Bool {
        tappedSection == section
    }
    
    var body: some View {
        Button(action: {
            tappedSection = section
            action()
            
            // Reset tap state after brief delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.linear(duration: 0.1)) {
                    tappedSection = nil
                }
            }
        }) {
            HStack(spacing: 16) {
                // Icon
                Group {
                    if section.isSystemIcon {
                        Image(systemName: section.icon)
                            .font(.system(size: 20, weight: .medium))
                    } else {
                        Image(section.icon)
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                }
                .foregroundColor(.primary)
                .frame(width: 20, height: 20)
                
                // Label
                Text(section.rawValue)
                    .font(.satoshiBold(size: 16))
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Arrow indicator
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.primary.opacity(0.4))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.primary.opacity(isPressed ? 0.1 : 0))
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .opacity(isPressed ? 0.7 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.easeInOut(duration: 0.1), value: isPressed)
    }
}

// MARK: - Liquid Fill Shape
struct LiquidFillShape: Shape {
    var progress: CGFloat
    
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        if progress <= 0 {
            return path
        }
        
        // Start from top-left corner (sidebar button origin)
        let startPoint = CGPoint(x: 0, y: 50)
        
        if progress >= 1.0 {
            // Full screen coverage
            path.addRect(rect)
            return path
        }
        
        // Calculate liquid expansion
        let maxRadius = max(rect.width, rect.height) * 1.2
        let currentRadius = maxRadius * progress
        
        // Create organic liquid shape with bezier curves
        let centerX = currentRadius * 0.3
        let centerY = startPoint.y + currentRadius * 0.2
        
        // Create a more organic, liquid-like expansion
        path.move(to: startPoint)
        
        // Add curved expansion that feels like liquid flowing
        let controlPoint1 = CGPoint(x: centerX + currentRadius * 0.6, y: centerY - currentRadius * 0.3)
        let controlPoint2 = CGPoint(x: centerX + currentRadius * 0.4, y: centerY + currentRadius * 0.7)
        
        // Top curve
        path.addQuadCurve(
            to: CGPoint(x: min(centerX + currentRadius, rect.maxX), y: max(centerY - currentRadius, 0)),
            control: controlPoint1
        )
        
        // Right edge
        if currentRadius > rect.width * 0.5 {
            path.addLine(to: CGPoint(x: rect.maxX, y: max(centerY - currentRadius, 0)))
            path.addLine(to: CGPoint(x: rect.maxX, y: min(centerY + currentRadius, rect.maxY)))
        }
        
        // Bottom curve
        path.addQuadCurve(
            to: CGPoint(x: max(centerX - currentRadius * 0.3, 0), y: min(centerY + currentRadius, rect.maxY)),
            control: controlPoint2
        )
        
        // Left edge back to start
        if currentRadius > rect.height * 0.3 {
            path.addLine(to: CGPoint(x: 0, y: min(centerY + currentRadius, rect.maxY)))
        }
        
        path.addLine(to: startPoint)
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Previews
#Preview("Sidebar") {
    SidebarView(isPresented: .constant(true))
        .background(Color.customBackground)
}