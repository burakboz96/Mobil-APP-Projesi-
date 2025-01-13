import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import FirebaseMessaging
import AVKit // Video oynatıcı için gerekli kütüphane
struct HomeScreen: View {
    
    @State private var searchText: String = ""
    @State private var searchHistory: [String] = []
    @State private var scrollTarget: String? = nil // Hedef içerik ID'si
    @State private var isExpanded = false  //arama çubuğu otomatikmem trigerlama
    @State private var selectedTab = 0 // Navbar için seçilen sekme
    @State private var animateTransition = false // Animasyon kontrolü
    //@State private var searchText = "" // Arama çubuğu için
    @State private var currentImageIndex = 0 // Carousel'in indexi
    @State private var selectedImage: String? = nil // Seçilen resim için
    @State private var dragOffset = CGSize.zero // Kullanıcının görseli sürüklemesi için
    @State private var showModal = false // Modal'ın görünürlüğü  // ürünler için
    @State private var showModal1 = false // Modal'ın görünürlüğü //grid yapısı için
    @State private var isDetailViewPresented: Bool = false
    @State private var navigateToCarModel3DPage = false // Geçiş durumu için @State değişkeni
    @State private var filteredResults: [String] = []
    @State private var selectedCardIndex: Int = 0
    
    @State private var favoriteItems: [Int] = [] // Favorilere eklenen görsellerin indeksleri
    @State private var selectedTab1 = 0
    @State private var showComments = false
    @State private var isFormPresented = false
    @State private var name = ""
    @State private var city = ""
    @State private var address = ""
    @State private var hasParticipated = false
    @State private var showSettingsView = false
    @State private var descriptions: [String: String] = [
        "image1": "Bu, birinci görselin açıklamasıdır.",
        "image2": "Bu, ikinci görselin açıklamasıdır.",
        "image3": "Bu, üçüncü görselin açıklamasıdır."
    ]
    @State private var selectedIndex: Int? = nil // Tıklanan öğenin indexi
    @State private var showSettings = false
    @State private var currentIndex = 0
    @State private var currentIndex1 = 0
    @State private var selectedDescription: String? = nil
    @State private var selectedDetail: String? = nil
    @State private var isLoading: Bool = false
    @State private var scrollOffset: CGFloat = 0
    
    @State private var navigateToHediyeToplaPage = false  // navigateToHediyeToplaPage
    @State private var isModalPresented: Bool = false//hediye içerik modal
    @State private var isMenuVisible = false // To control menu visibility
    @State private var menuOffset: CGSize = .zero // Track menu position
    
    
    @State private var showSupportSheet = false
    @State private var showPhoneSheet = false
    @State private var showEmailSheet = false
    @State private var emailRecipient = "support@yourapp.com"
    
    let campaignImages = ["audi", "porche", "tesla", "dahafazlası"] // Example array of image names
    let CarouselView = ["audi", "porche", "tesla","dahafazlası"] // Görsel isimleri (Assets'te tanımlı olmalı)
    let gridImages = ["loading", "loading", "loading","loading"] // Kareler için görseller
    // Dinamik başlıklar için bir dizi
    let gridDescriptions: [String] = [
        "Açıklama 1: Bu görsel hakkında detaylı bilgi...",
        "Açıklama 2: Favori görselinizle ilgili bilgiler burada...",
        "Açıklama 3: Bu görsel, özel bir koleksiyonun parçasıdır...",
        "Açıklama 4: Daha fazla detay için favorilerinizi kontrol edin..."
        // Her grid için bir açıklama ekleyin.
    ]
    //let displayedItems = selectedTab == 0 ? gridImages.indices : favoriteItems
    let tabTitles = ["Ana Sayfa", "Favoriler", "Profil", "Bildirimler", "Ayarlar"]
    let carouselImages = [  "indirim1", "indirim2", "indirim3"   ] //carosel image ve dynamic text kısımlarının dizi boyutları eşit
    let dynamicTexts = ["İndirimli Ürünler", "Süper İndirim", "%20 İndirim"]
    let detailTexts = [
        "Daha fazlası için tıklayın.",
        "Daha fazlası için ıklayın.",
        "Daha fazlası için tıklayın."
    ]
    let carouselDescriptions = ["Ürün 1 Açıklaması", "Ürün 2 Açıklaması", "Ürün 3 Açıklaması"] // Resim açıklamaları
    
    
    func toggleFavorite(index: Int) {
        if let existingIndex = favoriteItems.firstIndex(of: index) {
            favoriteItems.remove(at: existingIndex)
        } else {
            favoriteItems.append(index)
        }
    }
    
    
    func navigateToChatbot() {
        // Chatbot görünümüne geçiş
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = UIHostingController(rootView: ChatbotView())
            window.makeKeyAndVisible()
        }
    }
    
    
    private func closeModal() {
        withAnimation {
            showModal = false
            selectedIndex = nil
        }
    }
    
    
    private func filterSearchResults() {
           // Metin bazlı arama ve filtreleme
           if !searchText.isEmpty {
               filteredResults = searchHistory.filter {
                   $0.localizedCaseInsensitiveContains(searchText)
               }
           } else {
               filteredResults = []
           }
       }
    
    public func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: date)
    }

    
    func navigateToHediyeTopla() {
        // Uygulama penceresine erişim ve root görünüm değiştirme
        if let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }) {
            
            window.rootViewController = UIHostingController(rootView: HediyeTopla())
            window.makeKeyAndVisible()
        }
    }
    
    
    class FavoriteManager: ObservableObject {
        @Published var favoriteItems: [String] = []

        func toggleFavorite(_ item: String) {
            if let existingIndex = favoriteItems.firstIndex(of: item) {
                favoriteItems.remove(at: existingIndex)
            } else {
                favoriteItems.append(item)
            }
        }

        func isFavorite(_ item: String) -> Bool {
            return favoriteItems.contains(item)
        }
    }
    
    var body: some View {
        
        
       
            
            NavigationView {
                
                
                VStack {
                    
                   
                    
                    
                    // Dinamik Başlık
                    HStack {
                        Spacer()
                        Text(tabTitles[selectedTab])
                            .font(.system(size: 26, weight: .semibold, design: .rounded))
                            .foregroundColor(.black)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                        Spacer()
                    }
                    .padding(.bottom, 20)
                
                    .background(
                        ZStack(alignment: .bottom ) {
                            Color.white.opacity(0.1) // Saydam arka plan
                            Rectangle()
                                .fill(Color.gray.opacity(0.9)) // Çizgi rengi ve saydamlığı
                                .frame(height: 1) // Çizgi kalınlığı
                                .edgesIgnoringSafeArea(.horizontal) // Çizginin kenarlara kadar uzanması
                                .offset(y: 10) // Çizgiyi yukarı taşı
                              
                        }
                    )
            
                    
                    
                    ScrollView {  //burda-------------------------------------------------------------
                        
                        // `selectedTab == 4` olduğunda SelectedTabView çağırma
                        if selectedTab == 4 {
                            SettingsTabView() //
                        }
                        
                        if selectedTab == 2 {
                            ProfileTabView() //
                        }
                        
                        if selectedTab == 3 {
                            NotificationsTabView() //
                        }
                       
                        if selectedTab == 1 {
                            FavoritesView() //
                        }
                        
                        if selectedTab == 0 || selectedTab == 1 {
                                     HStack {
                                         // Arama İkonu Butonu
                                         Button(action: {
                                             withAnimation(.easeInOut(duration: 0.2)) {
                                                 isExpanded.toggle() // Arama çubuğunu aç/kapat
                                             }
                                         }) {
                                             Image(systemName: "magnifyingglass")
                                                 .foregroundColor(.white)
                                                 .padding()
                                                 .background(Color.blue)
                                                 .clipShape(Circle())
                                         }
                                         
                                         // Arama Çubuğu
                                         if isExpanded {
                                             TextField("Arama yap...", text: $searchText, onEditingChanged: { isEditing in
                                                 if !isEditing {
                                                     // Klavye kapandığında geçmişe ekle
                                                     if !searchText.isEmpty && !searchHistory.contains(searchText) {
                                                         searchHistory.append(searchText)
                                                     }
                                                 }
                                             })
                                             .padding(10)
                                             .background(Color.white)
                                             .cornerRadius(10)
                                             .transition(.move(edge: .trailing)) // Sağa doğru kayarak açılma animasyonu
                                             .shadow(color: .gray.opacity(0.6), radius: 5, x: 0, y: 5)
                                             .onChange(of: searchText) { newText in
                                                 filterSearchResults()
                                             }
                                         }
                                     }
                                     .onAppear {
                                         // Sayfa her ziyaret edildiğinde animasyonu tetikle
                                         isExpanded = false // Önce kapalı hale getir
                                         DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                             withAnimation(.easeInOut(duration: 0.6)) { // Açılma süresini biraz yavaşlat
                                                 isExpanded = true
                                             }
                                         }
                                     }
                                     .padding(.horizontal)
                                     .padding(.vertical, 10)
                                 }

                                 // Geçmiş Aramalar
                                 if !searchHistory.isEmpty && !searchText.isEmpty {
                                     VStack(alignment: .leading) {
                                         Text("Geçmiş Aramalar:")
                                             .font(.headline)
                                             .padding(.leading)
                                         
                                         ScrollView {
                                             VStack(alignment: .leading) {
                                                 ForEach(searchHistory, id: \.self) { item in
                                                     Text(item)
                                                         .padding()
                                                         .background(Color.gray.opacity(0.2))
                                                         .cornerRadius(8)
                                                         .padding(.horizontal)
                                                         .onTapGesture {
                                                             searchText = item
                                                         }
                                                 }
                                             }
                                         }
                                     }
                                 }

                                 // Arama Sonuçları
                                 if !searchText.isEmpty {
                                     VStack(alignment: .leading) {
                                         Text("Sonuçlar:")
                                             .font(.headline)
                                             .padding(.leading)
                                         
                                         ScrollView {
                                             VStack(alignment: .leading) {
                                                 ForEach(filteredResults, id: \.self) { item in
                                                     Text(item)
                                                         .padding()
                                                         .background(Color.gray.opacity(0.2))
                                                         .cornerRadius(8)
                                                         .padding(.horizontal)
                                                 }
                                             }
                                         }
                                     }
                                 }
                        
                        
                        ZStack {
                            // Saydam gri arka plan: Tüm ekranı kaplar
                            if selectedImage != nil {
                                Color.white.opacity(0.3)
                                    .edgesIgnoringSafeArea(.all)
                            }
                            
                            VStack {
                                // Diğer içerikler
                                Spacer()
                                
                                // Tıklanan resim için yeni ekran
                                if let selectedImage = selectedImage {
                                    ZStack {
                                        VStack {
                                            // Resmin küçülmesi ve tam ekran animasyonu
                                            Image(selectedImage)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: UIScreen.main.bounds.width - 40, height: 250) // Küçültülmüş görsel boyutu
                                                .cornerRadius(20)
                                                .shadow(radius: 10)
                                                .padding(.top, 50)
                                                .scaleEffect(animateTransition ? 1 : 0.8) // Animasyonlu açılış
                                                .opacity(animateTransition ? 1 : 0) // Başlangıçta saydam
                                                .animation(.easeInOut(duration: 0.5), value: animateTransition) // Animasyon süresi
                                                .onAppear {
                                                    withAnimation {
                                                        animateTransition = true // Animasyonu başlat
                                                    }
                                                }
                                            
                                            Spacer()
                                            
                                            // Yorum paneli (alt kısmı kaydırarak açılabilir)
                                            VStack {
                                                if showComments {
                                                    VStack {
                                                        Text("Açıklama") // Başlık
                                                            .font(.headline)
                                                            .foregroundColor(.black)
                                                            .padding(.top, 10)
                                                        
                                                        // Yorum metinleri
                                                        ScrollView {
                                                            VStack(alignment: .leading) {
                                                                Text("Bu bir örnek yorum.")
                                                                    .padding(.bottom, 10)
                                                                Text("Başka bir yorum burada yer alabilir.")
                                                                    .padding(.bottom, 10)
                                                                Text("Yorumlar burada gösterilir.")
                                                                    .padding(.bottom, 10)
                                                            }
                                                            .padding(.horizontal)
                                                        }
                                                        .frame(height: 200) // Yorumların boyutunu ayarlayabilirsiniz
                                                        .background(Color.white)
                                                        .cornerRadius(15)
                                                        .shadow(radius: 5)
                                                        .padding()
                                                        .transition(.move(edge: .top)) // Üstten kayarak gelir
                                                    }
                                                }
                                                
                                                // Yorum panelini açan buton
                                                Button(action: {
                                                    withAnimation {
                                                        showComments.toggle()
                                                    }
                                                }) {
                                                    Text(showComments ? "İçeriği Kapat" : "Açıklamayı Görüntüle")
                                                        .font(.body)
                                                        .foregroundColor(.blue)
                                                        .padding()
                                                        .background(Color.white)
                                                        .cornerRadius(25)
                                                        .shadow(radius: 5)
                                                        .padding(.bottom, 20)
                                                }
                                            }
                                            .edgesIgnoringSafeArea(.bottom) // Ekranın alt kısmındaki boşluğu yok sayar
                                        }
                                        .background(Color.white)
                                        .cornerRadius(20)
                                        .shadow(radius: 10)
                                        .padding(.top, 80)
                                        .transition(.move(edge: .top)) // Top'tan kayarak açılır
                                        .animation(.spring(), value: selectedImage) // Spring animasyonu ile açılır
                                    }
                                    
                                    // Kapatma butonu (en altta)
                                    Button(action: {
                                        withAnimation {
                                            self.selectedImage = nil // Resmi kapatma
                                        }
                                    }) {
                                        Image(systemName: "x.circle.fill") // Çarpı simgesi
                                            .foregroundColor(.red) // Kırmızı renk
                                            .font(.largeTitle)
                                            .padding(.top, 1) // Alt boşluk
                                    }
                                }
                            }
                            .padding(.top, 0) // Üstten padding ekleyebilirsiniz
                        }
                        
                        
                        
                        
                        // Carousel
                        if selectedTab == 0 {
                            
                            ZStack {
                                // Arka plan
                                RoundedRectangle(cornerRadius: 40)
                                    .fill(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.white]), startPoint: .top, endPoint: .bottom))
                                    .shadow(radius: 10)
                                    .padding(.horizontal, 0) // Modern görünüm için kenar boşlukları
                                    .frame(height: 245) // Alt kısmı kaplayacak yükseklik
                                
                                
                                ZStack {
                                    ForEach(0..<CarouselView.count, id: \.self) { index in
                                        Image(CarouselView[index])
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 275, height: 190) // Görsel boyutu
                                            .clipped()
                                            .cornerRadius(10)
                                            .shadow(radius: index == currentImageIndex ? 10 : 0) // Ortadaki görsel için gölge
                                            .scaleEffect(index == currentImageIndex ? 1.4 : 0.7) // Ortadaki görseli büyütme
                                            .opacity(index == currentImageIndex ? 1.4 : 0.7) // Ortadaki görseli daha belirgin yapma
                                            .offset(x: CGFloat(index - currentImageIndex) * 220) // Görselleri sağa-sola yerleştirme
                                            .animation(.spring(), value: currentImageIndex) // Geçiş animasyonu
                                            .onTapGesture {
                                                // Tıklama işlemi
                                                selectedImage = CarouselView[index] // Seçilen görseli kaydet
                                            }
                                    }
                                    
                                }
                                
                                
                                VStack {
                                    Spacer()
                                    HStack {
                                        ForEach(0..<CarouselView.count, id: \.self) { index in
                                            Circle()
                                                .fill(index == currentImageIndex ? Color.blue : Color.gray)
                                                .frame(width: 7, height: 34)
                                                .padding(5)
                                        }
                                    }
                                    .padding(.bottom, 66)
                                }
                                
                                
                                .frame(height: 200)
                                .onAppear {
                                    // Otomatik kaydırma için zamanlayıcı
                                    Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { _ in
                                        withAnimation {
                                            currentImageIndex = (currentImageIndex + 1) % CarouselView.count
                                            
                                        }
                                    }
                                    
                                }
                                //
                                .padding(.bottom,-300)
                                
                            }
                            
                        }
                        
                        // 0: Home, 1: Favoriler
                        if selectedTab == 0 || selectedTab == 1 {
                            // İçerik Yazısı
                            Text(selectedTab == 0 ? "Favoriler" : "Favoriler")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.top, 30)

                            // 2x2 Grid
                            ZStack {
                                // Grid yapısı
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: -50), count: 2), spacing: 11) {
                                    let displayedItems = selectedTab == 0 ? gridImages.indices : (favoriteItems.indices)
                                    ForEach(displayedItems, id: \.self) { index in
                                        ZStack(alignment: .topTrailing) {
                                            // Resim
                                            Image(gridImages[index])
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 140)
                                                .cornerRadius(15)
                                                .shadow(radius: 10, x: 0, y: 5)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 20)
                                                        .stroke(Color.gray, lineWidth: 1.5)
                                                )

                                            // Favori butonu
                                            Button(action: {
                                                toggleFavorite(index: index)
                                            }) {
                                                Image(systemName: favoriteItems.contains(index) ? "heart.fill" : "heart")
                                                    .foregroundColor(favoriteItems.contains(index) ? .red : .gray)
                                                    .padding(10)
                                                    .background(Color.white.opacity(0.8))
                                                    .clipShape(Circle())
                                                    .shadow(radius: 5)
                                                    .padding(10)
                                            }
                                            .zIndex(1) // Butonu en üst katmana alıyoruz, böylece etkileşimli olur

                                            // Grid elemanına tıklanınca modal açma
                                            Button(action: {
                                                selectedIndex = index
                                                showModal = true
                                            }) {
                                                Color.clear
                                                    .frame(width: 140, height: 140) // Butonun boyutu grid elemanı ile uyumlu
                                            }
                                        }
                                    }
                                }

                                // Modal ekran
                                if showModal, let selectedIndex = selectedIndex {
                                    VStack {
                                        Spacer()
                                        ZStack {
                                            // Modal içerik
                                            VStack {
                                                // Resim
                                                Image(gridImages[selectedIndex])
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(height: 150)
                                                    .cornerRadius(20)
                                                    .padding()
                                                    .shadow(radius: 10)

                                                // Açıklama alanı
                                                Text(gridDescriptions[selectedIndex]) // Dinamik açıklama
                                                    .font(.body)
                                                    .padding()
                                                    .foregroundColor(.black)

                                                // Kapatma butonu
                                                Button(action: closeModal) {
                                                    Text("Kapat")
                                                        .foregroundColor(.white)
                                                        .padding()
                                                        .background(Color.red)
                                                        .cornerRadius(15)
                                                        .padding(.top, 10)
                                                }
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color.white)
                                            .cornerRadius(20)
                                            .shadow(radius: 15)

                                        }
                                        .edgesIgnoringSafeArea(.bottom) // Alt kısımda boşluk bırakmamak için
                                    }
                                    .background(Color.blue.opacity(0.5).edgesIgnoringSafeArea(.all)) // Arka plan saydam
                                    .onTapGesture {
                                        closeModal() // Modal dışına tıklanınca kapansın
                                    }
                                }
                            }
                        }



                        
                        
                        
                        if selectedTab == 0 { // 0: Home, 1: Favoriler
                            // İçerik Yazısı
                            Text("Kampanya")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                                .padding(.top, 20)
                            
                            if isFormPresented {
                                ZStack {
                                    // Karartma arka plan
                                    Color.black.opacity(0.4)
                                        .ignoresSafeArea()
                                        .onTapGesture {
                                            withAnimation {
                                                isFormPresented = false // Formu kapat
                                            }
                                        }
                                    
                                    // Form İçeriği
                                    VStack(spacing: 20) {
                                        HStack {
                                            Spacer()
                                            Button(action: {
                                                withAnimation {
                                                    isFormPresented = false
                                                }
                                            }) {
                                                Image(systemName: "xmark")
                                                    .foregroundColor(.black)
                                                    .padding(10)
                                                    .background(Color.gray.opacity(0.2))
                                                    .clipShape(Circle())
                                            }
                                        }
                                        .padding(.horizontal)
                                        
                                        Text("Katılım Formu")
                                            .font(.title)
                                            .fontWeight(.bold)
                                        
                                        TextField("İsim Soyisim", text: $name)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                            .padding(.horizontal)
                                        
                                        TextField("İl", text: $city)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                            .padding(.horizontal)
                                        
                                        TextField("Adres", text: $address)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                            .padding(.horizontal)
                                        
                                        Button(action: {
                                            if !name.isEmpty && !city.isEmpty && !address.isEmpty {
                                                hasParticipated = true
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                    withAnimation {
                                                        isFormPresented = false
                                                    }
                                                }
                                            }
                                        }) {
                                            Text(hasParticipated ? "BAŞARIYLA KATILDINIZ" : "KATIL")
                                                .fontWeight(.semibold)
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                                .background(hasParticipated ? Color.green : Color.blue)
                                                .foregroundColor(.white)
                                                .cornerRadius(8)
                                        }
                                        .padding(.horizontal)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(15)
                                    .shadow(radius: 10)
                                }
                                .transition(.move(edge: .top)) // Altan üste geçiş animasyonu
                            }
                            // Kampanya Kartı
                            ZStack {
                                // Arka plan
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(LinearGradient(gradient: Gradient(colors: [Color.green.opacity(0.8), Color.green]), startPoint: .top, endPoint: .bottom))
                                    .shadow(radius: 5)
                                    .padding(.horizontal)
                                
                                VStack(spacing: 15) {
                                    // Başlık
                                    Text("EFSANE ÖDÜLLERLE\nYENİ YIL ÇEKİLİŞİ BAŞLADI")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.white)
                                    
                                    // Katılım Butonu
                                    Button(action: {
                                        withAnimation {
                                            isFormPresented = true // Formu aç
                                        }
                                    }) {
                                        Text("HEMEN GEL ÜCRETSİZ KATIL")
                                            .fontWeight(.semibold)
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 10)
                                            .background(Color.yellow)
                                            .foregroundColor(.green)
                                            .cornerRadius(8)
                                    }
                                    
                                    // Ödül Görselleri ve Metinleri
                                    HStack(spacing: 20) {
                                        VStack {
                                            Image(systemName: "airpodspro")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 50)
                                            Text("25 ADET\nAIRPODS 4")
                                                .font(.caption)
                                                .multilineTextAlignment(.center)
                                                .foregroundColor(.white)
                                        }
                                        
                                        VStack {
                                            Image(systemName: "iphone")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 50)
                                            Text("5 ADET\nIPHONE 16")
                                                .font(.caption)
                                                .multilineTextAlignment(.center)
                                                .foregroundColor(.white)
                                        }
                                        
                                        VStack {
                                            Image(systemName: "gamecontroller")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 50)
                                            Text("10 ADET\nPLAYSTATION 5")
                                                .font(.caption)
                                                .multilineTextAlignment(.center)
                                                .foregroundColor(.white)
                                        }
                                    }
                                }
                                .padding()
                            }
                            .padding(.top, 10)
                            
                            // Form Görünümü
                            if isFormPresented {
                                ZStack {
                                    // Karartma arka plan
                                    Color.black.opacity(0.4)
                                        .ignoresSafeArea()
                                        .onTapGesture {
                                            withAnimation {
                                                isFormPresented = false // Formu kapat
                                            }
                                        }
                                    
                                    // Form İçeriği
                                    VStack(spacing: 20) {
                                        HStack {
                                            Spacer()
                                            Button(action: {
                                                withAnimation {
                                                    isFormPresented = false
                                                }
                                            }) {
                                                Image(systemName: "xmark")
                                                    .foregroundColor(.black)
                                                    .padding(10)
                                                    .background(Color.gray.opacity(0.2))
                                                    .clipShape(Circle())
                                            }
                                        }
                                        .padding(.horizontal)
                                        
                                        Text("Katılım Formu")
                                            .font(.title)
                                            .fontWeight(.bold)
                                        
                                        TextField("İsim Soyisim", text: $name)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                            .padding(.horizontal)
                                        
                                        TextField("İl", text: $city)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                            .padding(.horizontal)
                                        
                                        TextField("Adres", text: $address)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                            .padding(.horizontal)
                                        
                                        Button(action: {
                                            if !name.isEmpty && !city.isEmpty && !address.isEmpty {
                                                hasParticipated = true
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                                    withAnimation {
                                                        isFormPresented = false
                                                    }
                                                }
                                            }
                                        }) {
                                            Text(hasParticipated ? "BAŞARIYLA KATILDINIZ" : "KATIL")
                                                .fontWeight(.semibold)
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                                .background(hasParticipated ? Color.green : Color.blue)
                                                .foregroundColor(.white)
                                                .cornerRadius(8)
                                        }
                                        .padding(.horizontal)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(15)
                                    .shadow(radius: 10)
                                }
                                .transition(.move(edge: .top)) // Altan üste geçiş animasyonu
                                
                            }
                        }
                        
                        //indirim
                        if selectedTab == 0 {
                            TabView(selection: $currentIndex1) {
                                ForEach(0..<carouselImages.count, id: \.self) { index in
                                    HStack {
                                        // Resim
                                        Image(carouselImages[index])
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 150, height: 150)
                                            .cornerRadius(10)
                                            .onTapGesture {
                                                selectedImage = carouselImages[index]
                                                selectedDescription = dynamicTexts[index]
                                                selectedDetail = detailTexts[index]
                                                showModal1.toggle()
                                            }
                                        
                                        // Metinler
                                        VStack(alignment: .leading) {
                                            Text(dynamicTexts[index])
                                                .font(.title2)
                                                .foregroundColor(.black)
                                                .padding(.bottom, 5)
                                            
                                            Text(detailTexts[index]) // Her resim için detay tanımı
                                                .font(.body)
                                                .foregroundColor(.gray)
                                        }
                                        .padding()
                                    }
                                    .padding()
                                    .tag(index)
                                    .background(
                                        LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.white.opacity(0.5)]),
                                                       startPoint: .topLeading,
                                                       endPoint: .bottomTrailing)
                                    ) // Modern mavi-beyaz gradyan arka plan
                                    .cornerRadius(15) // Köşeleri yuvarlat
                                    .shadow(color: .gray.opacity(0.5), radius: 10, x: 5, y: 5) // Gölge etkisi
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1) // Hafif dış kenarlık
                                    )
                                }
                            }
                            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                            .frame(height: 300)
                            .padding(.top, -50) // Carousel'i yukarı taşı
                            .animation(.easeInOut, value: currentIndex1)
                            .onAppear {
                                Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
                                    withAnimation {
                                        currentIndex1 = (currentIndex1 + 1) % carouselImages.count
                                    }
                                }
                            }
                            .sheet(isPresented: $showModal1) {
                                VStack {
                                    if let selectedImage = selectedImage {
                                        Image(selectedImage)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 200, height: 200)
                                            .cornerRadius(10)
                                    }
                                    
                                    if let selectedDescription = selectedDescription {
                                        Text(selectedDescription)
                                            .font(.title)
                                            .foregroundColor(.black)
                                            .padding(.bottom, 10)
                                    }
                                    
                                    if let selectedDetail = selectedDetail {
                                        Text(selectedDetail)
                                            .font(.body)
                                            .foregroundColor(.white)
                                            .padding()
                                    }
                                    
                                    Spacer()
                                }
                                .padding()
                            }
                        }
                        
                        
                        
                        
                        if selectedTab == 0 {
                            Text("Yeni NovaAi")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                                .padding(.top, 20)
                            ZStack {
                                // Arka plan siyah
                                Color.black
                                    .edgesIgnoringSafeArea(.all)
                                
                                VStack(spacing: 30) {
                                    Text("NOVAaİ")
                                        .font(.system(size: 48, weight: .bold, design: .rounded))
                                        .foregroundColor(.blue)
                                        .shadow(color: .blue.opacity(0.7), radius: 15, x: 0, y: 5)
                                        .padding(.top, 50)
                                    // Arcade Metni
                                    Text(" Kaliteli Sohbet.\n Tamamen Ücretsiz.\nReklamsız.")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                        .shadow(color: .blue.opacity(0.7), radius: 10, x: 0, y: 5)
                                        .cornerRadius(50)
                                    // Buton
                                    Button(action: {
                                        // Yönlendirme işlemi burada gerçekleşiyor
                                        navigateToChatbot()
                                    }) {
                                        Text("Sohbete Başla")
                                            .foregroundColor(.white)
                                            .font(.headline)
                                            .frame(width: 220, height: 50)
                                            .cornerRadius(20)
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(Color.blue)
                                                    .shadow(color: .blue.opacity(0.5), radius: 15, x: 0, y: 10)
                                            )
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.black.opacity(0.9))
                                        .shadow(color: .blue.opacity(0.4), radius: 20, x: 0, y: 10)
                                    
                                )
                                .padding()
                            }
                        }
                        
                        
                        
                        VStack {
                            if selectedTab == 0 {
                                 Text("Hediye İçerik")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                    .padding(.top, 20)
                                
                                ZStack {
                                    // Arka Plan Rengi
                                    Rectangle()
                                        .fill(LinearGradient(gradient: Gradient(colors: [Color.red, Color.pink]),
                                                             startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .cornerRadius(20)
                                        .frame(width: 350, height: 400) // Görsel boyutu
                                    
                                    // İçerik
                                    VStack(spacing: 20) {
                                        Text("TOPLAMAYA BAŞLA  HEDİYE KAZAN")
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                            .padding(.top, 20)
                                        
                                        Image(systemName: "star")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 120, height: 120)
                                            .foregroundColor(.white)
                                            .shadow(radius: 10)
                                        
                                        Text("TOPLA")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        
                                        Text("Toplanan yıldızlar her ay yenilenir.")
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                    
                                    // Kaydırma alanı
                                    Rectangle()
                                        .fill(Color.blue)
                                        .frame(height: 60)
                                        .cornerRadius(10)
                                        .overlay(
                                            Text("Sağa Kaydırarak Hediye Topla")
                                                .foregroundColor(.white)
                                                .font(.headline)
                                        )
                                        .offset(x: dragOffset.width, y: 200)
                                        .gesture(
                                            DragGesture()
                                                .onChanged { value in
                                                    self.dragOffset = value.translation
                                                }
                                                .onEnded { value in
                                                    let screenWidth = UIScreen.main.bounds.width
                                                    let threshold = screenWidth * 0.6
                                                    
                                                    if self.dragOffset.width > threshold {
                                                        // Kaydırma tamamlandığında sayfaya yönlendir
                                                        self.navigateToHediyeToplaPage = true
                                                    }
                                                    self.dragOffset = .zero
                                                }
                                        )
                                    
                                    // NavigationLink ile HediyeTopla sayfasına geçiş
                                    NavigationLink(destination: HediyeTopla(), isActive: $navigateToHediyeToplaPage) {
                                        EmptyView()
                                    }
                                }
                            }
                        }
                        .navigationBarHidden(true)  // Menü çubuğunu gizle
                        
                        
                        
                        
                        if selectedTab == 0 {
                          
                                VStack(spacing: 20) {
                                    Text("Premium Avantajlara Katıl")
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                        .padding(.top, 20)
                                    
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color(.systemGray6))
                                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                                        
                                        VStack(spacing: 15) {
                                            Image("premium_logo") // Görselin dosya adını kullan
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(height: 200)
                                            
                                            Text("HEMEN KATIL")
                                                .font(.title2)
                                                .fontWeight(.bold)
                                            
                                            Text("Başlangıç fiyatı: 44.99 TL")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                            
                                            NavigationLink(destination: SatınAlmaView()) {
                                                Text("Satın Al")
                                                    .font(.headline)
                                                    .foregroundColor(.white)
                                                    .frame(maxWidth: .infinity)
                                                    .padding()
                                                    .background(Color.black)
                                                    .cornerRadius(10)
                                            }
                                            Text("Ödemeler her ay otomatik olarak yenilenir")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                            
                                            .padding(.horizontal, 20)
                                        }
                                        .padding()
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }
                       
                        
                        // içerik kısmında boşluklar doldurulacak
                        
                        
                        if selectedTab==0{
                            Text("Mutlu Yıllar")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                                .padding(.top, 20)
                            
                            VStack {
                                // Tasarım Başlığı
                                Text("Mutlu Yıllar")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Text("Yılbaşında RENOVATİONS Soft Seninle")
                                    .font(.title3)
                                    .foregroundColor(.white)
                                    .padding(.bottom, 20)
                                
                                // Karakterler ve Butonlar
                                HStack(spacing: 10) {
                                    Button(action: {
                                        // Karaktere tıklama işlemi
                                        if selectedTab == 0 {
                                            isModalPresented.toggle()
                                        }
                                    }) {
                                        Image(systemName: "play.circle.fill")
                                            .resizable()
                                            .frame(width: 80, height: 80)
                                            .foregroundColor(.white)
                                    }
                                    .sheet(isPresented: $isModalPresented) {
                                        VStack {
                                            // Video Player
                                            VideoPlayer(player: AVPlayer(url: URL(string: "https://youtu.be/IIuvKcyPeOY?si=tERC9JiOw5xsB4va")!))
                                                .frame(height: 250)
                                                .cornerRadius(20) // Oval köşeler
                                                .padding()
                                            
                                            // İçerik
                                            Text("Bu, içeriğinizle alakalı bir yazıdır. Daha fazla bilgi ekleyebilirsiniz.")
                                                .font(.body)
                                                .padding()
                                            
                                            Spacer()
                                            
                                            // Hadi Başla Butonu
                                            Button(action: {
                                                // Yönlendirme sayfasına git
                                                // Burada yönlendri.swift sayfasına geçiş yapılabilir
                                                // Örnek: NavigationLink(destination: YönlendriView()) {
                                                print("Yönlendri sayfasına git")
                                            }) {
                                                Text("Hadi Başla")
                                                    .font(.title2)
                                                    .foregroundColor(.white)
                                                    .padding()
                                                    .background(Color.green)
                                                    .cornerRadius(15)
                                                    .padding(.bottom, 20)
                                            }
                                        }
                                        .presentationDetents([.medium, .large])
                                        .background(
                                            LinearGradient(gradient: Gradient(colors: [Color.white, Color.blue]), startPoint: .top, endPoint: .bottom)
                                                .edgesIgnoringSafeArea(.all)
                                        )
                                    }
                                }
                                
                                Spacer()
                                
                                // Alt Taraftaki Oyun İkonları
        
                                
                            }
                            .padding()
                            .background(
                                LinearGradient(gradient: Gradient(colors: [Color.green, Color.blue]), startPoint: .top, endPoint: .bottom)
                                    .edgesIgnoringSafeArea(.all)
                            )
                            .cornerRadius(30) // Oval köşeler
                            .shadow(radius: 10) // Gölgelendirme
                            
                            
                        }
                        
                        

                        if selectedTab == 0 {
                                        VStack {
                                            Text("Araç Lansmanı")
                                                .font(.title)
                                                .fontWeight(.bold)
                                                .foregroundColor(.primary)
                                                .padding(.top, 20)
                                            
                                            VStack {
                                                // Arka Plan Görseli
                                                RoundedRectangle(cornerRadius: 25)
                                                    .fill(LinearGradient(gradient: Gradient(colors: [Color.gray.opacity(0.3), Color.white.opacity(0.3)]), startPoint: .top, endPoint: .bottom)) // Cam efekti
                                                    .frame(height: 300)
                                                    .shadow(radius: 20) // Cam etkisi için gölge
                                                    .overlay(
                                                        VStack {
                                                            // Özel Araç Resmi
                                                            Image("car_image") // Burada kendi resim dosyanızı ekleyebilirsiniz
                                                                .resizable()
                                                                .scaledToFit()
                                                                .frame(width: 220, height: 220)
                                                                .clipShape(Circle()) // Yuvarlak şekilde kesme
                                                                .shadow(radius: 10)
                                                                .padding(.top, 20)
                                                            
                                                            Text("Araç İncelemesi")
                                                                .font(.headline)
                                                                .foregroundColor(.black)
                                                            Text("3D model inceleyin")
                                                                .font(.title2)
                                                                .fontWeight(.bold)
                                                                .foregroundColor(.black)
                                                                .padding(.top, 5)
                                                        }
                                                    )
                                            }
                                            .padding()
                                            
                                            Spacer()
                                            
                                            // Git Butonu
                                            NavigationLink(destination: CarModel3D(), isActive: $navigateToCarModel3DPage) {
                                                EmptyView() // Hidden NavigationLink
                                            }

                                            Button(action: {
                                                navigateToCarModel3DPage = true
                                            }) {
                                                Text("Araçlara Gözat")
                                                    .font(.headline)
                                                    .foregroundColor(.white)
                                                    .padding()
                                                    .frame(maxWidth: .infinity)
                                                    .background(Color.blue)
                                                    .cornerRadius(10)
                                            }
                                            .padding()
                                        }
                                        .navigationBarTitle("Araç Lansmanı", displayMode: .inline)
                                    }
                                
                        
                        if selectedTab == 0 {
                            Text("Kursları Keşfet")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                                .padding(.top, 20)
                            VStack {
                                Spacer()

                                // Yatay ScrollView
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 20) {
                                        ForEach(0..<3) { index in
                                            ZStack {
                                                // Kart Görünümü
                                                RoundedRectangle(cornerRadius: 20)
                                                    .strokeBorder(Color.white, lineWidth: 5) // Çerçeve genişliği
                                                    .background(
                                                        RoundedRectangle(cornerRadius: 20)
                                                            .fill(index == 0 ? Color.purple.opacity(0.6) : index == 1 ? Color.orange.opacity(0.6) : Color.green.opacity(0.6))
                                                    )
                                                    .frame(
                                                        width: selectedCardIndex == index ? 300 : 200,
                                                        height: selectedCardIndex == index ? 400 : 300
                                                    )
                                                    .scaleEffect(selectedCardIndex == index ? 1.1 : 1.0)
                                                    .animation(.spring(), value: selectedCardIndex)
                                                    .onTapGesture {
                                                        selectedCardIndex = index
                                                    }

                                                VStack {
                                                    Text(index == 0 ? "Yapay Zeka" : index == 1 ? "Makine Öğrenmesi" : "Drop Shopping")
                                                        .font(.title2)
                                                        .fontWeight(.bold)
                                                        .foregroundColor(.white)

                                                    if selectedCardIndex == index {
                                                        Text(index == 0 ? "Yapay Zeka alanında en son teknolojileri öğrenin." :
                                                             index == 1 ? "Makine öğrenmesi modellerini sıfırdan geliştirin." :
                                                             "Drop shopping ile e-ticarette başarılı olun.")
                                                            .font(.body)
                                                            .fontWeight(.regular)
                                                            .foregroundColor(.white)
                                                            .padding(.top, 10)
                                                            .multilineTextAlignment(.center)
                                                            .frame(width: 260)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }

                                Spacer()

                                // Seçilen Kurs için Buton
                                if selectedCardIndex >= 0 {
                                    NavigationLink(
                                        destination: CourseView(courseTitle: selectedCardIndex == 0 ? "Yapay Zeka" :
                                                                  selectedCardIndex == 1 ? "Makine Öğrenmesi" :
                                                                  "Drop Shopping"),
                                        label: {
                                            Text("KURSU KEŞFET")
                                                .font(.headline)
                                                .foregroundColor(.white)
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                                .background(Color.blue)
                                                .cornerRadius(30)
                                                .padding(.horizontal, 20)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(Color.white, lineWidth: 4) // Kenarlık genişliği
                                                )
                                        }
                                    )
                                }

                                Spacer()
                            }
                        }
                        
                        
                     
                     
                        if selectedTab == 0 {
                            VStack {
                                // Title
                                Text("Piyasada Bugün")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                    .padding(.top, 20)

                                ZStack {
                                    Rectangle()
                                        .fill(LinearGradient(gradient: Gradient(colors: [Color.green, Color.white]),
                                                             startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .cornerRadius(25)
                                        .frame(width: 330, height: 380) // Rectangle size
                                        .shadow(radius: 10)

                                    VStack {
                                        HStack {
                                            Image(systemName: "arrow.up.circle.fill")
                                                .font(.system(size:50))
                                                .foregroundColor(.yellow)
                                            Spacer()
                                        }
                                        .padding(.top, 30)

                                        Rectangle()
                                            .fill(Color.yellow)
                                            .frame(width: 180, height: 60)
                                            .cornerRadius(12)
                                            .padding(.top, 15)

                                        Spacer()
                                    }
                                    .padding()
                                    
                                    ZStack {
                                        NavigationLink(destination: PiyasaView()) {
                                            Text("Piyasada Bugün")
                                                .font(.headline)
                                                .foregroundColor(.white)
                                                .padding()
                                                .background(Color.green)
                                                .cornerRadius(25) // Oval shape
                                                .shadow(radius: 10) // Optional: Adding shadow for a 3D effect
                                        }
                                        .frame(width: 250)
                                        Image("piyasa") //  image asset
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 200, height: 200) // Adjust size as needed
                                            .offset(y: -170) // Adjust the vertical offset to place the image above the button
                                    }
                                    .padding(.top, 240)  
                                }
                            }
                            .padding(.horizontal, 20) // Horizontal padding for overall spacing
                            .padding(.top, 20) // Top padding for a bit of breathing room
                        }

                       
                        
                       
                        if selectedTab == 0 {
                            Text("Ödülleri Topla")
                         
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                                .padding(.top, 20)
                            NavigationView {
                                ZStack {
                                    // Background
                                    LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                        .edgesIgnoringSafeArea(.all)
                                    
                                    VStack {
                                        Spacer()
                                            .frame(height: 50) // Top space
                                        
                                        // Logo and title
                                        VStack(spacing: 12) {
                                            ZStack {
                                                Circle()
                                                    .fill(Color.white.opacity(0.15))
                                                    .frame(width: 100, height: 100)
                                                
                                                Image(systemName: "map.fill")  // Changed to map icon
                                                    .resizable()
                                                    .frame(width: 60, height: 60)
                                                    .foregroundColor(.white)
                                            }
                                            
                                            Text("ŞEHRİ KEŞFET")
                                                .font(.system(size: 32, weight: .bold))
                                                .foregroundColor(.white)
                                                .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                                            
                                            Text("Haritada ödülleri Toplayın!")
                                                .font(.system(size: 18))
                                                .multilineTextAlignment(.center)
                                                .foregroundColor(.white.opacity(0.85))
                                                .padding(.horizontal, 30)
                                        }
                                        
                                        Spacer()
                                        
                                        // Button with NavigationLink wrapped in ZStack for layout
                                        ZStack {
                                            NavigationLink(destination: HaritaOdulView()) {
                                                Text("Hemen Oyna")
                                                    .font(.system(size: 20, weight: .semibold))
                                                    .foregroundColor(Color.purple)
                                                    .padding()
                                                    .frame(maxWidth: .infinity)
                                                    .background(
                                                        RoundedRectangle(cornerRadius: 15)
                                                            .fill(Color.white)
                                                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                                                    )
                                                    .padding(.horizontal, 30)
                                            }
                                            .frame(width: 250)  // Width of the NavigationLink button
                                        }
                                        .padding(.bottom, 30) // Bottom space
                                    }
                                }
                                .navigationBarHidden(true) // Hides the navigation bar
                            }
                        }

                        
                        
                        
                        
                        if selectedTab==0{
                            VStack {
                                // Title
                                Text("Bize Ulaşın")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                    .padding(.top, 20)
                                
                                // Yellow Container for Icons
                                VStack {
                                    HStack {
                                        // Phone Icon
                                        Button(action: {
                                            if let url = URL(string: "tel://123456789") {
                                                UIApplication.shared.open(url)
                                            }
                                        }) {
                                            Image(systemName: "phone.fill")
                                                .resizable()
                                                .frame(width: 30, height: 30)
                                                .foregroundColor(.white)
                                                .padding()
                                                .background(Circle().fill(Color.green))
                                        }
                                        .frame(width: 60, height: 60)
                                        
                                        // Email Icon
                                        Button(action: {
                                            if let url = URL(string: "mailto:\(emailRecipient)") {
                                                UIApplication.shared.open(url)
                                            }
                                        }) {
                                            Image(systemName: "envelope.fill")
                                                .resizable()
                                                .frame(width: 30, height: 30)
                                                .foregroundColor(.white)
                                                .padding()
                                                .background(Circle().fill(Color.blue))
                                        }
                                        .frame(width: 60, height: 60)
                                        
                                        // Social Media Icon (Example: Instagram)
                                        Button(action: {
                                            if let url = URL(string: "https://instagram.com") {
                                                UIApplication.shared.open(url)
                                            }
                                        }) {
                                            Image(systemName: "app.fill")
                                                .resizable()
                                                .frame(width: 30, height: 30)
                                                .foregroundColor(.white)
                                                .padding()
                                                .background(Circle().fill(Color.purple))
                                        }
                                        .frame(width: 60, height: 60)
                                        
                                        // Close (X) Icon
                                        Button(action: {
                                            // Action for closing, e.g., dismiss view
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .resizable()
                                                .frame(width: 30, height: 30)
                                                .foregroundColor(.white)
                                                .padding()
                                                .background(Circle().fill(Color.red))
                                        }
                                        .frame(width: 60, height: 60)
                                    }
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: 15).fill(Color.yellow)) // Yellow container
                                    .padding(.horizontal, 50)
                                }
                            }
                            .padding()
                            
                        }

                        
                        if selectedTab == 0 {
                            VStack {
                                VStack(spacing: 30) {
                                    Spacer()
                                    
                                    // Başlık
                                    Text("İLETİŞİM BİLGİSİ")
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundColor(.white)
                                        .shadow(color: .blue.opacity(0.8), radius: 5, x: 0, y: 2)
                                    
                                    // Ayırıcı Çizgi
                                    Divider()
                                        .background(Color.white.opacity(0.8))
                                        .padding(.horizontal, 70)
                                    
                                    // Bilgi Alanları
                                    VStack(alignment: .leading, spacing: 15) {
                                        HStack {
                                            Image(systemName: "mappin.and.ellipse")
                                                .foregroundColor(.white.opacity(0.9))
                                            Text("Adres")
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)
                                            Spacer()
                                        }
                                        Text("ELAZIĞ/TÜRKİYE")
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.9))
                                        
                                        HStack {
                                            Image(systemName: "envelope.fill")
                                                .foregroundColor(.white.opacity(0.9))
                                            Text("Email")
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)
                                            
                                        }
                                        Text("bilgi@renova.com")
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.9))
                                        
                                        HStack {
                                            Image(systemName: "phone.fill")
                                                .foregroundColor(.white.opacity(0.9))
                                            Text("Telefon")
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)
                                            Spacer()
                                        }
                                        Text("0212 945 51 55")
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.9))
                                    }
                                    .padding(.horizontal, 20)
                                    
                                    // Harita Butonu
                                    Button(action: {
                                        if let url = URL(string: "http://maps.apple.com/?q=Elazığ+Merkez") {
                                            UIApplication.shared.open(url)
                                        }
                                    }) {
                                        HStack {
                                            Image(systemName: "map.fill")
                                                .foregroundColor(.white)
                                            Text("Haritayı Aç")
                                                .foregroundColor(.white)
                                                .fontWeight(.semibold)
                                        }
                                        .padding()
                                        .background(Color.blue)
                                        .cornerRadius(10)
                                        .shadow(color: .blue.opacity(0.6), radius: 5, x: 0, y: 2)
                                    }
                                    .padding(.top, 20)
                                    
                                    // Sosyal Medya İkonları
                                    HStack(spacing: 20) {
                                        Image(systemName: "square.and.arrow.up.fill")
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                            .foregroundColor(.white)
                                            .shadow(color: .blue.opacity(0.6), radius: 5, x: 0, y: 2)
                                        Image(systemName: "star.fill")
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                            .foregroundColor(.white)
                                            .shadow(color: .blue.opacity(0.6), radius: 5, x: 0, y: 2)
                                        Image(systemName: "tag.fill")
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                            .foregroundColor(.white)
                                            .shadow(color: .blue.opacity(0.6), radius: 5, x: 0, y: 2)
                                    }
                                    .padding(.top, 10)
                                    
                                    // QR ve Logo Alanı
                                    HStack {
                                        Image("QRIcon")
                                            .resizable()
                                            .frame(width: 50, height: 50)
                                            .clipShape(Circle())
                                            .shadow(color: .blue.opacity(0.6), radius: 5, x: 0, y: 2)
                                        Image("TRLogo")
                                            .resizable()
                                            .frame(width: 50, height: 50)
                                            .clipShape(Circle())
                                            .shadow(color: .blue.opacity(0.6), radius: 5, x: 0, y: 2)
                                    }
                                    
                                    Spacer()
                                }
                                .padding()
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.blue.opacity(0.9), Color.blue.opacity(0.6), Color.black]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(20)
                                .shadow(color: .blue.opacity(0.8), radius: 15, x: 0, y: 10)
                                .padding()
                            }
                        }
                        
                        
                        
                        
                        
                        
                        
                        
                        // Sayfa içeriği
                        TabView(selection: $selectedTab) {
                            // Ana Sayfa Sayfası
                            HomeTabView()
                                .tag(0)
                                .transition(.move(edge: .leading))
                            
                            // Favoriler Sayfası
                            FavoritesView()
                                .tag(1)
                                .transition(.move(edge: .leading))
                            
                            // Profil Sayfası
                            ProfileTabView()
                                .tag(2)
                                .transition(.move(edge: .leading))
                            
                            // Bildirimler Sayfası
                            NotificationsTabView()
                                .tag(3)
                                .transition(.move(edge: .leading))
                            
                            // Ayarlar Sayfası
                            SettingsTabView()
                                .tag(4)
                                .transition(.move(edge: .leading))
                        }
                        
                    }//scroolview bitiş burda------------------------------------
                    
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // Sayfa gösterimi, üstteki sayfa göstergesini gizler
                    .animation(.easeInOut(duration: 0.3), value: selectedTab) // Animasyon eklenmiş geçişler
                    
                    
                    
                    
                    // Navbar
                    CustomTabBar(selectedTab: $selectedTab)
                    
                        .padding(.bottom, -30)
                        .background(Color.clear) // Arka planı beyaz
                    
                    
                    
                    
                    
                    
                    
                    
                    
                } // body son
     
            }//vstack son
            
        }//navigationview son
        



    // Ana Sayfa İçeriği
    struct HomeTabView: View {
        var body: some View {
            VStack {
                Text("")
                    .font(.largeTitle)
                    .padding()
                Spacer()
            }
            .background(Color.white)
            .cornerRadius(20)
            .padding()
        }
    
    }
    
    // Favoriler İçeriği
    struct FavoritesTabView: View {
        var body: some View {
            VStack {
                Text("")
                    .font(.largeTitle)
                    .padding()
                Spacer()
            }
            .background(Color.white)
            .cornerRadius(20)
            .padding()
        }
    }
    
    
    
    // Profil İçeriği
    struct ProfileTabView: View {
        @State private var user: FirebaseAuth.User?
        @State private var email: String = ""
        @State private var username: String = ""
        @State private var aboutMe: String = "Hakkında bilgi yok"
        @State private var profileImageUrl: String = ""
        @State private var isLoading: Bool = true
        @State private var errorMessage: String = ""
        @State private var newPassword: String = ""
        @State private var currentPassword: String = ""
        @State private var verificationCode: String = ""
        @State private var showVerificationField: Bool = false
        @State private var isImagePickerPresented: Bool = false
        @State private var selectedImage: UIImage? = nil
        @State private var isPhoneNumberUpdatePresented: Bool = false
        @State private var newPhoneNumber: String = ""
        
        @State private var isPasswordChangePresented = false // For password change modal
        @State private var isMenuVisible = false // To control menu visibility
        @State private var menuOffset: CGSize = .zero // Track menu position
        
        var body: some View {
            ZStack {
                // Main content
              
                    VStack {
                        if isLoading {
                            ProgressView("Yükleniyor...")
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            HStack {
                                if let url = URL(string: profileImageUrl), !profileImageUrl.isEmpty {
                                    AsyncImage(url: url) { image in
                                        image.resizable()
                                            .scaledToFill()
                                            .clipShape(Circle())
                                            .frame(width: 100, height: 100)
                                    } placeholder: {
                                        Circle().fill(Color.gray)
                                            .frame(width: 100, height: 100)
                                    }
                                } else {
                                    Circle().fill(Color.blue)
                                        .frame(width: 100, height: 100)
                                        .overlay(
                                            Text(username.prefix(1)) // Kullanıcı adının ilk harfi
                                                .font(.system(size: 40, weight: .bold))
                                                .foregroundColor(.white)
                                        )
                                }
                                
                                Button(action: {
                                    isImagePickerPresented.toggle()
                                }) {
                                    Image(systemName: "pencil.circle.fill")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.blue)
                                        .padding(.leading, 10)
                                }
                            }
                            
                            Text(username.isEmpty ? "Kullanıcı adı yok" : username)
                                .font(.title)
                                .fontWeight(.bold)
                                .padding(.top)
                            
                            Text(email)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding(.top, 2)
                            
                            Text("Hakkında")
                                .font(.headline)
                                .padding(.top, 20)
                            
                            Text(aboutMe)
                                .font(.body)
                                .padding(.top, 10)
                            
                            Spacer()
                        }
                    }
                    .onAppear {
                        fetchUserData()
                    }
                    .padding()
                    .sheet(isPresented: $isImagePickerPresented) {
                        ImagePicker(isImagePickerPresented: $isImagePickerPresented, selectedImage: $selectedImage)
                    }
                    .sheet(isPresented: $isPhoneNumberUpdatePresented) {
                        PhoneNumberUpdateView(newPhoneNumber: $newPhoneNumber, isPresented: $isPhoneNumberUpdatePresented)
                    }
                    .sheet(isPresented: $isPasswordChangePresented) {
                        PasswordChangeView(isPresented: $isPasswordChangePresented, newPassword: $newPassword)
                    }
                
                // Menu overlay (semi-transparent background)
                           if isMenuVisible {
                               Color.black.opacity(0.4) // Semi-transparent background
                                   .ignoresSafeArea()
                                   .onTapGesture {
                                       withAnimation {
                                           isMenuVisible = false // Close menu when tapping outside
                                       }
                                   }
                           }
                           
                if isMenuVisible {
                               Color.black.opacity(0.4) // Semi-transparent background
                                   .ignoresSafeArea()
                                   .onTapGesture {
                                       withAnimation {
                                           isMenuVisible = false // Close menu when tapping outside
                                       }
                                   }
                           }
                // Menu Button at the bottom-left corner
                           VStack {
                               Spacer()

                               // Menu Button at the bottom-left
                               HStack {
                                   Button(action: {
                                       withAnimation {
                                           isMenuVisible.toggle()
                                       }
                                   }) {
                                       Image(systemName: isMenuVisible ? "xmark" : "plus")
                                           .resizable()
                                           .frame(width: 25, height: 25)
                                           .padding(20)
                                           .background(Color.blue)
                                           .clipShape(Circle())
                                           .foregroundColor(.white)
                                           .transition(.scale) // Button animation for scale
                                   }
                                   .padding()
                                   .frame(maxWidth: .infinity, alignment: .leading)
                                   .padding(.leading, 0) // Ensure it's positioned on the left side
                                   Spacer()
                               }
                               
                               if isMenuVisible {
                                   VStack(spacing: 20) {
                                       Button(action: {
                                           isPhoneNumberUpdatePresented.toggle()
                                           isMenuVisible = false // Close menu after selection
                                       }) {
                                           Text("Telefon Numarası Güncelle")
                                               .foregroundColor(.blue)
                                               .padding()
                                               .frame(maxWidth: .infinity)
                                               .background(Color.white)
                                               .cornerRadius(10)
                                       }

                                       Button(action: {
                                           isPasswordChangePresented.toggle()
                                           isMenuVisible = false // Close menu after selection
                                       }) {
                                           Text("Şifreyi Değiştir")
                                               .foregroundColor(.blue)
                                               .padding()
                                               .frame(maxWidth: .infinity)
                                               .background(Color.white)
                                               .cornerRadius(10)
                                       }
                                   }
                                   .padding()
                                   .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                                   .shadow(radius: 10)
                                   .frame(width: 250) // Set a fixed width for the menu
                                   .transition(.move(edge: .bottom)) // Menu appears from the bottom
                                   .padding(.leading, 40) // Ensure the menu stays aligned to the left side
                                   .offset(y: -70) // Add this line to move the menu a bit higher when
                               }

                               Spacer()
                           }
                           .padding(.bottom, -780) // Space from the bottom edge
                           .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom) // Pin the VStack to the bottom
            }
        }
        func fetchUserData() {
            guard let user = Auth.auth().currentUser else {
                errorMessage = "Kullanıcı giriş yapmamış."
                isLoading = false
                return
            }
            
            let db = Firestore.firestore()
            let userRef = db.collection("users").document(user.uid)
            
            userRef.getDocument { document, error in
                if let error = error {
                    errorMessage = "Hata: \(error.localizedDescription)"
                    isLoading = false
                    return
                }
                
                if let document = document, document.exists {
                    if let data = document.data() {
                        self.email = data["email"] as? String ?? "E-posta yok"
                        self.username = data["username"] as? String ?? ""
                        self.aboutMe = data["aboutMe"] as? String ?? "Hakkında bilgi yok"
                        self.profileImageUrl = data["profileImage"] as? String ?? ""
                    }
                } else {
                    errorMessage = "Kullanıcı verisi bulunamadı."
                }
                isLoading = false
            }
        }
    }

    struct PhoneNumberUpdateView: View {
        @Binding var newPhoneNumber: String
        @Binding var isPresented: Bool
        
        var body: some View {
            VStack {
                Text("Yeni Telefon Numarası")
                    .font(.headline)
                    .padding(.top)
                
                TextField("Telefon Numarası", text: $newPhoneNumber)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.vertical)
                
                Button(action: {
                    // Telefon numarasını güncelleme işlemini burada yap
                    isPresented = false
                }) {
                    Text("Telefon Numarasını Güncelle")
                        .font(.body)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                        .frame(maxWidth: .infinity)
                }
                .padding(.top, 10)
            }
            .padding()
        }
    }

    struct PasswordChangeView: View {
        @Binding var isPresented: Bool
        @Binding var newPassword: String
        
        @State private var currentPassword: String = ""
        @State private var confirmationPassword: String = ""
        @State private var errorMessage: String = ""

        var body: some View {
            VStack {
                Text("Şifre Değiştir")
                    .font(.headline)
                    .padding(.top)
                
                SecureField("Mevcut Şifre", text: $currentPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.vertical)
                
                SecureField("Yeni Şifre", text: $newPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.vertical)
                
                SecureField("Yeni Şifreyi Onayla", text: $confirmationPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.vertical)
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.top, 10)
                }

                Button(action: {
                    changePassword()
                }) {
                    Text("Şifreyi Değiştir")
                        .font(.body)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                        .frame(maxWidth: .infinity)
                }
                .padding(.top, 10)
            }
            .padding()
        }
        
        private func changePassword() {
            guard !currentPassword.isEmpty, !newPassword.isEmpty, !confirmationPassword.isEmpty else {
                errorMessage = "Tüm alanları doldurduğunuzdan emin olun."
                return
            }
            
            if newPassword != confirmationPassword {
                errorMessage = "Yeni şifreler eşleşmiyor."
                return
            }
            
            // Re-authenticate user to change password
            guard let user = Auth.auth().currentUser else {
                errorMessage = "Kullanıcı oturum açmamış."
                return
            }
            
            let credential = EmailAuthProvider.credential(withEmail: user.email!, password: currentPassword)
            
            user.reauthenticate(with: credential) { result, error in
                if let error = error {
                    errorMessage = "Mevcut şifre yanlış: \(error.localizedDescription)"
                    return
                }
                
                // Update password
                user.updatePassword(to: newPassword) { error in
                    if let error = error {
                        errorMessage = "Şifre değiştirilemedi: \(error.localizedDescription)"
                    } else {
                        isPresented = false
                        errorMessage = ""
                    }
                }
            }
        }
    }
    
    struct ContentView: View {
        @State private var isSettingsActive: Bool = false

        var body: some View {
            VStack {
                Text("Ana Sayfa")
                    .font(.largeTitle)
                    .padding()
                
                // Ayarlar Butonu
                Button(action: {
                    isSettingsActive = true // Ayarlar sayfasını aktif yap
                }) {
                    Text("Ayarlar")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
                .fullScreenCover(isPresented: $isSettingsActive) {
                    SettingsTabView() // Butona tıklanınca gösterilecek görünüm
                }
            }
        }
    }
   
    
   
    struct SettingsTabView: View {
        @State private var notificationsEnabled: Bool = true
        @State private var selectedTheme: String = "Light"
        @State private var username: String = ""
        @State private var email: String = ""
        @State private var userData: [String: Any] = [:]
        private var db = Firestore.firestore()
        @State private var currentUser: User? = Auth.auth().currentUser
        @Environment(\.colorScheme) var colorScheme
        @State private var timeSpent: Int = 0
        @State private var player: AVAudioPlayer?
        @State private var isKVKKAccepted: Bool = false

        var body: some View {
            NavigationView {
                ZStack {
                    

                    List {
                        // Profil Bilgileri Bölümü
                        Section(header: Text("Hesap Bilgileri")) {
                            HStack {
                                Text("Kullanıcı Adı:")
                                Spacer()
                                Text(username.isEmpty ? "Yükleniyor..." : username)
                                    .foregroundColor(.gray)
                            }
                            
                            HStack {
                                Text("E-posta:")
                                Spacer()
                                Text(email.isEmpty ? "Yükleniyor..." : email)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        // Genel Ayarlar Bölümü
                        Section(header: Text("Genel Ayarlar")) {
                            Toggle("Bildirimler", isOn: $notificationsEnabled)
                            
                            Picker("Tema Seçimi", selection: $selectedTheme) {
                                Text("Light").tag("Light")
                                Text("Dark").tag("Dark")
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .onChange(of: selectedTheme) { value in
                                updateAppTheme(value)
                            }
                        }
                        
                        // Uygulama Ayarları
                        Section(header: Text("Uygulama Ayarları")) {
                            NavigationLink(destination: NotificationSettingsView()) {
                                SettingsRow(icon: "bell.fill", color: .red, title: "Bildirimler")
                            }
                            NavigationLink(destination: SoundAndTouchSettingsView()) {
                                SettingsRow(icon: "speaker.wave.2.fill", color: .pink, title: "Ses ve Dokunuş")
                            }
                            
                            NavigationLink(destination: ScreenTimeSettingsView(timeSpent: $timeSpent)) {
                                SettingsRow(icon: "hourglass", color: .blue, title: "Ekran Süresi: \(timeSpent) dk")
                            }
                        }
                        
                        // Güvenlik
                        Section(header: Text("Güvenlik")) {
                            NavigationLink(destination: FaceIDSettingsView()) {
                                SettingsRow(icon: "faceid", color: .green, title: "Face ID ve Parola")
                            }
                            
                            NavigationLink(destination: PrivacyAndSecuritySettingsView(isKVKKAccepted: $isKVKKAccepted)) {
                                SettingsRow(icon: "hand.raised.fill", color: .blue, title: "Gizlilik ve Güvenlik")
                            }
                        }
                        
                        // Diğer Ayarlar
                        Section(header: Text("Diğer Ayarlar")) {
                            NavigationLink(destination: WalletSettingsView()) {
                                SettingsRow(icon: "wallet.pass.fill", color: .black, title: "Cüzdan")
                            }
                            
                            NavigationLink(destination: iCloudSettingsView()) {
                                SettingsRow(icon: "icloud.fill", color: .blue, title: "iCloud")
                            }
                        }
                        
                        // Çıkış Yap Butonu
                        Section {
                            Button(action: {
                                do {
                                    try Auth.auth().signOut()
                                } catch {
                                    print("Çıkış hatası: \(error.localizedDescription)")
                                }
                            }) {
                                HStack {
                                    Image(systemName: "arrow.right.circle.fill")
                                        .foregroundColor(.red)
                                    Text("Çıkış Yap")
                                        .foregroundColor(.red)
                                        .font(.headline)
                                }
                            }
                        }
                    }
                    
                   
                    
                }
                .onAppear {
                    fetchUserData()
                    applyTheme()
                    trackTime()
                }
            }
        }
        func fetchUserData() {
            guard let currentUser = currentUser else { return }
            db.collection("users").whereField("email", isEqualTo: currentUser.email ?? "").getDocuments { snapshot, error in
                if let error = error {
                    print("Hata: \(error.localizedDescription)")
                    return
                }

                if let snapshot = snapshot, !snapshot.isEmpty {
                    if let document = snapshot.documents.first {
                        let data = document.data()
                        DispatchQueue.main.async {
                            self.username = data["username"] as? String ?? "Bilinmiyor"
                            self.email = data["email"] as? String ?? "Bilinmiyor"
                            print("Kullanıcı verisi çekildi: \(self.username), \(self.email)")
                        }
                    }
                }
            }
        }

        func updateAppTheme(_ theme: String) {
            if theme == "Dark" {
                UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .dark
            } else {
                UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .light
            }
        }

        func applyTheme() {
            if selectedTheme == "Dark" {
                UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .dark
            } else {
                UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .light
            }
        }

        // Ekran süresi sayaç
        func trackTime() {
            guard let currentUser = currentUser else { return }
            let userRef = db.collection("users").document(currentUser.uid)
            userRef.updateData([
                "time": FieldValue.increment(Int64(1))
            ]) { error in
                if let error = error {
                    print("Zaman güncelleme hatası: \(error.localizedDescription)")
                } else {
                    print("Zaman güncellendi.")
                }
            }
        }
    }

    struct SettingsRow: View {
        var icon: String
        var color: Color
        var title: String

        var body: some View {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.white)
                    .frame(width: 30, height: 30)
                    .background(color)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                Text(title)
                    .font(.system(size: 16, weight: .regular))
            }
        }
    }

  

    struct SoundAndTouchSettingsView: View {
        @State private var selectedSound: String = "system"

        var body: some View {
            VStack {
                Text("Bildirim Sesi Seçimi")
                Picker("Ses", selection: $selectedSound) {
                    Text("Sistem Sesi").tag("system")
                    Text("Ses 1").tag("sound1")
                    Text("Ses 2").tag("sound2")
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        }
    }

    struct ScreenTimeSettingsView: View {
        @Binding var timeSpent: Int
        @State private var timer: Timer?
        @State private var isTracking = false
        @State private var isLoggedIn = false
        private var db = Firestore.firestore()
        
        // Firebase authentication check
        init(timeSpent: Binding<Int>) {
            _timeSpent = timeSpent
        }

        var body: some View {
            VStack {
                // Başlık
                Text("Ekran Süresi")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 20)

                // Kullanıcının ekran süresini göster
                Text("Bu ekranı kullanma süreniz: \(timeSpent) dakika")
                    .font(.title)
                    .padding()

                // Sayaç görünümü
                ProgressView(value: Double(timeSpent), total: 60)
                    .progressViewStyle(LinearProgressViewStyle())
                    .padding(.top, 20)
                    .accentColor(.blue)
                
                // Sayaç ilerledikçe renk değişir
                Circle()
                    .trim(from: 0, to: CGFloat(min(Double(timeSpent) / 60.0, 1.0)))
                    .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .foregroundColor(.blue)
                    .frame(width: 150, height: 150)
                    .rotationEffect(Angle(degrees: -90))
                    .padding(.top, 40)
                    .animation(.linear(duration: 1), value: timeSpent)

                Spacer()
                
            }
            .padding()
            .onAppear {
                // Kullanıcı giriş kontrolü ve sayaç başlatma
                checkUserLogin()
            }
            .onDisappear {
                self.stopTracking()
            }
        }

        // Kullanıcı girişi kontrolü ve sayaç başlatma
        func checkUserLogin() {
            guard let currentUser = Auth.auth().currentUser else {
                print("Kullanıcı giriş yapmamış.")
                return
            }
            
            self.isLoggedIn = true
            self.startTracking() // Kullanıcı giriş yaptıysa sayaç başlar
            
            // Firebase'ten kullanıcı ekran süresi verisini al
            loadTimeSpentFromFirebase()
        }
        
        // Ekran süresi takibini başlat
        func startTracking() {
            self.isTracking = true
            self.timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                self.timeSpent += 1
                self.saveTimeSpent()
            }
        }

        // Ekran süresi takibini durdur
        func stopTracking() {
            self.isTracking = false
            self.timer?.invalidate()
            self.timer = nil
        }

        // Firebase'e ekran süresi verilerini kaydet
        func saveTimeSpent() {
            guard let currentUser = Auth.auth().currentUser else { return }

            db.collection("users").document(currentUser.uid).updateData([
                "time": timeSpent
            ]) { error in
                if let error = error {
                    print("Ekran süresi kaydedilemedi: \(error.localizedDescription)")
                } else {
                    print("Ekran süresi başarıyla kaydedildi: \(self.timeSpent) dakika")
                }
            }
        }

        // Firebase'ten kullanıcı ekran süresi verisini al
        func loadTimeSpentFromFirebase() {
            guard let currentUser = Auth.auth().currentUser else { return }

            db.collection("users").document(currentUser.uid).getDocument { document, error in
                if let document = document, document.exists {
                    if let time = document.data()?["time"] as? Int {
                        self.timeSpent = time
                    }
                } else {
                    print("Ekran süresi verisi alınamadı: \(error?.localizedDescription ?? "Bilinmeyen hata")")
                }
            }
        }
    }
    struct FaceIDSettingsView: View {
        var body: some View {
            Text("Parola Ayarları")
        }
    }

    struct PrivacyAndSecuritySettingsView: View {
       
        @Binding var isKVKKAccepted: Bool
        @State private var isShowingText = false
        var body: some View {
               VStack {
                   Button(action: {
                       withAnimation {
                           isShowingText.toggle()
                       }
                   }) {
                       HStack {
                           Text(isShowingText ? "Metni Kapat" : "KVKK Metnini Görüntüle")
                               .font(.headline)
                               .foregroundColor(.blue)
                           Image(systemName: isShowingText ? "chevron.up" : "chevron.down")
                               .foregroundColor(.blue)
                       }
                       .padding()
                   }

                   if isShowingText {
                       VStack {
                           Text("KVKK Metni: Lütfen kişisel verilerinizin korunması hakkında bilgi alın. Verilerinizin toplama, işleme ve saklama işlemleri hakkında detaylı bilgiye buradan ulaşabilirsiniz. Bu onay, kişisel verilerinizin güvenliğini sağlamayı hedefler.2.KİŞİSEL VERİLERİN İŞLENME AMACI")
                                
                                Text("Kişisel veriler, Kanun’un 5. ve 6. maddelerinde belirtilen kişisel veri işleme şartları ile Kanun’da belirtilen amaçlar çerçevesinde ve sınırlı olmamak kaydıyla aşağıda belirtilen amaçlarla işlenmektedir. Buna göre kişisel verilerin işlenme amacı;Çalışanlar, çalışan adayları, stajyer, habere konu kişi, potansiyel ürün veya hizmet alıcısı, ürün veya hizmet alıcısı, tedarikçi çalışanı, tedarikçi yetkilisi, veli/vasi/temsilci, ziyaretçi ve diğer vatandaşlardan toplanan kişisel veriler, Kanun’un 8. ve 9. maddelerinde belirtilen şartlar çerçevesinde VERİ SORUMLUSU’nun tedarikçileri, hizmet sağlayıcıları, veri işleyenleri ve yasal olarak yetkili kurum ve kuruluşlar ile, ilgili mevzuatlar çerçevesinde, kişisel veri işleme şartları ve amaçları doğrultusunda paylaşılabilecektir.")
                                
                               .font(.body)
                               .padding()
                               .frame(maxWidth: .infinity, alignment: .leading)
                               .background(Color.gray.opacity(0.1))
                               .cornerRadius(10)

                           Button("KVKK Onayla") {
                               withAnimation {
                                   isKVKKAccepted = true
                               }
                           }
                           .padding()
                           .background(Color.blue)
                           .foregroundColor(.white)
                           .cornerRadius(8)
                           .padding(.top, 10)

                           if isKVKKAccepted {
                               Text("KVKK Onaylandı! Gizlilik Ayarlarına Yönlendiriliyorsunuz...")
                                   .font(.headline)
                                   .foregroundColor(.green)
                                   .padding(.top, 10)
                           }
                       }
                       .transition(.move(edge: .bottom))
                   }
               }
               .padding()
               .navigationBarTitle("Gizlilik ve Güvenlik", displayMode: .inline)
           }
    }

    struct WalletSettingsView: View {
        var body: some View {
            Text("Cüzdan Ayarları")
        }
    }

    struct iCloudSettingsView: View {
        var body: some View {
            Link("iCloud'a Git", destination: URL(string: "https://www.apple.com/icloud/")!)
        }
    }
    
    


   
    
    
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
    
    
    
    
    //favroite view sayfa içeriği
    struct FavoritesView: View {
        @State private var isLoading = false
        @State private var selectedPage: Int? = nil
        @State private var favoriteItems = Array(repeating: false, count: 10)

        let contentData: [Content] = [
            Content(imageName: "zara", title: "Zara", description: "Zara'da 750 TL MaxiPuan Fırsatı!", maxipuan: "750 TL MaxiPuan", expiryDate: Date().addingTimeInterval(86400 * 3 + 3600 * 5)),
            Content(imageName: "mavi", title: "MAVİ", description: "Mavi'da 1.000 TL MaxiPuan Fırsatı!", maxipuan: "1.000 TL MaxiPuan", expiryDate: Date().addingTimeInterval(86400 * 2 + 3600 * 12)),
            Content(imageName: "boyner", title: "BOYNER", description: "Boyner'de 500 TL MaxiPuan Fırsatı!", maxipuan: "500 TL MaxiPuan", expiryDate: Date().addingTimeInterval(86400 * 5 + 3600 * 3)),
            Content(imageName: "only", title: "ONLY", description: "Only'de 600 TL MaxiPuan Fırsatı!", maxipuan: "600 TL MaxiPuan", expiryDate: Date().addingTimeInterval(86400 * 4)),
            Content(imageName: "nike", title: "Nike", description: "Nike'da 800 TL MaxiPuan Fırsatı!", maxipuan: "800 TL MaxiPuan", expiryDate: Date().addingTimeInterval(86400 * 6 + 3600)),
            Content(imageName: "image6", title: "Adidas", description: "Adidas'ta 700 TL MaxiPuan Fırsatı!", maxipuan: "700 TL MaxiPuan", expiryDate: Date().addingTimeInterval(86400 * 3 + 3600 * 8)),
            Content(imageName: "image7", title: "H&M", description: "H&M'de 900 TL MaxiPuan Fırsatı!", maxipuan: "900 TL MaxiPuan", expiryDate: Date().addingTimeInterval(86400 * 2 + 3600 * 6)),
            Content(imageName: "image8", title: "Pull&Bear", description: "Pull&Bear'de 650 TL MaxiPuan Fırsatı!", maxipuan: "650 TL MaxiPuan", expiryDate: Date().addingTimeInterval(86400 * 4 + 3600 * 9)),
            Content(imageName: "image9", title: "Bershka", description: "Bershka'da 550 TL MaxiPuan Fırsatı!", maxipuan: "550 TL MaxiPuan", expiryDate: Date().addingTimeInterval(86400 * 3 + 3600 * 2)),
            Content(imageName: "image10", title: "Stradivarius", description: "Stradivarius'ta 600 TL MaxiPuan Fırsatı!", maxipuan: "600 TL MaxiPuan", expiryDate: Date().addingTimeInterval(86400 * 7))
        ]

        var body: some View {
            NavigationView {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(contentData.indices, id: \ .self) { index in
                            NavigationLink(
                                destination: PageDetailView(content: contentData[index]),
                                tag: index,
                                selection: $selectedPage
                            ) {
                                ContentCardView(content: contentData[index],
                                                isFavorite: $favoriteItems[index])
                            }
                            .simultaneousGesture(TapGesture().onEnded {
                                showLoadingScreen(for: index)
                            })
                        }
                    }
                    .padding()
                }
                
            }
            .overlay(
                LoadingView(isLoading: $isLoading)
            )
        }

        private func showLoadingScreen(for index: Int) {
            isLoading = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isLoading = false
                selectedPage = index
            }
        }
    }

    struct ContentCardView: View {
        let content: Content
        @Binding var isFavorite: Bool

        var body: some View {
            
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(content.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .cornerRadius(8)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(content.title)
                                .font(.headline)
                            Text(content.description)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            HStack {
                                Text(content.maxipuan)
                                    .font(.subheadline)
                                    .foregroundColor(.pink)
                                Spacer()
                                Text("Son Gün: \(formattedDate(content.expiryDate))")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }
                        }
                        Spacer()
                        Button(action: {
                            isFavorite.toggle()
                        }) {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .foregroundColor(isFavorite ? .red : .gray)
                                .font(.title3)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(radius: 4)
                }
            
        }
        private func formattedDate(_ date: Date) -> String {
              let formatter = DateFormatter()
              formatter.dateFormat = "dd.MM.yyyy"
              return formatter.string(from: date)
          }
    }

    struct PageDetailView: View {
        let content: Content
        @State private var showMessage = false
        @State private var remainingTime: String = ""
        @State private var isParticipated = false

        var body: some View {
            ScrollView {  // <-- ScrollView starts here
                VStack(spacing: 16) {
                    Image(content.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(8)
                    Text(content.title)
                        .font(.title)
                        .bold()
                    Text(content.description)
                        .font(.body)
                        .padding()
                    Text("Kampanyanın Bitmesine: \(remainingTime)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .onAppear {
                            startTimer()
                        }
                    Text(content.maxipuan)
                        .font(.headline)
                        .foregroundColor(.pink)
                    Spacer()
                    Button(action: {
                        participateInCampaign()
                    }) {
                        Text(isParticipated ? "Katıldınız" : "Katıl")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(isParticipated ? Color.green : Color.blue)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    .disabled(isParticipated)
                    .alert(isPresented: $showMessage) {
                        Alert(title: Text("Katılımınız Onaylandı"),
                              message: Text("E-posta adresinize onay mesajı gönderildi."),
                              dismissButton: .default(Text("Tamam")))
                    }
                }
                .padding()
            }
        }
            private func startTimer() {
                Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                    let currentTime = Date()
                    if content.expiryDate > currentTime {
                        let interval = content.expiryDate.timeIntervalSince(currentTime)
                        remainingTime = formatTimeRemaining(interval)
                    } else {
                        remainingTime = "Süre Doldu"
                        timer.invalidate()
                    }
                }
                
            
        }

        private func formatTimeRemaining(_ interval: TimeInterval) -> String {
            let days = Int(interval) / 86400
            let hours = (Int(interval) % 86400) / 3600
            let minutes = (Int(interval) % 3600) / 60
            return "\(days) Gün \(hours) Saat \(minutes) Dakika"
        }

        private func participateInCampaign() {
            guard let user = Auth.auth().currentUser else { return }

            // Firestore'dan kullanıcının telefon numarasını almak
            let userRef = Firestore.firestore().collection("users").document(user.uid)
            userRef.getDocument { (document, error) in
                if let error = error {
                    print("Kullanıcı bilgisi alınırken hata oluştu: \(error.localizedDescription)")
                    return
                }
                
                if let document = document, document.exists {
                    let userPhoneNumber = document.data()?["phoneNumber"] as? String ?? ""
                    self.sendSMS(to: userPhoneNumber)
                    self.isParticipated = true
                    self.showMessage = true
                } else {
                    print("Doküman bulunamadı")
                }
            }
        }

        private func sendSMS(to phoneNumber: String) {
            let messageContent = "\(content.title): \(content.description) \(content.maxipuan) \(formattedDate(content.expiryDate)) tarihine kadar geçerlidir."
            let parameters: [String: Any] = [
                "phoneNumber": phoneNumber,
                "message": messageContent
            ]

            Firestore.firestore().collection("smsRequests").addDocument(data: parameters) { error in
                if let error = error {
                    print("SMS gönderim hatası: \(error.localizedDescription)")
                } else {
                    print("SMS gönderildi: \(phoneNumber)")
                }
            }
        }
            private func formattedDate(_ date: Date) -> String {
                let formatter = DateFormatter()
                formatter.dateFormat = "dd.MM.yyyy"
                return formatter.string(from: date)
            
          }
    }

    struct LoadingView: View {
        @Binding var isLoading: Bool

        var body: some View {
            if isLoading {
                ZStack {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                    ProgressView("Yükleniyor...")
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                }
            }
        }
    }

    struct Content {
        let imageName: String
        let title: String
        let description: String
        let maxipuan: String
        let expiryDate: Date
    }

  

   
    
    
 
    
}// homescreen view son







    struct HomeScreen_Previews: PreviewProvider {
        static var previews: some View {
            HomeScreen()
        }
    }
    

