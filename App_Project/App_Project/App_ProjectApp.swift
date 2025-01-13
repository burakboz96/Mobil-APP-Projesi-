import SwiftUI
import Firebase

@main
struct App_ProjectApp: App {
    
    // AppDelegate'i burada bağlıyoruz
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            SplashScreen(logoImageName: "renova_logo")  // SplashScreen'i başlatıyoruz
        }
    }
}

// Firebase'i başlatmak için AppDelegate'de Firebase'i import et ve yapılandır


