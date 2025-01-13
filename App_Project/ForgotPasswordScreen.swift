import SwiftUI
import FirebaseAuth

struct ForgotPasswordScreen: View {
    @State private var email: String = ""
    @State private var phoneNumber: String = ""
    @State private var isUsingPhone: Bool = false
    @State private var errorMessage: String? = nil
    @State private var isLoading: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Şifre Sıfırla")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.black)

            Text("Lütfen şifrenizi sıfırlamak için e-posta adresinizi veya telefon numaranızı girin.")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding()

            Toggle(isOn: $isUsingPhone) {
                Text("Telefon numarası ile sıfırlama")
                    .foregroundColor(.black)
            }
            .padding()

            if isUsingPhone {
                TextField("Telefon Numarası", text: $phoneNumber)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .keyboardType(.phonePad)
                    .foregroundColor(.black)
            } else {
                TextField("E-posta", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .foregroundColor(.black)
            }

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            Button(action: {
                resetPassword()
            }) {
                Text("Şifre Sıfırlama Bağlantısı Gönder")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }

            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding()
    }

    func resetPassword() {
        if isUsingPhone {
            guard !phoneNumber.isEmpty else {
                errorMessage = "Lütfen telefon numaranızı girin."
                return
            }

            isLoading = true
            errorMessage = nil

            // Phone number verification will depend on your Firebase setup.
            PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
                isLoading = false

                if let error = error {
                    errorMessage = "Telefon numarası doğrulama başarısız: \(error.localizedDescription)"
                } else if let verificationID = verificationID {
                    // You would prompt the user for the SMS code and verify the phone number with the verificationID.
                    // This step is needed before resetting the password.
                    errorMessage = "Bir doğrulama kodu gönderildi. Lütfen doğrulama kodunu girin."
                    // Proceed with resetting password once the phone is verified.
                }
            }
        } else {
            guard !email.isEmpty else {
                errorMessage = "Lütfen e-posta adresinizi girin."
                return
            }

            guard isValidEmail(email) else {
                errorMessage = "Geçersiz e-posta adresi."
                return
            }

            isLoading = true
            errorMessage = nil

            Auth.auth().sendPasswordReset(withEmail: email) { error in
                isLoading = false

                if let error = error {
                    errorMessage = "Şifre sıfırlama başarısız: \(error.localizedDescription)"
                } else {
                    errorMessage = "Şifre sıfırlama bağlantısı e-posta adresinize gönderildi."
                }
            }
        }
    }

    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z.-_%]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
}

private struct PrivacyPolicyView: View {
    var body: some View {
        VStack {
            Text("Gizlilik Politikası")
                .font(.title)
                .fontWeight(.bold)
                .padding()

            Text("Burada, uygulamanın gizlilik politikası hakkında bilgi verilecektir.")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding()

            Button(action: {
                // Add action for accepting privacy policy
            }) {
                Text("Gizlilik Politikasını Kabul Et")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(10)
            }
            .padding()
        }
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding()
    }
}



struct ForgotPasswordScreen_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordScreen()
    }
}
