import SwiftUI

struct CourseView: View {
    var courseTitle: String
    @State private var isLoading = true

    var body: some View {
        VStack {
            if isLoading {
                VStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .padding()
                    
                    Text("Kurs Yükleniyor...")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .padding(.bottom, 20)
                    
                    
                }
                .onAppear {
                    // 2 saniye sonra yükleme tamamlanacak
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        isLoading = false
                    }
                }
            } else {
                Text("\(courseTitle) Kurs İçeriği")
                    .font(.title)
                    .padding()
                // Kurs içeriği buraya eklenebilir
            }
        }
        .navigationBarTitle(courseTitle, displayMode: .inline)
        .padding()
    }
}
