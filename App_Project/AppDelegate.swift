import UIKit
import Firebase
import UserNotifications
import FirebaseMessaging
import Network

class AppDelegate: UIResponder, UIApplicationDelegate {

    private var noInternetAlert: UIAlertController?
    private var hasInternet: Bool = true // Uygulama başlangıcında internet durumunu kontrol etmek için

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Firebase'i yalnızca bir kez yapılandırıyoruz
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }

        // Bildirim izinlerini istiyoruz
        requestNotificationPermission(application)

        // Firebase Messaging ayarlarını yapılandırıyoruz
        Messaging.messaging().delegate = self

        // İnternet bağlantısını izlemek için NetworkManager'ı başlatıyoruz
        AppNetworkManager.shared.startMonitoring()

        // İnternet bağlantısı durumu değiştiğinde bildirim göndermek
        NotificationCenter.default.addObserver(self, selector: #selector(handleNoInternet), name: .appNoInternetConnection, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleInternetRestored), name: .appInternetConnectionRestored, object: nil)

        // Uygulama başlangıcında internet kontrolü
        if !AppNetworkManager.shared.isConnected {
            hasInternet = false
            showSplashScreenError()
        }

        return true
    }

    func requestNotificationPermission(_ application: UIApplication) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] granted, error in
            guard let self = self else { return }

            DispatchQueue.main.async {
                if granted {
                    print("Bildirim izni verildi.")
                    application.registerForRemoteNotifications()
                } else {
                    print("Bildirim izni reddedildi.")
                }
            }
        }
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Bildirim kaydı başarısız oldu: \(error.localizedDescription)")
    }

    @objc func handleNoInternet() {
        DispatchQueue.main.async {
            self.showNoInternetAlert()
        }
    }

    @objc func handleInternetRestored() {
        DispatchQueue.main.async {
            self.dismissNoInternetAlert()
        }
    }

    func showNoInternetAlert() {
        guard noInternetAlert == nil else { return }

        if let window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first {
            noInternetAlert = UIAlertController(title: "İnternet Bağlantısı Hatası ",
                                                message: "İnternet bağlantınız kesildi. Lütfen bir ağa bağlanın.",
                                                preferredStyle: .alert)
            noInternetAlert?.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
            
            DispatchQueue.main.async {
                window.rootViewController?.present(self.noInternetAlert!, animated: true, completion: nil)
            }
        }
    }

    func dismissNoInternetAlert() {
        DispatchQueue.main.async {
            self.noInternetAlert?.dismiss(animated: true, completion: nil)
            self.noInternetAlert = nil
        }
    }

    func showSplashScreenError() {
        if let window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first {
            let alert = UIAlertController(title: "Hata",
                                          message: "İnternet bağlantısı yok. Lütfen bir ağa bağlanın.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: { _ in
                exit(0) // Uygulama çıkış yapıyor
            }))
            
            DispatchQueue.main.async {
                window.rootViewController?.present(alert, animated: true, completion: nil)
            }
        }
    }
}

extension AppDelegate: MessagingDelegate {

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("FCM token: \(String(describing: fcmToken))")
    }
}

// Network Manager sınıfı
class AppNetworkManager {
    static let shared = AppNetworkManager()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "AppNetworkMonitor")
    var isConnected: Bool = false

    func startMonitoring() {
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                self.isConnected = true
                NotificationCenter.default.post(name: .appInternetConnectionRestored, object: nil)
            } else {
                self.isConnected = false
                NotificationCenter.default.post(name: .appNoInternetConnection, object: nil)
            }
        }
        monitor.start(queue: queue)
    }

    func stopMonitoring() {
        monitor.cancel()
    }
}

extension Notification.Name {
    static let appNoInternetConnection = Notification.Name("appNoInternetConnection")
    static let appInternetConnectionRestored = Notification.Name("appInternetConnectionRestored")
}

