import SwiftUI
import SceneKit

struct CarModel3D: View {
    @State private var selectedCar = "Tesla Model"
    
    let carModels = ["Tesla Model", "Audi Model", "Porsche Model"]
    let modelNames = ["Tesla_Model.usdz", "Audi_Model.usdz", "Porche_Model.usdz"]
    
    var body: some View {
        NavigationView {
            VStack {
                // Başlık
                Text("Araba 3D İnceleme")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                // Araç Seçim Picker
                Picker("Araç Seç", selection: $selectedCar) {
                    ForEach(carModels, id: \.self) { car in
                        Text(car).tag(car)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Seçilen araca göre model adı ve USDZ dosyasını belirle
                let selectedModelName = modelNames[carModels.firstIndex(of: selectedCar) ?? 0]
                
                // 3D Model Görüntüleme Alanı
                SceneView(
                    scene: SCNScene(named: selectedModelName), // Seçilen 3D Model dosyası
                    options: [.autoenablesDefaultLighting, .allowsCameraControl] // Kamera kontrolü ve ışık desteği
                )
                .frame(height: 400)
                .cornerRadius(12)
                .padding()
                
                // Kullanıcı Bilgilendirme
                Text("Aracı döndürmek ve yakınlaştırmak için ekrana dokunun ve sürükleyin.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                
                Spacer()
                
                // Geri Dön Butonu
                Button(action: {
                    // Geri dönüş eylemi, Navigation'dan geri gider.
                }) {
                    Text("Ana Sayfaya Dön")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .navigationBarTitle("\(selectedCar) Detayı", displayMode: .inline)
        }
    }
}

struct CarModel3D_Previews: PreviewProvider {
    static var previews: some View {
        CarModel3D()
    }
}

