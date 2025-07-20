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
        let newMessage = ChatMessage(
            content: content,
            isFromUser: true,
            timestamp: Date(),
            messageType: .text
        )
        
        withAnimation(.easeInOut(duration: 0.3)) {
            messages.append(newMessage)
        }
        
        inputText = ""
        
        // Simulate assistant response after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.addAssistantResponse()
        }
    }
    
    func handleQuickReply(_ replyText: String) {
        sendMessage(replyText)
        showQuickReplies = false
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
    
    var body: some View {
        VStack(spacing: 0) {
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
            ChatInputView(viewModel: viewModel)
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
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.satoshiMedium(size: 16))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.chatBlue)
                .clipShape(RoundedRectangle(cornerRadius: 25))
        }
    }
}

// MARK: - Chat Input View
struct ChatInputView: View {
    @ObservedObject var viewModel: ChatViewModel
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Text Input
            HStack(spacing: 12) {
                TextField("Type a message...", text: $viewModel.inputText)
                    .font(.satoshiRegular(size: 16))
                    .focused($isTextFieldFocused)
                    .submitLabel(.send)
                    .onSubmit {
                        if !viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            viewModel.sendMessage(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines))
                        }
                    }
                
                // Attachment Button
                Button(action: {
                    // Attachment action
                }) {
                    Image(systemName: "paperclip")
                        .font(.system(size: 20))
                        .foregroundColor(.chatGray)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.assistantBubble)
            .clipShape(RoundedRectangle(cornerRadius: 25))
            
            // Send Button (only visible when there's text)
            if !viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Button(action: {
                    viewModel.sendMessage(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines))
                }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.chatBlue)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.chatBackground)
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(.chatGray.opacity(0.3)),
            alignment: .top
        )
    }
}

// MARK: - Previews
#Preview("Chat View") {
    ChatView()
}