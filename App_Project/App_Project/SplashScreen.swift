import SwiftUI
import Firebase


struct App_Project: App {
    
    init() {
        AppCheck.setAppCheckProviderFactory(nil)

        // Firebase uygulamasını başlatıyoruz
        FirebaseApp.configure()
        AppCheck.setAppCheckProviderFactory(nil)

    }
    
    var body: some Scene {
        WindowGroup {
            SplashScreenWithNavigation()  // SplashScreen ardından yönlendirme yapılır
        }
    }
}

struct SplashScreenWithNavigation: View {
    @State private var navigateToLogin = false

    var body: some View {
        ZStack {
            SplashScreen(logoImageName: "renova_logo")  // Logonun adı burada belirtiliyor
            
                .frame(width: 450, height: 450)
                .onAppear {
                    // SplashScreen 4 saniye sonra LoginScreen'e yönlendirilecek
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                        navigateToLogin = true
                    }
                }

            
            .opacity(0) // Görünmez yapıyoruz
        }
    }
}

struct SplashScreen: View {
    @State private var isActive = false // Animasyonun bitip bitmediğini kontrol eden state
    @State private var navigateToLoginScreen = false // Login ekranına geçişi kontrol eden state
    @State private var displayedText = "" // Görünen yazı
    @State private var cursorVisible = true // İmleç görünürlüğü
    @State private var isWriting = true // Yazma/silme kontrolü
    let logoImageName: String // Logonun dosya adını dışarıdan alacağız
    let fullText = "Hoş Geldiniz" // Gösterilecek tam metin

    var body: some View {
        NavigationStack {
            VStack {
                if !isActive {
                    HStack {
                        Text(displayedText)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        if cursorVisible {
                            Text("|")
                                .font(.largeTitle)
                                .foregroundColor(.blue)
                                .opacity(cursorVisible ? 1 : 0)
                        }
                    }
                    .onAppear {
                        startTypingAnimation()
                    }
                } else {
                    // "Hoş Geldiniz!" yazısı kaybolduktan sonra logo gösterilir
                    Image(logoImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250, height: 250)
                        .padding()

                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                        .padding()
                }
            }
            .onAppear {
                // 2 saniye sonra "Hoş Geldiniz!" yazısını kaldırıp logoyu göstermek için
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.isActive = true
                }
                // 4 saniye sonra giriş ekranına geçiş yapmak için
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    self.navigateToLoginScreen = true
                }
            }
            .background(
                NavigationLink(destination: LoginScreen(), isActive: $navigateToLoginScreen) {
                    EmptyView()
                }
                .opacity(0)
            )
        }
    }

    private func startTypingAnimation() {
        var charIndex = 0
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if charIndex < fullText.count {
                let index = fullText.index(fullText.startIndex, offsetBy: charIndex)
                displayedText.append(fullText[index])
                charIndex += 1
            } else if isWriting {
                isWriting = false
                Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { deleteTimer in
                    if !displayedText.isEmpty {
                        displayedText.removeLast()
                    } else {
                        deleteTimer.invalidate()
                    }
                }
            } else {
                timer.invalidate()
            }
        }

        // İmleç animasyonu
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { cursorTimer in
            cursorVisible.toggle()
        }
    }
}
struct LoginScreen1: View {
    var body: some View {
        Text("Giriş Ekranı")
    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen(logoImageName: "renova_logo") // Logonun adını burada belirtin
    }
}




