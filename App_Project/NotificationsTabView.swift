import SwiftUI
import Firebase
import FirebaseMessaging

class NotificationsManager: NSObject, ObservableObject, MessagingDelegate, UNUserNotificationCenterDelegate {
    static let shared = NotificationsManager()

    @Published var notifications: [String] = [] // Aktif bildirimler listesi
    @Published var deletedNotifications: [String] = [] // Silinen bildirimler (çöp kutusu)

    private override init() {
        super.init()
        setupFirebaseMessaging()
    }

    func setupFirebaseMessaging() {
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self

        // Bildirim izinlerini al
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Bildirim izni alınamadı: \(error.localizedDescription)")
            }
        }

        // FCM Token al
        Messaging.messaging().token { token, error in
            if let error = error {
                print("FCM Token alınamadı: \(error.localizedDescription)")
            } else if let token = token {
                print("FCM Token: \(token)")
            }
        }
    }

    func addNotification(_ message: String) {
        DispatchQueue.main.async {
            self.notifications.append(message)
        }
    }

    func deleteNotification(at index: Int) {
        DispatchQueue.main.async {
            let deletedNotification = self.notifications.remove(at: index)
            self.deletedNotifications.append(deletedNotification)
        }
    }

    func restoreNotification(at index: Int) {
        DispatchQueue.main.async {
            let restoredNotification = self.deletedNotifications.remove(at: index)
            self.notifications.append(restoredNotification)
        }
    }

    // Firebase Messaging Delegate method
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase Registration Token: \(fcmToken ?? "Yok")")
    }

    // UNUserNotificationCenter Delegate method
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        let message = notification.request.content.body
        addNotification(message)
        return [.banner, .sound]
    }
}

struct NotificationsTabView: View {
    @ObservedObject var notificationManager = NotificationsManager.shared
    @State private var showTrash = false

    var body: some View {
        NavigationView {
            VStack {
                // Başlık
                Text("Bildirimler")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color.blue)
                    .padding(.top, 40)

                // Bildirim Listesi
                ScrollView {
                    if notificationManager.notifications.isEmpty {
                        Text("Henüz bildirim yok")
                            .font(.body)
                            .foregroundColor(Color.gray)
                            .italic()
                            .padding(.top, 20)
                    } else {
                        ForEach(Array(notificationManager.notifications.enumerated()), id: \.offset) { index, notification in
                            HStack {
                                NotificationItemView(notificationText: notification)
                                Button(action: {
                                    notificationManager.deleteNotification(at: index)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                }
                .padding()

                Spacer()

                // Çöp Kutusu Butonu
                Button(action: {
                    showTrash.toggle()
                }) {
                    Label("Çöp Kutusu", systemImage: "trash.fill")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                }
                .padding(.bottom, 20)
            }
            .sheet(isPresented: $showTrash) {
                TrashBinView()
            }
            .navigationBarHidden(true)
        }
    }
}

struct NotificationItemView: View {
    var notificationText: String

    var body: some View {
        HStack {
            Image(systemName: "bell.fill")
                .foregroundColor(Color.blue)

            Text(notificationText)
                .font(.body)
                .foregroundColor(Color.black)

            Spacer()
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
        .shadow(radius: 5)
    }
}

struct TrashBinView: View {
    @ObservedObject var notificationManager = NotificationsManager.shared

    var body: some View {
        VStack {
            Text("Çöp Kutusu")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 20)

            ScrollView {
                if notificationManager.deletedNotifications.isEmpty {
                    Text("Çöp kutusu boş")
                        .font(.body)
                        .foregroundColor(Color.gray)
                        .italic()
                        .padding(.top, 20)
                } else {
                    ForEach(Array(notificationManager.deletedNotifications.enumerated()), id: \.offset) { index, notification in
                        HStack {
                            NotificationItemView(notificationText: notification)
                            Button(action: {
                                notificationManager.restoreNotification(at: index)
                            }) {
                                Image(systemName: "arrow.uturn.backward")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
}

struct NotificationsTabView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsTabView()
    }
}

