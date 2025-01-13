import FirebaseStorage
import UIKit

class ImageUploader {
    static func uploadImageToStorage(image: UIImage, userId: String, imageName: String, completion: @escaping (String?) -> Void) {
        let storage = Storage.storage()
        let storageRef = storage.reference().child("images/\(userId)/\(imageName).jpg")
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(nil)
            return
        }
        
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Resim yükleme hatası: \(error.localizedDescription)")
                completion(nil)
            } else {
                storageRef.downloadURL { url, error in
                    if let error = error {
                        print("URL alırken hata: \(error.localizedDescription)")
                        completion(nil)
                    } else {
                        if let imageURL = url?.absoluteString {
                            completion(imageURL)
                        } else {
                            completion(nil)
                        }
                    }
                }
            }
        }
    }
}

