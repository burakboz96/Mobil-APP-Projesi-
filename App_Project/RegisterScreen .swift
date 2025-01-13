import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct RegisterScreen: View {
    @State private var username = "" // Kullanıcı adı
    @State private var email = "" // E-posta
    @State private var password = "" // Şifre
    @State private var confirmPassword = "" // Şifreyi onayla
    @State private var phoneNumber = "" // Telefon numarası
    @State private var isRegistering = false // Kayıt işlemi sürecini kontrol eder
    @State private var errorMessage = "" // Hata mesajı
    @State private var showIcon = false // İkonu göstermek için
    @State private var iconColor = Color.green // Başarı durumunda yeşil, hata durumunda kırmızı
    @State private var showErrorIcon = false // Hata ikonunu göster
    @State private var navigateToLogin = false // Başarıyla kayıt olduktan sonra login ekranına geçiş için

    // Firestore reference
    private let db = Firestore.firestore()

    var body: some View {
        NavigationView {
            VStack {
                Text("Kayıt Ol")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()

                // Kullanıcı adı TextField
                TextField("Kullanıcı Adı", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                // E-posta TextField
                TextField("E-posta", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .padding()

                // Telefon numarası TextField
                TextField("Telefon Numarası", text: $phoneNumber)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.phonePad)
                    .padding()

                // Şifre TextField
                SecureField("Şifre", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                // Şifreyi onayla TextField
                SecureField("Şifreyi Onayla", text: $confirmPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                // Hata mesajı
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }

                // Kayıt Ol butonu
                Button(action: {
                    // Kayıt işlemi
                    registerUser()
                }) {
                    Text(isRegistering ? "Kaydoluyor..." : "Kayıt Ol")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
                .disabled(isRegistering) // Kayıt işlemi sırasında butonu devre dışı bırak

                // Tik veya çarpı ikonunu göstermek için animasyon
                if showIcon {
                    Circle()
                        .fill(iconColor)
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: showErrorIcon ? "xmark" : "checkmark")
                                .font(.system(size: 50))
                                .foregroundColor(.white)
                        )
                        .scaleEffect(showIcon ? 1.2 : 0.8)
                        .opacity(showIcon ? 1 : 0)
                        .animation(.easeInOut(duration: 0.6), value: showIcon)
                        .onAppear {
                            // 2 saniye sonra animasyonu bitir
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    showIcon = false
                                }
                            }
                        }
                }

                Spacer()

                // Login ekranına yönlendirme
                NavigationLink(
                    destination: LoginScreen(), // LoginScreen'e yönlendirme
                    isActive: $navigateToLogin, // navigateToLogin state'ine göre geçiş
                    label: { EmptyView() } // Görünür bir şey göstermemek için boş bir görünüm
                )
            }
            .padding()
            .background(navigateToLogin ? Color.white : Color.clear) // Yönlendirme ekranında beyaz arka plan
        }
    }

    func registerUser() {
        // Kayıt işlemi başlamadan önce hata kontrolü yapalım
        guard !username.isEmpty, !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty, !phoneNumber.isEmpty else {
            errorMessage = "Tüm alanları doldurduğunuzdan emin olun."
            return
        }

        guard password == confirmPassword else {
            errorMessage = "Şifreler eşleşmiyor."
            return
        }

        isRegistering = true // Kayıt işlemi başlıyor
        errorMessage = "" // Hata mesajını temizle
        showIcon = false // İkonu gizle
        showErrorIcon = false

        // Firebase ile kullanıcı kaydı
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            isRegistering = false // Kayıt işlemi bitti
            
            if let error = error {
                // Hata mesajını göster
                errorMessage = error.localizedDescription
                iconColor = .red
                showErrorIcon = true
                showIcon = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    showIcon = false
                }
            } else {
                // Kullanıcı başarıyla kaydedildi, Firestore'a kullanıcı bilgilerini ekleyelim
                if let user = result?.user {
                    let userData: [String: Any] = [
                        "username": self.username,   // Kullanıcı adı
                        "email": self.email,         // E-posta
                        "phoneNumber": self.phoneNumber, // Telefon numarası
                        "uid": user.uid,             // Firebase UID (Benzersiz kimlik)
                        "createdAt": Timestamp()     // Kullanıcı oluşturulma tarihi
                    ]

                    // Firestore'da users koleksiyonuna verileri ekleyelim
                    self.db.collection("users").document(user.uid).setData(userData) { error in
                        if let error = error {
                            // Firestore kaydı sırasında hata oluşursa
                            self.errorMessage = "Veri kaydedilirken hata oluştu: \(error.localizedDescription)"
                            iconColor = .red
                            showErrorIcon = true
                            showIcon = true
                        } else {
                            // Kullanıcı başarıyla kaydedildi
                            iconColor = .green
                            showErrorIcon = false
                            showIcon = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showIcon = false
                                // Başarılı kayıttan sonra giriş ekranına yönlendirme yapılır
                                navigateToLogin = true
                            }
                            print("Kullanıcı başarıyla kaydedildi!")
                        }
                    }
                }
            }
        }
    }
}

struct RegisterScreen_Previews: PreviewProvider {
    static var previews: some View {
        RegisterScreen()
    }
}

