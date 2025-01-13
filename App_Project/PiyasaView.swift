import SwiftUI

// BorsaVerileriResponse Yapısı
struct BorsaVerileriResponse: Codable {
    let success: Bool
    let result: [Result]
    
    struct Result: Codable {
        let currency: String
        let name: String
        let pricestr: String
        let price: Double
        let rate: Double
        let time: String
    }
}

struct PiyasaView: View {
    @State private var borsaVerileri: [BorsaVerileriResponse.Result] = []  // API'den çekilen verileri saklamak için
    @State private var filteredBorsaVerileri: [BorsaVerileriResponse.Result] = []  // Arama filtrelenmiş verileri
    @State private var errorMessage: String?  // Hata mesajı için
    @State private var isRefreshing = false  // Yenileme durumu
    @State private var searchQuery = ""  // Arama sorgusu
    
    private let apiKey = "6xCmksFJC4t1m8HLbaodaB:27tDYGQpJ70L7Y9F3RWEmH" // API anahtarınız

    var body: some View {
        NavigationView {
            VStack {
                // Arama kutusu
                TextField("Ara...", text: $searchQuery)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .onChange(of: searchQuery) { _ in
                        filterResults()
                    }
                
                // Yenileme butonu ve mesaj
                if let errorMessage = errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                }

                // ScrollView ile verileri göster
                ScrollView {
                    VStack(spacing: 20) {
                        // Eğer veriler varsa göster
                        if !filteredBorsaVerileri.isEmpty {
                            ForEach(filteredBorsaVerileri, id: \.name) { veriler in
                                VStack(alignment: .leading) {
                                    Text("Currency: \(veriler.currency) - \(veriler.name)")
                                        .font(.headline)
                                        .foregroundColor(.blue)
                                    Text("Price: \(veriler.pricestr)")
                                        .font(.subheadline)
                                    Text("Rate: \(veriler.rate, specifier: "%.2f")")
                                        .font(.subheadline)
                                    Text("Time: \(veriler.time)")
                                        .font(.subheadline)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                            }
                        } else {
                            Text("Veri bulunamadı.")
                                .font(.headline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                }
                .refreshable {
                    // Yenileme sırasında veri çekme
                    fetchBorsaVerileri()
                }
            }
            .navigationBarTitle("Borsa Verileri", displayMode: .inline)
            .onAppear {
                // Ekran yüklendiğinde veri çekme fonksiyonunu çalıştır
                fetchBorsaVerileri()
            }
        }
    }

    func fetchBorsaVerileri() {
        isRefreshing = true  // Yenileme başladığında işareti
        let headers = [
            "content-type": "application/json",
            "authorization": "apikey \(apiKey)"
        ]
        
        let urlString = "https://api.collectapi.com/economy/liveBorsa"
        guard let url = URL(string: urlString) else {
            errorMessage = "Geçersiz URL"
            isRefreshing = false  // Yenileme işlemi bitti
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isRefreshing = false  // Yenileme işlemi bitti
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Veri çekme hatası: \(error.localizedDescription)"
                }
                return
            }
            
            // HTTP yanıtını kontrol et
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Durum Kodu: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    DispatchQueue.main.async {
                        self.errorMessage = "HTTP Hata: \(httpResponse.statusCode)"
                    }
                    return
                }
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "Veri alınamadı"
                }
                return
            }
            
            // JSON verisini yazdırma
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Gelen JSON Verisi: \(jsonString)")
            }
            
            do {
                // JSON verisini çözümleme
                let borsaVerileri = try JSONDecoder().decode(BorsaVerileriResponse.self, from: data)
                DispatchQueue.main.async {
                    // Veriyi alıp UI'da göster
                    self.borsaVerileri = borsaVerileri.result
                    self.filteredBorsaVerileri = borsaVerileri.result // İlk başta tüm veriyi göster
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Veri çözümleme hatası: \(error.localizedDescription)"
                }
            }
        }
        
        dataTask.resume()
    }
    
    func filterResults() {
        if searchQuery.isEmpty {
            filteredBorsaVerileri = borsaVerileri // Arama boşsa tüm veriyi göster
        } else {
            filteredBorsaVerileri = borsaVerileri.filter {
                $0.name.lowercased().contains(searchQuery.lowercased()) ||
                $0.currency.lowercased().contains(searchQuery.lowercased())
            }
        }
    }
}

struct PiyasaView_Previews: PreviewProvider {
    static var previews: some View {
        PiyasaView()
            .previewLayout(.sizeThatFits)
            .padding()
    }
}

