import SwiftUI
import Firebase
import FirebaseAuth

struct SatınAlmaView: View {
    @State private var cardNumber: String = ""
    @State private var expiryDate: Date = Date()
    @State private var cvv: String = ""
    @State private var cardHolderName: String = ""
    @State private var isCardFlipped: Bool = false
    @State private var saveCard: Bool = false
    @State private var showDatePickerSheet: Bool = false // State to control the sheet
    
    var cardType: String {
        if cardNumber.first == "4" {
            return "Visa"
        } else if cardNumber.first == "5" {
            return "MasterCard"
        } else if cardNumber.first == "6" {
            return "Troy"
        } else if cardNumber.first == "7" {
            return "American Express"
        } else {
            return "Unknown"
        }
    }
    
    var cardImage: String {
        switch cardType {
        case "Visa":
            return "visa_logo"
        case "MasterCard":
            return "mastercard_logo"
        case "Troy":
            return "troy_logo"
        case "American Express":
            return "amex_logo"
        default:
            return "unknown_logo"
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Ödeme Ekranı")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 40)
            
            // Kredi Kartı Görünümü
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(height: 200)
                    .overlay(
                        VStack {
                            if isCardFlipped {
                                // Kartın arka yüzü (CVV kısmı)
                                HStack {
                                    Spacer()
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.black.opacity(0.8))
                                        .frame(height: 40)
                                        .padding(.horizontal)
                                }
                                .padding(.top, 50)
                                
                                Text("CVV: \(cvv)")
                                    .foregroundColor(.white)
                                    .font(.headline)
                                    .padding(.top, 20)
                            } else {
                                // Kartın ön yüzü
                                VStack(alignment: .leading, spacing: 10) {
                                    Text(cardType)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding(.top, 10)
                                    
                                    Text(cardNumber.isEmpty ? "XXXX XXXX XXXX XXXX" : cardNumber)
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                    
                                    HStack {
                                        Text(expiryDate, style: .date)
                                            .foregroundColor(.white)
                                            .font(.subheadline)
                                        Spacer()
                                        Image(cardImage)
                                            .resizable()
                                            .frame(width: 50, height: 30)
                                            .cornerRadius(5)
                                    }
                                    
                                    Text(cardHolderName.isEmpty ? "Kart Sahibi" : cardHolderName)
                                        .foregroundColor(.white)
                                        .font(.subheadline)
                                        .padding(.top, 5)
                                }
                                .padding()
                            }
                        }
                    )
                    .rotation3DEffect(
                        .degrees(isCardFlipped ? 180 : 0),
                        axis: (x: 0, y: 1, z: 0)
                    )
                    .animation(.easeInOut, value: isCardFlipped)
            }
            .padding(.horizontal, 20)
            
            // Form Alanları
            VStack(spacing: 15) {
                TextField("Kart Numarası", text: $cardNumber)
                    .keyboardType(.default)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: cardNumber) { _ in
                        if cardNumber.count > 16 {
                            cardNumber = String(cardNumber.prefix(16))
                        }
                    }
                
                // Expiry Date - Button to open the sheet for selecting the date
                Button(action: {
                    showDatePickerSheet.toggle()
                }) {
                    HStack {
                        Text("Son Kullanma Tarihi")
                            .foregroundColor(.black)
                        Spacer()
                        Text(expiryDate, style: .date)
                            .foregroundColor(.black)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray))
                }
                
                TextField("CVV", text: $cvv)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onTapGesture {
                        isCardFlipped = true
                    }
                    .onChange(of: cvv) { _ in
                        if cvv.count > 3 {
                            cvv = String(cvv.prefix(3))
                        }
                    }
                    .onDisappear {
                        isCardFlipped = false
                    }
                
                TextField("Kart Sahibi İsmi", text: $cardHolderName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.horizontal, 20)
            
            Toggle("Kartı Kaydet", isOn: $saveCard)
                .padding(.horizontal, 20)
            
            Spacer()
            
            // Ödeme Butonu
            Button(action: {
                if saveCard {
                    saveCardToFirebase()
                } else {
                    print("Ödeme işlemi tamamlandı.")
                }
            }) {
                Text(saveCard ? "Kartı Kaydet ve Ödemeyi Tamamla" : "Ödemeyi Tamamla")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 20)
        }
        .padding()
        .navigationTitle("Satın Alma")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showDatePickerSheet) {
            
            Text("Son Kullanma Tarihi ")
            .font(.title2)
            .fontWeight(.bold)
            .padding(.top, 10)
                
            // Date Picker Sheet
            DatePicker("  ", selection: $expiryDate, displayedComponents: .date)
           
                .datePickerStyle(WheelDatePickerStyle())
                .padding()
            
            Button("Tamam") {
                               showDatePickerSheet = false // Dismiss the sheet
                
                           }
        }
    }
    
    func saveCardToFirebase() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Kullanıcı oturum açmamış.")
            return
        }
        
        let cardData: [String: Any] = [
            "cardNumber": cardNumber,
            "expiryDate": expiryDate,
            "cvv": cvv,
            "cardHolderName": cardHolderName
        ]
        
        let db = Firestore.firestore()
        db.collection("users").document(userID).collection("cardDetails").addDocument(data: cardData) { error in
            if let error = error {
                print("Kart bilgileri kaydedilirken hata oluştu: \(error.localizedDescription)")
            } else {
                print("Kart bilgileri başarıyla kaydedildi.")
            }
        }
    }
}

struct SatınAlmaViewPreview: PreviewProvider {
    static var previews: some View {
        SatınAlmaView()
    }
}

