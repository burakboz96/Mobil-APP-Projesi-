import SwiftUI
import Firebase
import FirebaseFirestore

struct ProfileView: View {
    @State private var userEmail: String = "Yükleniyor..."
    @State private var userName: String = "Yükleniyor..."
    @State private var aboutMe: String = "Yükleniyor..."
    @State private var isLoading: Bool = true // Yükleniyor durumu
    
    var body: some View {
        VStack {
            // Üst Mavi Alan (Profil Resmi)
            ZStack {
                Color.blue // Mavi arka plan
                    .frame(height: UIScreen.main.bounds.height / 2) // Ekranın yarısı kadar yükseklik
                
                VStack {
                    Image(systemName: "person.circle.fill") // Profil resmi simgesi
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.white) // Beyaz renk
                        .padding(.top, 50) // Üstten boşluk
                    Text(userName) // Kullanıcı adı
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white) // Beyaz renk
                    Text(userEmail) // Kullanıcı e-posta
                        .font(.body)
                        .foregroundColor(.white) // Beyaz renk
                    Spacer()
                }
            }
            
            // Alt Kısım: Profil Bilgileri ve Hakkımda
            ZStack {
                Color.white // Arka plan beyaz
                VStack(alignment: .leading, spacing: 20) {
                    Divider()
                    Text("Hakkımda:")
                        .font(.headline)
                        .padding(.top, 20)
                    
                    Text(aboutMe)
                        .font(.body)
                        .foregroundColor(.gray)
                        .padding(.bottom, 20)
                    
                    Divider()
                }
                .padding()
                .background(Color.white) // Beyaz arka plan
                .cornerRadius(25) // Köşe yuvarlama
                .shadow(radius: 10) // Gölgelendirme
            }
            .padding(.top, -40) // Mavi alanla birleşmesi için yukarı kaydır
        }
        .edgesIgnoringSafeArea(.top) // Üst alanın taşması için
        .onAppear {
            fetchUserData() // Firebase verisini çek
        }
    }
    
    // Firebase'den kullanıcı verilerini çekme
    func fetchUserData() {
        guard let user = Auth.auth().currentUser else {
            print("Kullanıcı oturum açmamış.")
            return
        }
        
        // Kullanıcı e-postasını al
        userEmail = user.email ?? "E-posta bulunamadı"
        
        // Firestore'dan kullanıcı bilgilerini al
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).getDocument { (document, error) in
            if let error = error {
                print("Veri alma hatası: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists {
                let data = document.data()
                self.userName = data?["name"] as? String ?? "Ad yok"
                self.aboutMe = data?["aboutMe"] as? String ?? "Hakkımda bilgisi yok"
            } else {
                print("Belge bulunamadı.")
            }
            
            // Yüklenme durumunu kaldır
            self.isLoading = false
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}

