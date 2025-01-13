import SwiftUI

struct ContentView1: View {
    @State private var selectedTab: Int = 0
    @State private var isTabBarHidden: Bool = false

    var body: some View {
        VStack {
            // Sayfa içeriği
            ScrollView {
                VStack {
                    Text("")
                        .font(.largeTitle)
                        .padding()
                    // Sayfa içeriği devamı...
                }
                .background(Color.white)
            }
            .onAppear {
                withAnimation {
                    isTabBarHidden = false
                }
            }
            .onDisappear {
                withAnimation {
                    isTabBarHidden = true
                }
            }

            // Tab bar
            if !isTabBarHidden {
                CustomTabBar(selectedTab: $selectedTab)
                    .transition(.move(edge: .bottom))
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int

    var body: some View {
        HStack {
            Spacer()

            // Ana Sayfa butonu (Ortada)
            TabBarButton(icon: "house.fill", isSelected: selectedTab == 0) {
                selectedTab = 0
            }

            Spacer()

            // Favoriler butonu
            TabBarButton(icon: "heart.fill", isSelected: selectedTab == 1) {
                selectedTab = 1
            }

            Spacer()

            // Büyütülmüş Profil butonu (Ortada)
            TabBarButton(icon: "person.fill", isSelected: selectedTab == 2) {
                selectedTab = 2
            }
            .frame(width: 60, height: 60) // Profil butonunu büyütme
            .background(Color.white.opacity(0.8)) // Profil butonunun arka planı
            .cornerRadius(35) // Yuvarlatılmış köşeler
            .shadow(radius: 10) // Gölgelendirme

            Spacer()

            // Bildirimler butonu
            TabBarButton(icon: "bell.fill", isSelected: selectedTab == 3) {
                selectedTab = 3
            }

            Spacer()

            // Ayarlar butonu
            TabBarButton(icon: "gearshape.fill", isSelected: selectedTab == 4) {
                selectedTab = 4
            }

            Spacer()
        }
        .frame(height: 70)
        .padding(.horizontal, 20)
        .background(Color.blue.opacity(0.9)) // Saydam arka plan
        .cornerRadius(25)
        .shadow(radius: 10)
        .padding([.leading, .trailing, .bottom])
        .animation(.easeInOut(duration: 0.3), value: selectedTab) // Tabbar animasyonu
    }
}

struct TabBarButton: View {
    var icon: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(isSelected ? .blue : .white)
                .padding(8)
                .background(
                    isSelected ? Color.white.opacity(0.3) : Color.clear,
                    in: Circle()
                )
                .scaleEffect(isSelected ? 1.2 : 1)
                .animation(.easeInOut(duration: 0.2), value: isSelected) // Buton animasyonu
        }
    }
}

struct ContentView1_Previews: PreviewProvider {
    static var previews: some View {
        ContentView1()
    }
}

