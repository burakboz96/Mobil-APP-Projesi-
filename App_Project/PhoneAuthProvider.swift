import FirebaseAuth

class PhoneAuthProviderHelper {
    
    // Telefon numarasına doğrulama kodu göndermek için fonksiyon
    static func sendVerificationCode(to phoneNumber: String, completion: @escaping (Bool, String?) -> Void) {
        // Phone number format kontrolü yapın
        let formattedPhoneNumber = "+90" + phoneNumber // Ülke kodunu ve numarayı doğru formatta birleştirme (örneğin: +90 555 555 55 55)
        
        PhoneAuthProvider.provider().verifyPhoneNumber(formattedPhoneNumber, uiDelegate: nil) { (verificationID, error) in
            if let error = error {
                // Hata meydana geldi
                print("Error during phone number verification: \(error.localizedDescription)")
                completion(false, error.localizedDescription)
                return
            }
            
            // Doğrulama ID'sini kullanıcıda saklayın
            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
            print("Verification ID sent successfully.")
            completion(true, nil)
        }
    }
    
    // Kullanıcının girdiği doğrulama kodu ile kimlik doğrulaması yapmak
    static func verifyCode(_ code: String, completion: @escaping (Bool, String?) -> Void) {
        // UserDefaults'dan verificationID'yi al
        guard let verificationID = UserDefaults.standard.string(forKey: "authVerificationID") else {
            print("Verification ID not found.")
            completion(false, "Verification ID not found.")
            return
        }
        
        // Doğrulama işlemini yap
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: code)
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                // Hata durumunu yönet
                print("Error during sign-in: \(error.localizedDescription)")
                completion(false, error.localizedDescription)
                return
            }
            
            // Başarılı giriş yapıldığında
            print("User successfully signed in.")
            completion(true, nil)
        }
    }
    
    // Şifre sıfırlama işlemi için
    static func sendPasswordResetEmail(to email: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if let error = error {
                print("Error sending password reset email: \(error.localizedDescription)")
                completion(false, error.localizedDescription)
                return
            }
            
            print("Password reset email sent successfully.")
            completion(true, nil)
        }
    }
}

