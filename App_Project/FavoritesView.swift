import SwiftUI
import Firebase
import FirebaseAuth

struct FavoritesView: View {
    @State private var isLoading = false
    @State private var selectedPage: Int? = nil
    @State private var favoriteItems = Array(repeating: false, count: 10)

    let contentData: [Content] = [
        Content(imageName: "zara", title: "Zara", description: "Zara'da 750 TL MaxiPuan Fırsatı!", maxipuan: "750 TL MaxiPuan", expiryDate: Date().addingTimeInterval(86400 * 3 + 3600 * 5)),
        Content(imageName: "mavi", title: "MAVİ", description: "Mavi'da 1.000 TL MaxiPuan Fırsatı!", maxipuan: "1.000 TL MaxiPuan", expiryDate: Date().addingTimeInterval(86400 * 2 + 3600 * 12)),
        Content(imageName: "boyner", title: "BOYNER", description: "Boyner'de 500 TL MaxiPuan Fırsatı!", maxipuan: "500 TL MaxiPuan", expiryDate: Date().addingTimeInterval(86400 * 5 + 3600 * 3)),
        Content(imageName: "only", title: "ONLY", description: "Only'de 600 TL MaxiPuan Fırsatı!", maxipuan: "600 TL MaxiPuan", expiryDate: Date().addingTimeInterval(86400 * 4)),
        Content(imageName: "nike", title: "Nike", description: "Nike'da 800 TL MaxiPuan Fırsatı!", maxipuan: "800 TL MaxiPuan", expiryDate: Date().addingTimeInterval(86400 * 6 + 3600)),
        Content(imageName: "image6", title: "Adidas", description: "Adidas'ta 700 TL MaxiPuan Fırsatı!", maxipuan: "700 TL MaxiPuan", expiryDate: Date().addingTimeInterval(86400 * 3 + 3600 * 8)),
        Content(imageName: "image7", title: "H&M", description: "H&M'de 900 TL MaxiPuan Fırsatı!", maxipuan: "900 TL MaxiPuan", expiryDate: Date().addingTimeInterval(86400 * 2 + 3600 * 6)),
        Content(imageName: "image8", title: "Pull&Bear", description: "Pull&Bear'de 650 TL MaxiPuan Fırsatı!", maxipuan: "650 TL MaxiPuan", expiryDate: Date().addingTimeInterval(86400 * 4 + 3600 * 9)),
        Content(imageName: "image9", title: "Bershka", description: "Bershka'da 550 TL MaxiPuan Fırsatı!", maxipuan: "550 TL MaxiPuan", expiryDate: Date().addingTimeInterval(86400 * 3 + 3600 * 2)),
        Content(imageName: "image10", title: "Stradivarius", description: "Stradivarius'ta 600 TL MaxiPuan Fırsatı!", maxipuan: "600 TL MaxiPuan", expiryDate: Date().addingTimeInterval(86400 * 7))
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(contentData.indices, id: \.self) { index in
                        NavigationLink(
                            destination: PageDetailView(content: contentData[index]),
                            tag: index,
                            selection: $selectedPage
                        ) {
                            ContentCardView(content: contentData[index],
                                            isFavorite: $favoriteItems[index])
                        }
                        .simultaneousGesture(TapGesture().onEnded {
                            showLoadingScreen(for: index)
                        })
                    }
                }
                .padding()
            }
            .navigationBarTitle("Fırsatlar", displayMode: .inline)
        }
        .overlay(
            LoadingView(isLoading: $isLoading)
        )
    }

    private func showLoadingScreen(for index: Int) {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isLoading = false
            selectedPage = index
        }
    }
}

struct ContentCardView: View {
    let content: Content
    @Binding var isFavorite: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(content.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .cornerRadius(8)
                VStack(alignment: .leading, spacing: 4) {
                    Text(content.title)
                        .font(.headline)
                    Text(content.description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    HStack {
                        Text(content.maxipuan)
                            .font(.subheadline)
                            .foregroundColor(.pink)
                        Spacer()
                        Text("Son Gün: \(formattedDate(content.expiryDate))")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                }
                Spacer()
                Button(action: {
                    isFavorite.toggle()
                }) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(isFavorite ? .red : .gray)
                        .font(.title3)
                }
                .buttonStyle(BorderlessButtonStyle())
            }
            .padding()
            .background(Color.white)
            .cornerRadius(8)
            .shadow(radius: 4)
        }
    }
}

struct PageDetailView: View {
    let content: Content
    @State private var showMessage = false
    @State private var remainingTime: String = ""
    @State private var isParticipated = false

    var body: some View {
        VStack(spacing: 16) {
            Image(content.imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 200)
                .cornerRadius(8)
            Text(content.title)
                .font(.title)
                .bold()
            Text(content.description)
                .font(.body)
                .padding()
            Text("Kampanyanın Bitmesine: \(remainingTime)")
                .font(.subheadline)
                .foregroundColor(.gray)
                .onAppear {
                    startTimer()
                }
            Text(content.maxipuan)
                .font(.headline)
                .foregroundColor(.pink)
            Spacer()
            Button(action: {
                participateInCampaign()
            }) {
                Text(isParticipated ? "Katıldınız" : "Katıl")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isParticipated ? Color.green : Color.blue)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            .disabled(isParticipated)
            .alert(isPresented: $showMessage) {
                Alert(title: Text("Katılınız Onaylandı"),
                      message: Text("E-posta adresinize onay mesajı gönderildi."),
                      dismissButton: .default(Text("Tamam")))
            }
        }
        .padding()
    }

    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            let currentTime = Date()
            if content.expiryDate > currentTime {
                let interval = content.expiryDate.timeIntervalSince(currentTime)
                remainingTime = formatTimeRemaining(interval)
            } else {
                remainingTime = "Süre Doldu"
                timer.invalidate()
            }
        }
    }

    private func formatTimeRemaining(_ interval: TimeInterval) -> String {
        let days = Int(interval) / 86400
        let hours = (Int(interval) % 86400) / 3600
        let minutes = (Int(interval) % 3600) / 60
        return "\(days) Gün \(hours) Saat \(minutes) Dakika"
    }

    private func participateInCampaign() {
        guard let user = Auth.auth().currentUser else { return }
        let userPhoneNumber = user.phoneNumber ?? ""
        sendSMS(to: userPhoneNumber)
        isParticipated = true
        showMessage = true
    }

    private func sendSMS(to phoneNumber: String) {
        let messageContent = "\(content.title): \(content.description) \(content.maxipuan) \(formattedDate(content.expiryDate)) tarihine kadar geçerlidir."
        let parameters: [String: Any] = [
            "phoneNumber": phoneNumber,
            "message": messageContent
        ]

        Firestore.firestore().collection("smsRequests").addDocument(data: parameters) { error in
            if let error = error {
                print("SMS gönderim hatası: \(error.localizedDescription)")
            } else {
                print("SMS gönderildi: \(phoneNumber)")
            }
        }
    }
}

struct LoadingView: View {
    @Binding var isLoading: Bool

    var body: some View {
        if isLoading {
            ZStack {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                ProgressView("Yükleniyor...")
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
            }
        }
    }
}

struct Content {
    let imageName: String
    let title: String
    let description: String
    let maxipuan: String
    let expiryDate: Date
}

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView()
    }
}

private func formattedDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd.MM.yyyy"
    return formatter.string(from: date)
}

