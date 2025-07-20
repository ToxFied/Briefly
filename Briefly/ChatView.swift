//
//  ChatView.swift
//  Briefly
//
//  Created by Anestis Archontopoulos on 20/7/25.
//

import SwiftUI

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
                content: "Which banks can I link to my app?",
                isFromUser: true,
                timestamp: now.addingTimeInterval(-290),
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

// MARK: - Main Chat View
struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @Environment(\.dismiss) private var dismiss
    @Binding var isKeyboardActive: Bool
    @Binding var logoOffset: CGFloat
    @Binding var aiIconOpacity: Double
    
    var body: some View {
        VStack(spacing: 0) {
            // Logo Header - using shared component
            SharedHeaderView(
                logoOffset: $logoOffset,
                aiIconOpacity: $aiIconOpacity
            )
            .transition(.identity) // No fade transition for logo
            
            // Messages Area
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 16) {
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
                    .padding(.top, 16)
                    .padding(.bottom, 20)
                }
                .onChange(of: viewModel.messages.count) { _ in
                    if let lastMessage = viewModel.messages.last {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            // Input Area
            ChatInputView(viewModel: viewModel, isKeyboardActive: $isKeyboardActive)
        }
        .background(Color.chatBackground)
        .navigationBarHidden(true)
    }
}



// MARK: - Chat Message View
struct ChatMessageView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if message.isFromUser {
                Spacer(minLength: 60)
                
                // User Message
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
                // Assistant Avatar (positioned at top)
                HStack(alignment: .top, spacing: 12) {
                    Circle()
                        .fill(Color.black)
                        .frame(width: 32, height: 32)
                        .padding(.top, 4)
                    
                    // Assistant Message
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
                        .keyboardType(.default)
                        .submitLabel(.return)
                        .colorScheme(.dark)
                }
                .onSubmit {
                    if !viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        viewModel.sendMessage(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines))
                    }
                }
                .onChange(of: isTextFieldFocused) { focused in
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
    ChatView(isKeyboardActive: .constant(false), logoOffset: .constant(0), aiIconOpacity: .constant(0))
}
