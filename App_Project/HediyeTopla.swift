import SwiftUI

struct HediyeTopla: View {
    @State private var starOffset: CGSize = .zero
    @State private var score: Int = 0
    @State private var canCollectReward: Bool = false
    @State private var timeRemaining: Int = 86400 // 1 gün (86400 saniye)
    @State private var timerActive: Bool = false
    @State private var loadingReward: Bool = false
    @State private var showRewards: Bool = false
    @State private var collectedStars: [Int] = [] // Toplanan yıldızları saklamak için dizi
    @State private var showModal: Bool = false // Modal kontrolü
    @State private var starInBox: Bool = false // Yıldızın kutuya girip girmediğini kontrol et
    @State private var starDisappeared: Bool = false // Yıldız kayboldu mu kontrolü

    // Ödüller
    let rewards = [
        "10 Puan: Hediye Kartı",
        "20 Puan: Ücretsiz Kargo",
        "30 Puan: İndirim Kuponu",
        "40 Puan: Özel Hediyelik Eşya",
        "50 Puan: Premium Üyelik"
    ]
    
    func startTimer() {
        if !timerActive {
            timerActive = true
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    timer.invalidate()
                }
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Arka Plan
                Color.blue.opacity(0.1).edgesIgnoringSafeArea(.all)
                
                VStack {
                    // Başlık ve Puan
                    Text("Yıldız Topla")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)
                        .padding()
                    
                    Text("Puan: \(score)")
                        .font(.headline)
                        .foregroundColor(.red)
                        .padding(.bottom, 10)
                    
                    // Yıldız ve Kutular
                    ZStack {
                        // Yıldız
                        if !starDisappeared {
                            Image(systemName: "star.fill")
                                .resizable()
                                .frame(width: 100, height: 100) // Yıldızın boyutunu büyük yapmak
                                .foregroundColor(.yellow)
                                .shadow(radius: 10)
                                .offset(x: starOffset.width, y: starOffset.height)
                                .scaleEffect(starOffset.width > 0 ? 1.5 : 1) // Kaydırma hareketi ile büyüme
                                .animation(.easeInOut(duration: 0.3), value: starOffset) // Kaydırıldıkça animasyon
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            self.starOffset = value.translation
                                        }
                                        .onEnded { value in
                                            // Eğer yıldız yukarı doğru kaydırılmışsa
                                            if self.starOffset.height < -50 { // Yıldız yukarı kaydıysa
                                                self.score += 1
                                                self.starDisappeared = true // Yıldız kaybolur
                                                self.startTimer() // Süre başlasın
                                            } else {
                                                self.starOffset = .zero // Yıldız eski yerine döner
                                            }
                                        }
                                )
                        }
                        
                        // Ödül Kutusu
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.blue) // Mavi renk
                            .frame(width: 100, height: 100) // Küçültülmüş boyut
                            .overlay(
                                Text("Ödül Kutusu")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white) // Yazı rengi beyaz
                            )
                            .shadow(radius: 10)
                            .position(x: 50, y: 50) // Sol üst tarafa konumlandırma
                            .onTapGesture {
                                showModal.toggle() // Modal'ı göster
                            }
                    }
                    
                    // Kalan süre
                    VStack {
                        Text("Kalan Süre")
                          
                            .font(.headline)
                            .foregroundColor(.green)
                            .padding(.bottom, 5)
                        
                        Text("\(timeRemaining / 3600) saat \(timeRemaining / 60 % 60) dakika \(timeRemaining % 60) saniye")
                            .font(.title)
                            .foregroundColor(.blue)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.white)
                                    .shadow(radius: 10)
                            )
                    }
                    .padding(.bottom, 30)
                    
                    // Loading animasyonu
                    if loadingReward {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .yellow))
                            .scaleEffect(2)
                            .padding()
                    }
                }
                
                VStack {
                    Spacer()
                    
                }
                
            }
            .onAppear {
                startTimer()
            }
            .sheet(isPresented: $showModal) {
                // Modal içerik
                VStack {
                    Text("Ödüller")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                    
                    List(rewards, id: \.self) { reward in
                        Text(reward)
                    }
                    
                    Button("Kapat") {
                        showModal.toggle()
                    }
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
        }
    }
    
    func updateRewardStatus() {
        if score >= 10 {
            canCollectReward = true
        } else {
            canCollectReward = false
        }
    }
}

struct HediyeTopla_Previews: PreviewProvider {
    static var previews: some View {
        HediyeTopla()
    }
}

