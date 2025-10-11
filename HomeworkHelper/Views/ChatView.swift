import SwiftUI

struct ChatView: View {
    let problemId: UUID
    
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var messageText = ""
    @State private var isSending = false
    
    private var messages: [ChatMessage] {
        dataManager.messages[problemId.uuidString] ?? []
    }
    
    private var problem: HomeworkProblem? {
        dataManager.problems.first(where: { $0.id == problemId })
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    ScrollViewReader { proxy in
                        VStack(spacing: 12) {
                            ForEach(messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }
                            
                            if isSending {
                                HStack {
                                    ProgressView()
                                    Text("Thinking...")
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                            }
                        }
                        .padding()
                        .onChange(of: messages.count) { _ in
                            if let lastMessage = messages.last {
                                withAnimation {
                                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                }
                            }
                        }
                    }
                }
                
                inputBar
            }
            .navigationTitle("AI Tutor")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private var inputBar: some View {
        HStack(spacing: 12) {
            TextField("Ask for help...", text: $messageText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disabled(isSending)
            
            Button {
                Task {
                    await sendMessage()
                }
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(messageText.isEmpty ? .gray : .blue)
            }
            .disabled(messageText.isEmpty || isSending)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
    }
    
    private func sendMessage() async {
        let text = messageText
        messageText = ""
        
        let userMessage = ChatMessage(
            problemId: problemId,
            role: .user,
            content: text
        )
        dataManager.addMessage(userMessage, for: problemId)
        
        isSending = true
        
        do {
            let problemContext = problem?.problemText ?? "homework problem"
            let userGradeLevel = dataManager.currentUser?.getGradeLevel() ?? "elementary"
            let userId = dataManager.currentUser?.userId
            let response = try await BackendAPIService.shared.generateChatResponse(
                messages: messages,
                problemContext: problemContext,
                userGradeLevel: userGradeLevel,
                userId: userId
            )
            
            let assistantMessage = ChatMessage(
                problemId: problemId,
                role: .assistant,
                content: response
            )
            dataManager.addMessage(assistantMessage, for: problemId)
        } catch {
            let errorMessage = ChatMessage(
                problemId: problemId,
                role: .assistant,
                content: "Sorry, I couldn't process that. Please try again."
            )
            dataManager.addMessage(errorMessage, for: problemId)
        }
        
        isSending = false
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.role == .user {
                Spacer()
            }
            
            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .padding(12)
                    .background(message.role == .user ? Color.blue : Color.gray.opacity(0.2))
                    .foregroundColor(message.role == .user ? .white : .primary)
                    .cornerRadius(16)
                
                Text(formatTime(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: 280, alignment: message.role == .user ? .trailing : .leading)
            
            if message.role == .assistant {
                Spacer()
            }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
