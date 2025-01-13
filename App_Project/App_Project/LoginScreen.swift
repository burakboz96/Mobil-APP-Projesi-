import SwiftUI
import FirebaseAuth


struct MyApp: App {
    @State private var isLoggedIn: Bool = UserDefaults.standard.bool(forKey: "isLoggedIn")
    
    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                HomeScreen()
            } else {
                LoginScreen()
            }
        }
    }
}

struct LoginScreen: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isRememberMeChecked: Bool = false
    @State private var animateCircles = false
    @State private var navigateToRegisterScreen = false
    @State private var errorMessage: String? = nil
    @State private var isLoading: Bool = false
    @State private var navigateToHomeScreen = false
    @State private var navigateToForgotPassword = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Animated Background
                AnimatedBackgroundView(animate: $animateCircles)

                VStack {
                    Spacer()

                    VStack(alignment: .center) {
                        Text("Giriş Ekranı")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .padding()

                        TextField("E-posta", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                            .background(Color.white.opacity(0.7))
                            .cornerRadius(10)
                            .foregroundColor(.black)

                        SecureField("Şifre", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                            .background(Color.white.opacity(0.7))
                            .cornerRadius(10)
                            .foregroundColor(.black)

                        HStack {
                            Toggle(isOn: $isRememberMeChecked) {
                                Text("Beni hatırla")
                                    .foregroundColor(.black)
                            }
                            .padding()

                            Spacer()

                            VStack {
                                            Button(action: {
                                                print("Şifremi unuttum tıklandı")
                                                navigateToForgotPassword = true
                                            }) {
                                                Text("Şifremi unuttum?")
                                                    .font(.footnote)
                                                    .foregroundColor(.blue)
                                            }

                                            // NavigationLink ile yönlendirme
                                            NavigationLink(
                                                destination: ForgotPasswordScreen(),
                                                isActive: $navigateToForgotPassword,
                                                label: {
                                                    EmptyView()
                                                })
                                        }
                        }
                        .padding()

                        Button(action: {
                            performLogin()
                        }) {
                            Text("Giriş Yap")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .padding()

                        Button(action: {
                            navigateToRegisterScreen = true
                        }) {
                            Text("Kayıt Ol")
                                .font(.title2)
                                .foregroundColor(.blue)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .cornerRadius(10)
                                .overlay(RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.blue, lineWidth: 2))
                        }
                        .padding()

                        
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .padding()
                        }

                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .padding()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white.opacity(0.6))
                    .cornerRadius(20)
                    .padding()

                    Spacer()
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                        animateCircles.toggle()
                    }
                }
                .background(
                    NavigationLink(destination: RegisterScreen(), isActive: $navigateToRegisterScreen) {
                        EmptyView()
                    }
                    .opacity(0)
                )

                NavigationLink(destination: HomeScreen(), isActive: $navigateToHomeScreen) {
                    EmptyView()
                }
                .opacity(0)
            }
        }
    }

    func performLogin() {
        guard isValidEmail(email) else {
            self.errorMessage = "Geçersiz e-posta adresi"
            return
        }

        guard !password.isEmpty else {
            self.errorMessage = "Şifre boş bırakılamaz"
            return
        }

        isLoading = true
        errorMessage = nil

        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            isLoading = false

            if let error = error {
                self.errorMessage = "Giriş başarısız: \(error.localizedDescription)"
                return
            }

            if isRememberMeChecked {
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
            }

            navigateToHomeScreen = true
        }
    }

    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z.-_%]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
}

// Animasyonlu Arka Plan Daireleri
struct AnimatedBackgroundView: View {
    @Binding var animate: Bool
    
    var body: some View {
        ZStack {
            // Mor Daire
            Circle()
                .frame(width: 300, height: 300)
                .foregroundColor(.purple)
                .opacity(animate ? 0.6 : 0.3)
                .offset(
                    x: animate ? CGFloat.random(in: -UIScreen.main.bounds.width...UIScreen.main.bounds.width) : CGFloat.random(in: -UIScreen.main.bounds.width...UIScreen.main.bounds.width),
                    y: animate ? CGFloat.random(in: -UIScreen.main.bounds.height...UIScreen.main.bounds.height) : CGFloat.random(in: -UIScreen.main.bounds.height...UIScreen.main.bounds.height)
                )
                .animation(.easeInOut(duration: 5).repeatForever(autoreverses: true), value: animate)
            
            // Yeşil Daire
            Circle()
                .frame(width: 300, height: 300)
                .foregroundColor(.green)
                .opacity(animate ? 0.6 : 0.3)
                .offset(
                    x: animate ? CGFloat.random(in: -UIScreen.main.bounds.width...UIScreen.main.bounds.width) : CGFloat.random(in: -UIScreen.main.bounds.width...UIScreen.main.bounds.width),
                    y: animate ? CGFloat.random(in: -UIScreen.main.bounds.height...UIScreen.main.bounds.height) : CGFloat.random(in: -UIScreen.main.bounds.height...UIScreen.main.bounds.height)
                )
                .animation(.easeInOut(duration: 15).repeatForever(autoreverses: true), value: animate)
            
            // Sarı Daire
            Circle()
                .frame(width: 300, height: 300)
                .foregroundColor(.yellow)
                .opacity(animate ? 0.6 : 0.3)
                .offset(
                    x: animate ? CGFloat.random(in: -UIScreen.main.bounds.width...UIScreen.main.bounds.width) : CGFloat.random(in: -UIScreen.main.bounds.width...UIScreen.main.bounds.width),
                    y: animate ? CGFloat.random(in: -UIScreen.main.bounds.height...UIScreen.main.bounds.height) : CGFloat.random(in: -UIScreen.main.bounds.height...UIScreen.main.bounds.height)
                )
                .animation(.easeInOut(duration: 15).repeatForever(autoreverses: true), value: animate)
            
            // Mavi Daire
            Circle()
                .frame(width: 300, height: 300)
                .foregroundColor(.blue)
                .opacity(animate ? 0.6 : 0.3)
                .offset(
                    x: animate ? CGFloat.random(in: -UIScreen.main.bounds.width...UIScreen.main.bounds.width) : CGFloat.random(in: -UIScreen.main.bounds.width...UIScreen.main.bounds.width),
                    y: animate ? CGFloat.random(in: -UIScreen.main.bounds.height...UIScreen.main.bounds.height) : CGFloat.random(in: -UIScreen.main.bounds.height...UIScreen.main.bounds.height)
                )
                .animation(.easeInOut(duration: 5).repeatForever(autoreverses: true), value: animate)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct HomeScreen1: View {
    var body: some View {
        VStack {
            Text("Ana Sayfa")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            Spacer()
            
            Button(action: {
                UserDefaults.standard.set(false, forKey: "isLoggedIn")
                exit(0) // Çıkış yapınca uygulamayı yeniden başlatır
            }) {
                Text("Çıkış Yap")
                    .foregroundColor(.red)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.red, lineWidth: 2))
            }
            .padding()
        }
    }
}

struct LoginScreen_Previews: PreviewProvider {
    static var previews: some View {
        LoginScreen()
    }
}
