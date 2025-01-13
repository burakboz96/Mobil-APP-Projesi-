import Foundation

// Arabaların bilgilerini almak için model
struct Car: Decodable {
    let make: String
    let model: String
    let year: Int
}

// API'den araba verilerini çeken fonksiyon
func fetchCarData() {
    guard let url = URL(string: "https://www.carqueryapi.com/api/0.3/?callback=?&cmd=getMakes") else { return }
    
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        guard let data = data, error == nil else {
            print("Error fetching data: \(String(describing: error))")
            return
        }
        
        do {
            // JSON verisini parse et
            let carMakes = try JSONDecoder().decode([String: [String]].self, from: data)
            print(carMakes)
        } catch {
            print("Error parsing JSON: \(error)")
        }
    }
    
    task.resume()
}

