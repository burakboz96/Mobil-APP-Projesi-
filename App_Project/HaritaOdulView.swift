import SwiftUI
import MapKit
import CoreLocation

// Ödül Modeli
struct RewardLocation: Identifiable {
    let id = UUID() // Benzersiz kimlik
    let coordinate: CLLocationCoordinate2D
}

// Konum Yöneticisi
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var userHeading: CLHeading? // Kullanıcı yönü
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading() // Yön bilgisini güncellemek için
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location.coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        userHeading = newHeading // Yön bilgisini güncelle
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}

struct HaritaOdulView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 38.6786, longitude: 39.2205), // Elazığ, Türkiye koordinatları
        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
    )
    
    @ObservedObject var locationManager = LocationManager()
    
    @State private var rewards = [RewardLocation]()
    @State private var showingSheet = false // Yarım sheet için durum değişkeni
    @State private var selectedReward: RewardLocation?
    
    let elazigCenter = CLLocationCoordinate2D(latitude: 38.6786, longitude: 39.2205) // Elazığ merkezi
    
    func generateRandomRewards() {
        rewards = []
        
        for _ in 1...10 {
            let randomLatitude = Double.random(in: 38.6750...38.6850)
            let randomLongitude = Double.random(in: 39.2150...39.2250)
            let rewardLocation = RewardLocation(coordinate: CLLocationCoordinate2D(latitude: randomLatitude, longitude: randomLongitude))
            rewards.append(rewardLocation)
        }
    }
    
    func distance(from userLocation: CLLocationCoordinate2D, to rewardLocation: CLLocationCoordinate2D) -> CLLocationDistance {
        let userCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let rewardCLLocation = CLLocation(latitude: rewardLocation.latitude, longitude: rewardLocation.longitude)
        return userCLLocation.distance(from: rewardCLLocation)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Harita
                Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: rewards) { reward in
                    MapAnnotation(coordinate: reward.coordinate) {
                        VStack {
                            Image(systemName: "gift.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.red)
                            Text("Ödül")
                                .font(.caption)
                                .foregroundColor(.black)
                        }
                        .onTapGesture {
                            selectedReward = reward
                            showingSheet.toggle()
                        }
                    }
                }
                .edgesIgnoringSafeArea(.all)
                
                // Kullanıcıya en yakın ödülü bulma
                if let userLocation = locationManager.userLocation {
                    ForEach(rewards) { reward in
                        let distance = distance(from: userLocation, to: reward.coordinate)
                        if distance < 20 { // 20 metre yakınlık
                            Text("Hediye Kazandınız!")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(10)
                                .position(x: 150, y: 100)
                        }
                    }
                }
                
                VStack {
                    // Back butonu
                    HStack {
                        Button(action: {
                            // Ana ekrana dönme
                        }) {
                            Image(systemName: "arrow.left.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.blue)
                        }
                        Spacer()
                    }
                    .padding()
                    
                    Spacer()
                    
                    // Yarım Sheet için buton
                    Button(action: {
                        showingSheet.toggle()
                    }) {
                        Text("Yardım")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                    .padding()
                }
                
                // Kullanıcı yönü
                if let heading = locationManager.userHeading {
                    Text("Yön: \(Int(heading.trueHeading))°")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(10)
                        .position(x: UIScreen.main.bounds.width - 80, y: 50) // Yönü sağ üst köşede göster
                }
            }
            .onAppear {
                generateRandomRewards()
            }
            .sheet(isPresented: $showingSheet) {
                VStack {
                    Text("Yapmanız Gerekenler")
                        .font(.title)
                        .padding()
                    Text("1. Haritada ödülleri bulmak için etrafı keşfedin.\n2. Konumunuzu işaretlemek için aşağıdaki butona tıklayın.")
                        .padding()
                    Button(action: {
                        if let userLocation = locationManager.userLocation {
                            region.center = userLocation
                        }
                    }) {
                        Text("Konumunuzu İşaretleyin")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                    .padding()
                }
            }
        }
    }
}

struct HaritaOdulView_Previews: PreviewProvider {
    static var previews: some View {
        HaritaOdulView()
    }
}

