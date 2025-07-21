// MARK: - Sparkle Header Animation
struct SparkleHeaderAnimation: View {
    @Binding var animate: Bool
    @State private var t: CGFloat = 0.0

    var body: some View {
        GeometryReader { geo in
            let iconSize: CGFloat = 24
            let yPos = geo.size.height / 2 // Center vertically in header
            let xStart = geo.size.width / 2 + 35
            let xEnd = xStart + 15

            // Straight line movement
            let pos = CGPoint(x: xStart + (xEnd - xStart) * t, y: yPos)

            // Start fade immediately with movement, complete fade at 40% of movement
            let fadeInStart: CGFloat = 0.0
            let fadeInEnd: CGFloat = 0.4
            let opacity: Double = {
                if t < fadeInStart {
                    return 0.0
                } else if t < fadeInEnd {
                    // Ease in
                    return Double((t - fadeInStart) / (fadeInEnd - fadeInStart))
                } else {
                    return 1.0
                }
            }()

            Image("sparkle-fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: iconSize, height: iconSize)
                .opacity(opacity)
                .position(x: pos.x, y: pos.y)
        }
        .frame(height: 30)
        .drawingGroup() // GPU optimization for smoother animation
        .onChange(of: animate) { _, shouldAnimate in
            if shouldAnimate {
                startAnimation()
            } else {
                // Reset animation state
                t = 0.0
            }
        }
    }
    
    private func startAnimation() {
        // Reset to start position
        t = 0.0
        
        // Use SwiftUI's native animation system for smoother performance
        withAnimation(.timingCurve(0.25, 0.1, 0.25, 1.0, duration: 0.8)) {
            t = 1.0
        }
    }
}
//
//  ChatView.swift
//  Briefly
//
//  Created by Anestis Archontopoulos on 20/7/25.
//

import SwiftUI

// MARK: - Scroll Offset Preference Key
struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Chat Message Model
struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let content: String
    let isFromUser: Bool
    let timestamp: Date
    let messageType: MessageType
    
    enum MessageType {
        case text
        case quickReply
    }
}

// MARK: - Chat View Model
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText: String = ""
    @Published var showQuickReplies: Bool = true
    @Published var hasUserSentMessage: Bool = false
    
    init() {
        loadDummyData()
    }
    
    private func loadDummyData() {
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        // Create realistic chat conversation
        messages = [
            ChatMessage(
                content: "Hi! How can I help?",
                isFromUser: false,
                timestamp: now.addingTimeInterval(-300), // 5 minutes ago
                messageType: .text
            ),
            ChatMessage(
                content: "You can link accounts from the following banks:\n\nDBS, OCBC, Standard Chartered, UOB, Maybank, and Bank of China.",
                isFromUser: false,
                timestamp: now.addingTimeInterval(-280),
                messageType: .text
            )
        ]
    }
    
    func sendMessage(_ content: String) {
        // Mark that user has sent a message
        hasUserSentMessage = true
        
        // First, animate quick replies away
        withAnimation(.easeInOut(duration: 0.3)) {
            showQuickReplies = false
        }
        
        // Then add the message after a slight delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let newMessage = ChatMessage(
                content: content,
                isFromUser: true,
                timestamp: Date(),
                messageType: .text
            )
            
            withAnimation(.easeInOut(duration: 0.3)) {
                self.messages.append(newMessage)
            }
        }
        
        inputText = ""
        
        // Simulate assistant response after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.addAssistantResponse()
        }
    }
    
    func handleQuickReply(_ replyText: String) {
        sendMessage(replyText)
    }
    
    private func addAssistantResponse() {
        let responses = [
            "Is there anything else I can help you with?",
            "Let me know if you need more information!",
            "Happy to assist with any other questions.",
            "Feel free to ask if you have more questions."
        ]
        
        let randomResponse = responses.randomElement() ?? responses[0]
        
        let assistantMessage = ChatMessage(
            content: randomResponse,
            isFromUser: false,
            timestamp: Date(),
            messageType: .text
        )
        
        withAnimation(.easeInOut(duration: 0.3)) {
            messages.append(assistantMessage)
        }
    }
}

// ...existing code...

// MARK: - Main Chat View
struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @Environment(\.dismiss) private var dismiss
    @Binding var isKeyboardActive: Bool
    @Binding var logoOffset: CGFloat
    @Binding var aiIconOpacity: Double
    @Binding var sparkleAnim: Bool
    
    // Header scroll state
    @State private var headerOffset: CGFloat = 0
    @State private var lastScrollOffset: CGFloat = 0
    @State private var isHeaderHidden: Bool = false
    @State private var hasAnimatedHeader: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            

            // Logo Header - using shared component with scroll-responsive positioning
            if !isHeaderHidden {
                ZStack {
                    SharedHeaderView(
                        logoOffset: $logoOffset,
                        aiIconOpacity: $aiIconOpacity
                    )
                    .transition(.identity)

                    // Sparkle Animation: appears centered, moves 20px right on appear
                    SparkleHeaderAnimation(animate: $sparkleAnim)
                }
                .offset(y: headerOffset)
                .animation(.easeInOut(duration: 0.6), value: headerOffset)
                .transition(.asymmetric(
                    insertion: .identity,
                    removal: .move(edge: .top).combined(with: .opacity)
                ))
            }

            // Messages Area
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        // Invisible top spacer to detect scroll position
                        Color.clear
                            .frame(height: 1)
                            .id("top")
                        // Messages
                        ForEach(viewModel.messages) { message in
                            ChatMessageView(message: message)
                                .id(message.id)
                        }
                        // Quick Reply Buttons
                        if viewModel.showQuickReplies {
                            QuickReplySection(viewModel: viewModel)
                                .transition(.asymmetric(
                                    insertion: .opacity.combined(with: .move(edge: .bottom)),
                                    removal: .opacity.combined(with: .scale(scale: 0.95))
                                ))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, isHeaderHidden ? 0 : 16) // Remove top padding when header is hidden
                    .padding(.bottom, 20)
                    .background(
                        GeometryReader { geometry in
                            Color.clear
                                .preference(key: ScrollOffsetKey.self, value: -geometry.frame(in: .named("scroll")).minY)
                        }
                    )
                }
                .coordinateSpace(name: "scroll")
                .onPreferenceChange(ScrollOffsetKey.self) { value in
                    handleScrollOffset(value)
                }
                .onChange(of: viewModel.messages.count) {
                    if let lastMessage = viewModel.messages.last {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }

            // Input Area
            ChatInputView(
                viewModel: viewModel, 
                isKeyboardActive: $isKeyboardActive
            )
        }
        .background(Color.chatBackground)
        .onAppear {
            // Initialize scroll tracking based on existing messages
            // Header behavior is now controlled by viewModel.hasUserSentMessage
        }
        .onChange(of: viewModel.hasUserSentMessage) { _, newValue in
            if newValue && !hasAnimatedHeader {
                animateHeaderAway()
                hasAnimatedHeader = true
            }
        }
    }
    
    private func handleScrollOffset(_ scrollOffset: CGFloat) {
        // Only respond to scrolling if user hasn't sent a message yet AND header isn't being animated away
        guard !viewModel.hasUserSentMessage && !isHeaderHidden else { return }
        
        let scrollDelta = scrollOffset - lastScrollOffset
        let maxHeaderOffset: CGFloat = -80 // How far header can move up
        
        // With negated coordinate system:
        // Positive delta = scrolling UP → hide header
        // Negative delta = scrolling DOWN → show header
        if scrollDelta > 5 { // Scrolling UP with sufficient velocity
            withAnimation(.easeOut(duration: 0.25)) {
                headerOffset = max(headerOffset - scrollDelta * 0.8, maxHeaderOffset)
            }
        } else if scrollDelta < -3 { // Scrolling DOWN - show header
            withAnimation(.easeOut(duration: 0.3)) {
                headerOffset = min(headerOffset - scrollDelta * 1.2, 0)
            }
        }
        
        lastScrollOffset = scrollOffset
    }
    
    private func animateHeaderAway() {
        // Animate header sliding up and out of view with spring animation
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)) {
            headerOffset = -150 // Move header completely off screen
        }
        
        // After the slide animation completes, remove header from hierarchy to allow chat expansion
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeOut(duration: 0.3)) {
                isHeaderHidden = true
            }
        }
    }
}

// MARK: - Chat Message View
struct ChatMessageView: View {
    let message: ChatMessage

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if message.isFromUser {
                Spacer(minLength: 60)
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.content)
                        .font(.satoshiRegular(size: 16))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.chatBlue)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                }
            } else {
                HStack(alignment: .top, spacing: 12) {
                    Circle()
                        .fill(Color.black)
                        .frame(width: 32, height: 32)
                        .padding(.top, 4)
                    VStack(alignment: .leading, spacing: 8) {
                        Text(message.content)
                            .font(.satoshiRegular(size: 16))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.assistantBubble)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                }
                Spacer(minLength: 60)
            }
        }
        .padding(.horizontal, 4)
    }
}

// MARK: - Quick Reply Section
struct QuickReplySection: View {
    @ObservedObject var viewModel: ChatViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            QuickReplyButtonView(
                text: "Got it, thanks",
                action: { viewModel.handleQuickReply("Got it, thanks") }
            )
            
            QuickReplyButtonView(
                text: "I need more help",
                action: { viewModel.handleQuickReply("I need more help") }
            )
        }
        .padding(.top, 8)
    }
}

// MARK: - Quick Reply Button View
struct QuickReplyButtonView: View {
    let text: String
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.satoshiMedium(size: 16))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.chatBlue)
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .opacity(isPressed ? 0.8 : 1.0)
        }
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

// MARK: - Chat Input View
struct ChatInputView: View {
    @ObservedObject var viewModel: ChatViewModel
    @Binding var isKeyboardActive: Bool
    @FocusState private var isTextFieldFocused: Bool
    @State private var isTextFieldExpanded: Bool = false
    
    private var shouldShowSendButton: Bool {
        !viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isTextFieldFocused
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Attachment Button - always visible, anchored to the left
            Button(action: {
                // Attachment action
            }) {
                Image(systemName: "paperclip")
                    .font(.system(size: 20))
                    .foregroundColor(.chatGray)
            }
            
            // Text Input
            HStack(spacing: 12) {
                ZStack(alignment: .leading) {
                    // Custom placeholder
                    if viewModel.inputText.isEmpty {
                        Text("Type a message...")
                            .font(.satoshiRegular(size: 16))
                            .foregroundColor(.white.opacity(0.49))
                    }
                    
                    TextField("", text: $viewModel.inputText)
                        .font(.satoshiRegular(size: 16))
                        .foregroundColor(.white)
                        .focused($isTextFieldFocused)
                        #if canImport(UIKit)
                        .keyboardType(.default)
                        .submitLabel(.return)
                        #endif
                        .colorScheme(.dark)
                }
                .onSubmit {
                    if !viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        viewModel.sendMessage(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines))
                    }
                }
                .onChange(of: isTextFieldFocused) { _, focused in
                    withAnimation(.easeInOut(duration: 0.35)) {
                        isTextFieldExpanded = focused
                        isKeyboardActive = focused
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.chatBlue)
            .clipShape(RoundedRectangle(cornerRadius: 25))
            .scaleEffect(isTextFieldExpanded ? 1.02 : 1.0)
            
            // Send Button - appears when focused or has text
            if shouldShowSendButton {
                Button(action: {
                    if !viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        viewModel.sendMessage(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines))
                    }
                }) {
                    Image(systemName: !viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "arrow.up.circle.fill" : "arrow.up.circle")
                        .font(.system(size: 32))
                        .foregroundColor(.chatBlue)
                        .opacity(!viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 1.0 : 0.6)
                }
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.3).combined(with: .opacity).combined(with: .move(edge: .trailing)),
                    removal: .scale(scale: 0.3).combined(with: .opacity).combined(with: .move(edge: .trailing))
                ))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.chatBackground)
        .animation(.easeInOut(duration: 0.35), value: shouldShowSendButton)
    }
}

// MARK: - Previews
#Preview("Chat View") {
    ChatView(isKeyboardActive: .constant(false), logoOffset: .constant(0), aiIconOpacity: .constant(0), sparkleAnim: .constant(false))
}
