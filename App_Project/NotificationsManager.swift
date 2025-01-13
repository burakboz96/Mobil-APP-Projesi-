import SwiftUI
import Firebase

class NotificationManager: ObservableObject {
    static let shared = NotificationManager() // Singleton design
    
    @Published var notifications: [String] = [] // Aktif bildirimler
    @Published var deletedNotifications: [String] = [] // Silinmiş bildirimler

    private init() {
        configureFirebase() // Firebase'i yapılandır
        observeNotifications() // Bildirimleri dinlemeye başla
    }

    // Firebase yapılandırması
    private func configureFirebase() {
        FirebaseApp.configure()
    }

    // Firebase'deki bildirimleri dinle
    private func observeNotifications() {
        let db = Firestore.firestore()
        db.collection("notifications").addSnapshotListener { snapshot, error in
            guard let documents = snapshot?.documents, error == nil else {
                print("Bildirimler yüklenemedi: \(error?.localizedDescription ?? "Bilinmeyen hata")")
                return
            }

            DispatchQueue.main.async {
                self.notifications = documents.compactMap { doc in
                    return doc.data()["message"] as? String
                }
            }
        }
    }

    // Bildirim ekleme
    func addNotification(notification: String) {
        let db = Firestore.firestore()
        db.collection("notifications").addDocument(data: ["message": notification]) { error in
            if let error = error {
                print("Bildirim eklenirken hata oluştu: \(error.localizedDescription)")
            }
        }
    }

    // Kullanıcı olaylarını işleme
    func userLoggedIn() {
        addNotification(notification: "Başarıyla giriş yapıldı.")
    }

    func userLoggedOut() {
        addNotification(notification: "Çıkış işlemi başarıyla yapıldı.")
    }

    func passwordChanged() {
        addNotification(notification: "Şifreniz başarıyla değiştirildi.")
    }

    // Bildirim silme
    func deleteNotification(notification: String) {
        let db = Firestore.firestore()
        db.collection("notifications").whereField("message", isEqualTo: notification).getDocuments { snapshot, error in
            guard let documents = snapshot?.documents, error == nil else {
                print("Silinecek bildirim bulunamadı: \(error?.localizedDescription ?? "Bilinmeyen hata")")
                return
            }

            for document in documents {
                document.reference.delete { error in
                    if let error = error {
                        print("Bildirim silinirken hata oluştu: \(error.localizedDescription)")
                    } else {
                        DispatchQueue.main.async {
                            self.notifications.removeAll { $0 == notification }
                            self.deletedNotifications.append(notification)
                        }
                    }
                }
            }
        }
    }

    // Bildirimi geri yükleme
    func restoreNotification(notification: String) {
        if let index = deletedNotifications.firstIndex(of: notification) {
            let restoredNotification = deletedNotifications.remove(at: index)
            addNotification(notification: restoredNotification)
        }
    }

    // Hoş geldiniz mesajı
    func showWelcomeMessage() -> String {
        return "Hoş Geldiniz!"
    }
}

