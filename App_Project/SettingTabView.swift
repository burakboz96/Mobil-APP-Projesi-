import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import AVFoundation

struct SettingsTabView: View {
    @State private var notificationsEnabled: Bool = true
    @State private var selectedTheme: String = "Light"
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var userData: [String: Any] = [:]
    private var db = Firestore.firestore()
    @State private var currentUser: User? = Auth.auth().currentUser
    @Environment(\.colorScheme) var colorScheme
    @State private var timeSpent: Int = 0
    @State private var player: AVAudioPlayer?
    @State private var isKVKKAccepted: Bool = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.red.opacity(0.9) // Arka plan rengi açık mavi
                    .edgesIgnoringSafeArea(.all)
                
                List {
                    // Profil Bilgileri Bölümü
                    Section(header: Text("Hesap Bilgileri")) {
                        HStack {
                            Text("Kullanıcı Adı:")
                            Spacer()
                            Text(username.isEmpty ? "Yükleniyor..." : username)
                                .foregroundColor(.gray)
                        }

                        HStack {
                            Text("E-posta:")
                            Spacer()
                            Text(email.isEmpty ? "Yükleniyor..." : email)
                                .foregroundColor(.gray)
                        }
                    }

                    // Genel Ayarlar Bölümü
                    Section(header: Text("Genel Ayarlar")) {
                        Toggle("Bildirimler", isOn: $notificationsEnabled)

                        Picker("Tema Seçimi", selection: $selectedTheme) {
                            Text("Light").tag("Light")
                            Text("Dark").tag("Dark")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .onChange(of: selectedTheme) { value in
                            updateAppTheme(value)
                        }
                    }

                    // Özel Ayarlar Sayfaları
                    Section(header: Text("Uygulama Ayarları")) {
                        NavigationLink(destination: NotificationSettingsView()) {
                            SettingsRow(icon: "bell.fill", color: .red, title: "Bildirimler")
                        }
                        NavigationLink(destination: SoundAndTouchSettingsView()) {
                            SettingsRow(icon: "speaker.wave.2.fill", color: .pink, title: "Ses ve Dokunuş")
                        }

                        NavigationLink(destination: ScreenTimeSettingsView(timeSpent: $timeSpent)) {
                            SettingsRow(icon: "hourglass", color: .blue, title: "Ekran Süresi: \(timeSpent) dk")
                        }
                    }

                    Section(header: Text("Güvenlik")) {
                        NavigationLink(destination: FaceIDSettingsView()) {
                            SettingsRow(icon: "faceid", color: .green, title: "Face ID ve Parola")
                        }

                        NavigationLink(destination: PrivacyAndSecuritySettingsView(isKVKKAccepted: $isKVKKAccepted)) {
                            SettingsRow(icon: "hand.raised.fill", color: .blue, title: "Gizlilik ve Güvenlik")
                        }
                    }

                    Section(header: Text("Diğer Ayarlar")) {
                        NavigationLink(destination: WalletSettingsView()) {
                            SettingsRow(icon: "wallet.pass.fill", color: .black, title: "Cüzdan")
                        }

                        NavigationLink(destination: iCloudSettingsView()) {
                            SettingsRow(icon: "icloud.fill", color: .blue, title: "iCloud")
                        }
                    }

                    // Çıkış Yap Butonu
                    Section {
                        Button(action: {
                            do {
                                try Auth.auth().signOut()
                            } catch {
                                print("Çıkış hatası: \(error.localizedDescription)")
                            }
                        }) {
                            HStack {
                                Image(systemName: "arrow.right.circle.fill")
                                    .foregroundColor(.red)
                                Text("Çıkış Yap")
                                    .foregroundColor(.red)
                                    .font(.headline)
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .navigationTitle("Genel Ayarlar")
                .onAppear {
                    fetchUserData()
                    applyTheme()
                    trackTime()
                }
            }
        }
    }

    func fetchUserData() {
        guard let currentUser = currentUser else { return }
        db.collection("users").whereField("email", isEqualTo: currentUser.email ?? "").getDocuments { snapshot, error in
            if let error = error {
                print("Hata: \(error.localizedDescription)")
                return
            }

            if let snapshot = snapshot, !snapshot.isEmpty {
                if let document = snapshot.documents.first {
                    let data = document.data()
                    DispatchQueue.main.async {
                        self.username = data["username"] as? String ?? "Bilinmiyor"
                        self.email = data["email"] as? String ?? "Bilinmiyor"
                        print("Kullanıcı verisi çekildi: \(self.username), \(self.email)")
                    }
                }
            }
        }
    }


    func updateAppTheme(_ theme: String) {
        if theme == "Dark" {
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .dark
        } else {
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .light
        }
    }

    func applyTheme() {
        if selectedTheme == "Dark" {
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .dark
        } else {
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .light
        }
    }

    // Ekran süresi sayaç
    func trackTime() {
        guard let currentUser = currentUser else { return }
        let userRef = db.collection("users").document(currentUser.uid)
        userRef.updateData([
            "time": FieldValue.increment(Int64(1))
        ]) { error in
            if let error = error {
                print("Zaman güncelleme hatası: \(error.localizedDescription)")
            } else {
                print("Zaman güncellendi.")
            }
        }
    }
}

struct SettingsRow: View {
    var icon: String
    var color: Color
    var title: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.white)
                .frame(width: 30, height: 30)
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: 6))
            Text(title)
                .font(.system(size: 16, weight: .regular))
        }
    }
}

struct NotificationSettingsView: View {
    var body: some View {
        Text("Bildirimler Ayarları")
    }
}

struct SoundAndTouchSettingsView: View {
    @State private var selectedSound: String = "system"

    var body: some View {
        VStack {
            Text("Bildirim Sesi Seçimi")
            Picker("Ses", selection: $selectedSound) {
                Text("Sistem Sesi").tag("system")
                Text("Ses 1").tag("sound1")
                Text("Ses 2").tag("sound2")
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
}

struct ScreenTimeSettingsView: View {
    @Binding var timeSpent: Int
    @State private var timer: Timer?
    @State private var isTracking = false
    @State private var isLoggedIn = false
    private var db = Firestore.firestore()
    
    // Firebase authentication check
    init(timeSpent: Binding<Int>) {
        _timeSpent = timeSpent
    }

    var body: some View {
        VStack {
            // Başlık
            Text("Ekran Süresi")
                .font(.largeTitle)
                .bold()
                .padding(.top, 20)

            // Kullanıcının ekran süresini göster
            Text("Bu ekranı kullanma süreniz: \(timeSpent) dakika")
                .font(.title)
                .padding()

            // Sayaç görünümü
            ProgressView(value: Double(timeSpent), total: 60)
                .progressViewStyle(LinearProgressViewStyle())
                .padding(.top, 20)
                .accentColor(.blue)
            
            // Sayaç ilerledikçe renk değişir
            Circle()
                .trim(from: 0, to: CGFloat(min(Double(timeSpent) / 60.0, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .foregroundColor(.blue)
                .frame(width: 150, height: 150)
                .rotationEffect(Angle(degrees: -90))
                .padding(.top, 40)
                .animation(.linear(duration: 1), value: timeSpent)

            Spacer()
            
        }
        .padding()
        .onAppear {
            // Kullanıcı giriş kontrolü ve sayaç başlatma
            checkUserLogin()
        }
        .onDisappear {
            self.stopTracking()
        }
    }

    // Kullanıcı girişi kontrolü ve sayaç başlatma
    func checkUserLogin() {
        guard let currentUser = Auth.auth().currentUser else {
            print("Kullanıcı giriş yapmamış.")
            return
        }
        
        self.isLoggedIn = true
        self.startTracking() // Kullanıcı giriş yaptıysa sayaç başlar
        
        // Firebase'ten kullanıcı ekran süresi verisini al
        loadTimeSpentFromFirebase()
    }
    
    // Ekran süresi takibini başlat
    func startTracking() {
        self.isTracking = true
        self.timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            self.timeSpent += 1
            self.saveTimeSpent()
        }
    }

    // Ekran süresi takibini durdur
    func stopTracking() {
        self.isTracking = false
        self.timer?.invalidate()
        self.timer = nil
    }

    // Firebase'e ekran süresi verilerini kaydet
    func saveTimeSpent() {
        guard let currentUser = Auth.auth().currentUser else { return }

        db.collection("users").document(currentUser.uid).updateData([
            "time": timeSpent
        ]) { error in
            if let error = error {
                print("Ekran süresi kaydedilemedi: \(error.localizedDescription)")
            } else {
                print("Ekran süresi başarıyla kaydedildi: \(self.timeSpent) dakika")
            }
        }
    }

    // Firebase'ten kullanıcı ekran süresi verisini al
    func loadTimeSpentFromFirebase() {
        guard let currentUser = Auth.auth().currentUser else { return }

        db.collection("users").document(currentUser.uid).getDocument { document, error in
            if let document = document, document.exists {
                if let time = document.data()?["time"] as? Int {
                    self.timeSpent = time
                }
            } else {
                print("Ekran süresi verisi alınamadı: \(error?.localizedDescription ?? "Bilinmeyen hata")")
            }
        }
    }
}
struct FaceIDSettingsView: View {
    var body: some View {
        Text("Face ID ve Parola Ayarları")
    }
}

struct PrivacyAndSecuritySettingsView: View {
   
    @Binding var isKVKKAccepted: Bool
    @State private var isShowingText = false
    var body: some View {
           VStack {
               Button(action: {
                   withAnimation {
                       isShowingText.toggle()
                   }
               }) {
                   HStack {
                       Text(isShowingText ? "Metni Kapat" : "KVKK Metnini Görüntüle")
                           .font(.headline)
                           .foregroundColor(.blue)
                       Image(systemName: isShowingText ? "chevron.up" : "chevron.down")
                           .foregroundColor(.blue)
                   }
                   .padding()
               }

               if isShowingText {
                   VStack {
                       Text("KVKK Metni: Lütfen kişisel verilerinizin korunması hakkında bilgi alın. Verilerinizin toplama, işleme ve saklama işlemleri hakkında detaylı bilgiye buradan ulaşabilirsiniz. Bu onay, kişisel verilerinizin güvenliğini sağlamayı hedefler.")
                           .font(.body)
                           .padding()
                           .frame(maxWidth: .infinity, alignment: .leading)
                           .background(Color.gray.opacity(0.1))
                           .cornerRadius(10)

                       Button("KVKK Onayla") {
                           withAnimation {
                               isKVKKAccepted = true
                           }
                       }
                       .padding()
                       .background(Color.blue)
                       .foregroundColor(.white)
                       .cornerRadius(8)
                       .padding(.top, 10)

                       if isKVKKAccepted {
                           Text("KVKK Onaylandı! Gizlilik Ayarlarına Yönlendiriliyorsunuz...")
                               .font(.headline)
                               .foregroundColor(.green)
                               .padding(.top, 10)
                       }
                   }
                   .transition(.move(edge: .bottom))
               }
           }
           .padding()
           .navigationBarTitle("Gizlilik ve Güvenlik", displayMode: .inline)
       }
}

struct WalletSettingsView: View {
    var body: some View {
        Text("Cüzdan Ayarları")
    }
}

struct iCloudSettingsView: View {
    var body: some View {
        Link("iCloud'a Git", destination: URL(string: "https://www.apple.com/icloud/")!)
    }
}

struct SettingTabView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsTabView()
    }
}

