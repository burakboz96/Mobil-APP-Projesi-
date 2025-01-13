//
//  SplashScreenView.swift
//  App_Project
//
//  Created by Burak Bozoğlu on 9.11.2024.
//


import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var rotationAngle = 0.0 // Görsel için dönüş açısı
    
    var body: some View {
        VStack {
            if isActive {
                LoginView() // Açılış ekranından sonra giriş ekranına geçiş yapar
            } else {
                VStack {
                    Text("Hoşgeldiniz")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .padding()
                    
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)
                        .rotationEffect(.degrees(rotationAngle))
                        .onAppear {
                            withAnimation(Animation.linear(duration: 1).repeatForever(autoreverses: false)) {
                                rotationAngle = 360
                            }
                        }
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.isActive = true // 2 saniye sonra giriş ekranına geçiş yapar
                    }
                }
            }
        }
        .background(Color.white.ignoresSafeArea())
    }
}

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var navigateToHome = false // Ana ekrana geçiş kontrolü

    var body: some View {
        VStack(spacing: 20) {
            Text("Giriş Yap")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            TextField("Kullanıcı Adı", text: $username)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
            
            SecureField("Şifre", text: $password)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
            
            Button(action: {
                // Giriş işlemi (örneğin giriş bilgilerini doğrulayabilirsiniz)
                navigateToHome = true
            }) {
                Text("Giriş Yap")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            Button(action: {
                // Şifre değiştirme işlemi
            }) {
                Text("Şifremi Değiştir")
                    .foregroundColor(.blue)
                    .padding()
            }
        }
        .padding()
        .background(Color.white.ignoresSafeArea())
        .navigationDestination(isPresented: $navigateToHome) {
            HomeView()
        }
    }
}

struct HomeView: View {
    var body: some View {
        VStack {
            Text("Ana Sayfa")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            Text("Hoşgeldiniz, bu ana ekranınızdır.")
                .font(.body)
                .padding(.top, 20)
        }
        .padding()
        .background(Color.white.ignoresSafeArea())
    }
}

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                SplashScreenView()
            }
        }
    }
}
