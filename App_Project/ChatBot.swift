import SwiftUI



func navigateToHomeScreen() {
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = UIHostingController(rootView: HomeScreen())
            window.makeKeyAndVisible()
        }
    }


// Model for chat messages
struct ChatMessage: Identifiable, Equatable {
    var id = UUID()
    var content: String
    var isUser: Bool // true for user message, false for bot message
    
    // Equatable conformance
    static func ==(lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        return lhs.id == rhs.id && lhs.content == rhs.content && lhs.isUser == rhs.isUser
    }
}

// View for each chat message
struct ChatMessageView: View {
    var message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                VStack(alignment: .trailing) {
                    Text(message.content)
                        .padding()
                        .background(Color.blue.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(radius: 3)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    
                    Image(systemName: "person.circle.fill") // User profile icon
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.blue)
                }
            } else {
                VStack(alignment: .leading) {
                    Image(systemName: "bubble.left.and.bubble.right.fill") // Bot profile icon
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.white)
                    
                    Text(message.content)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(radius: 3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.top, 5)
    }
}

// API Response Model
struct OpenAIResponse: Decodable {
    struct Choice: Decodable {
        struct Message: Decodable {
            var content: String
        }
        var message: Message
    }
    var choices: [Choice]
}

// ViewModel to handle the API call
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isLoading: Bool = false
    
    let apiKey = "YOUR_OPENAI_API_KEY" // OpenAI API Anahtarınızı buraya girin
    
    init() {
        // Add welcome message when the app opens
        let welcomeMessage = ChatMessage(content: "Hoşgeldiniz, ben NOVAal. Ne sormak istersiniz?", isUser: false)
        messages.append(welcomeMessage)
    }
    
    func sendMessage(userMessage: String) {
        let userChat = ChatMessage(content: userMessage, isUser: true)
        messages.append(userChat)
        
        // API çağrısı yap
        isLoading = true
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": "You are an AI assistant designed to provide clear and helpful answers."],
                ["role": "user", "content": userMessage]
            ],
            "max_tokens": 150
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
            request.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                }
                
                if let error = error {
                    print("API Error: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        let errorMessage = ChatMessage(content: "Error: \(error.localizedDescription)", isUser: false)
                        self?.messages.append(errorMessage)
                    }
                    return
                }
                
                guard let data = data else { return }
                
                do {
                    let response = try JSONDecoder().decode(OpenAIResponse.self, from: data)
                    if let botContent = response.choices.first?.message.content {
                        let botResponse = ChatMessage(content: botContent, isUser: false)
                        DispatchQueue.main.async {
                            self?.messages.append(botResponse)
                        }
                    }
                } catch {
                    print("JSON Decode Error: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        let errorMessage = ChatMessage(content: "Failed to parse response", isUser: false)
                        self?.messages.append(errorMessage)
                    }
                }
            }
            task.resume()
        } catch {
            isLoading = false
            print("Error encoding JSON request body: \(error.localizedDescription)")
        }
    }
}

// Main chat view
struct ChatbotView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = ChatViewModel()
    @State private var userMessage: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                // Top Bar with Back Button
                HStack {
                    Button(action: {
                        navigateToHomeScreen()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .padding()
                    }
                    Spacer()
                    Text("NOVAaI Chatbot")
                        .foregroundColor(.white)
                        .font(.headline)
                    Spacer()
                }
                .background(Color.blue)
                
                // Messages list with ScrollView
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack {
                            ForEach(viewModel.messages) { message in
                                ChatMessageView(message: message)
                                    .id(message.id)
                            }
                            if viewModel.isLoading {
                                ProgressView()
                                    .id(UUID())
                                    .padding()
                            }
                        }
                    }
                    .onChange(of: viewModel.messages) { _ in
                        if let lastMessage = viewModel.messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }

                // User input and send button
                HStack {
                    TextField("Type a message...", text: $userMessage)
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .padding(.leading)
                    
                    Button(action: {
                        viewModel.sendMessage(userMessage: userMessage)
                        userMessage = ""
                    }) {
                        Image(systemName: "paperplane.fill") // Send icon
                            .resizable()
                            .scaledToFit()
                            .frame(width: 35, height: 35)
                            .foregroundColor(.blue)
                            .padding(.trailing)
                    }
                    .disabled(userMessage.isEmpty)
                }
                .padding()
                .background(Color.black.opacity(0.9).cornerRadius(12))
                .shadow(radius: 5)
            }
            .background(LinearGradient(gradient: Gradient(colors: [Color.black, Color.blue]), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(.all))
            .navigationBarHidden(true) // Burada geri butonunu kontrol etmek için navigation bar'ı gizliyoruz
        }
    }
}

// Preview
struct ChatbotView_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen()
    }
}

