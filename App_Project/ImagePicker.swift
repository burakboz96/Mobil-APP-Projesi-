import SwiftUI
import UIKit

// ImagePicker SwiftUI bileşeni
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var isImagePickerPresented: Bool // Görüntü seçici açılıp kapanmasını kontrol etmek için
    @Binding var selectedImage: UIImage? // Seçilen fotoğrafı tutar
    
    // Coordinator sınıfı, UIImagePickerController delegesi olarak çalışır.
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePicker
        
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        // İptal işlemi
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isImagePickerPresented = false // Seçici iptal edildiyse kapat
        }
        
        // Fotoğraf seçildiğinde
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image // Seçilen fotoğrafı kaydet
            }
            parent.isImagePickerPresented = false // Seçim yapıldıktan sonra kapat
        }
    }
    
    // Coordinator'ı oluşturur
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    // UIImagePickerController'ı oluşturur
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator // Delegate olarak Coordinator kullanılıyor
        picker.sourceType = .photoLibrary // Galeriden fotoğraf seçme
        return picker
    }
    
    // SwiftUI güncellemelerini uygular (şu an gerek yok)
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

