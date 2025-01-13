import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct ProfileTabView: View {
    @State private var user: FirebaseAuth.User?
    @State private var email: String = ""
    @State private var username: String = ""
    @State private var aboutMe: String = "Hakkında bilgi yok"
    @State private var profileImageUrl: String = ""
    @State private var isLoading: Bool = true
    @State private var errorMessage: String = ""
    @State private var newPassword: String = ""
    @State private var currentPassword: String = ""
    @State private var verificationCode: String = ""
    @State private var showVerificationField: Bool = false
    @State private var isImagePickerPresented: Bool = false
    @State private var selectedImage: UIImage? = nil
    @State private var isPhoneNumberUpdatePresented: Bool = false
    @State private var newPhoneNumber: String = ""
    
    @State private var isPasswordChangePresented = false // For password change modal
    @State private var isMenuVisible = false // To control menu visibility

    var body: some View {
        ZStack {
            // Main content
            ScrollView {
                VStack {
                    if isLoading {
                        ProgressView("Yükleniyor...")
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        HStack {
                            if let url = URL(string: profileImageUrl), !profileImageUrl.isEmpty {
                                AsyncImage(url: url) { image in
                                    image.resizable()
                                        .scaledToFill()
                                        .clipShape(Circle())
                                        .frame(width: 100, height: 100)
                                } placeholder: {
                                    Circle().fill(Color.gray)
                                        .frame(width: 100, height: 100)
                                }
                            } else {
                                Circle().fill(Color.blue)
                                    .frame(width: 100, height: 100)
                                    .overlay(
                                        Text(username.prefix(1)) // Kullanıcı adının ilk harfi
                                            .font(.system(size: 40, weight: .bold))
                                            .foregroundColor(.white)
                                    )
                            }
                            
                            Button(action: {
                                isImagePickerPresented.toggle()
                            }) {
                                Image(systemName: "pencil.circle.fill")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.blue)
                                    .padding(.leading, 10)
                            }
                        }

                        Text(username.isEmpty ? "Kullanıcı adı yok" : username)
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.top)

                        Text(email)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.top, 2)

                        Text("Hakkında")
                            .font(.headline)
                            .padding(.top, 20)
                        
                        Text(aboutMe)
                            .font(.body)
                            .padding(.top, 10)
                        
                        Spacer()
                    }
                }
                .onAppear {
                    fetchUserData()
                }
                .padding()
                .sheet(isPresented: $isImagePickerPresented) {
                    ImagePicker(isImagePickerPresented: $isImagePickerPresented, selectedImage: $selectedImage)
                }
                .sheet(isPresented: $isPhoneNumberUpdatePresented) {
                    PhoneNumberUpdateView(newPhoneNumber: $newPhoneNumber, isPresented: $isPhoneNumberUpdatePresented)
                }
                .sheet(isPresented: $isPasswordChangePresented) {
                    PasswordChangeView(isPresented: $isPasswordChangePresented, newPassword: $newPassword)
                }
            }
            
            // Menu overlay
            if isMenuVisible {
                Color.black.opacity(0.4) // Semi-transparent background
                    .ignoresSafeArea()
                    .onTapGesture {
                        isMenuVisible = false // Close menu when tapping outside
                    }
            }
            
            VStack {
                           Spacer()
                           HStack {
                               Spacer()
                               VStack {
                                   Button(action: {
                                       withAnimation {
                                           isMenuVisible.toggle()
                                       }
                                   }) {
                                       Image(systemName: isMenuVisible ? "xmark" : "line.horizontal.3")
                                           .resizable()
                                           .frame(width: 40, height: 40)
                                           .padding(10)
                                           .background(Color.blue)
                                           .clipShape(Circle())
                                           .foregroundColor(.white)
                                   }
                                   
                                   if isMenuVisible {
                                       VStack(spacing: 15) {
                                           Button(action: {
                                               isPhoneNumberUpdatePresented.toggle()
                                               isMenuVisible = false // Close menu after selection
                                           }) {
                                               Text("Telefon Numarası Güncelle")
                                                   .foregroundColor(.blue)
                                                   .padding()
                                                   .frame(maxWidth: .infinity)
                                                   .background(Color.white)
                                                   .cornerRadius(10)
                                           }
                                           Button(action: {
                                               isPasswordChangePresented.toggle()
                                               isMenuVisible = false // Close menu after selection
                                           }) {
                                               Text("Şifreyi Değiştir")
                                                   .foregroundColor(.blue)
                                                   .padding()
                                                   .frame(maxWidth: .infinity)
                                                   .background(Color.white)
                                                   .cornerRadius(10)
                                           }
                                       }
                                       .padding()
                                       .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                                       .shadow(radius: 10)
                                       .padding(.bottom, 60)
                                   }
                               }
                               .padding()
                           }
                       }
                   }
               }
    
    func fetchUserData() {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "Kullanıcı giriş yapmamış."
            isLoading = false
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.uid)
        
        userRef.getDocument { document, error in
            if let error = error {
                errorMessage = "Hata: \(error.localizedDescription)"
                isLoading = false
                return
            }
            
            if let document = document, document.exists {
                if let data = document.data() {
                    self.email = data["email"] as? String ?? "E-posta yok"
                    self.username = data["username"] as? String ?? ""
                    self.aboutMe = data["aboutMe"] as? String ?? "Hakkında bilgi yok"
                    self.profileImageUrl = data["profileImage"] as? String ?? ""
                }
            } else {
                errorMessage = "Kullanıcı verisi bulunamadı."
            }
            isLoading = false
        }
    }
}

struct PhoneNumberUpdateView: View {
    @Binding var newPhoneNumber: String
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            Text("Yeni Telefon Numarası")
                .font(.headline)
                .padding(.top)
            
            TextField("Telefon Numarası", text: $newPhoneNumber)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.vertical)
            
            Button(action: {
                // Telefon numarasını güncelleme işlemini burada yap
                isPresented = false
            }) {
                Text("Telefon Numarasını Güncelle")
                    .font(.body)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                    .frame(maxWidth: .infinity)
            }
            .padding(.top, 10)
        }
        .padding()
    }
}

struct PasswordChangeView: View {
    @Binding var isPresented: Bool
    @Binding var newPassword: String
    
    @State private var currentPassword: String = ""
    @State private var confirmationPassword: String = ""
    @State private var errorMessage: String = ""

    var body: some View {
        VStack {
            Text("Şifre Değiştir")
                .font(.headline)
                .padding(.top)
            
            SecureField("Mevcut Şifre", text: $currentPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.vertical)
            
            SecureField("Yeni Şifre", text: $newPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.vertical)
            
            SecureField("Yeni Şifreyi Onayla", text: $confirmationPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.vertical)
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.top, 10)
            }

            Button(action: {
                changePassword()
            }) {
                Text("Şifreyi Değiştir")
                    .font(.body)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                    .frame(maxWidth: .infinity)
            }
            .padding(.top, 10)
        }
        .padding()
    }
    
    private func changePassword() {
        guard !currentPassword.isEmpty, !newPassword.isEmpty, !confirmationPassword.isEmpty else {
            errorMessage = "Tüm alanları doldurduğunuzdan emin olun."
            return
        }
        
        if newPassword != confirmationPassword {
            errorMessage = "Yeni şifreler eşleşmiyor."
            return
        }
        
        // Re-authenticate user to change password
        guard let user = Auth.auth().currentUser else {
            errorMessage = "Kullanıcı oturum açmamış."
            return
        }
        
        let credential = EmailAuthProvider.credential(withEmail: user.email!, password: currentPassword)
        
        user.reauthenticate(with: credential) { result, error in
            if let error = error {
                errorMessage = "Mevcut şifre yanlış: \(error.localizedDescription)"
                return
            }
            
            // Update password
            user.updatePassword(to: newPassword) { error in
                if let error = error {
                    errorMessage = "Şifre değiştirilemedi: \(error.localizedDescription)"
                } else {
                    isPresented = false
                    errorMessage = ""
                }
            }
        }
    }
}

struct ProfileTabView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileTabView()
    }
}


