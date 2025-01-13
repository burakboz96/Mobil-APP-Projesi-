import FirebaseFirestore

class FirestoreManager {
    static func addFavoriteItem(userId: String, name: String, imageName: String, image: UIImage, description: String) {
        ImageUploader.uploadImageToStorage(image: image, userId: userId, imageName: imageName) { imageURL in
            if let imageURL = imageURL {
                let db = Firestore.firestore()
                
                let favoriteData: [String: Any] = [
                    "userId": userId,
                    "name": name,
                    "imageName": imageName,
                    "imageURL": imageURL, // Firebase Storage URL'si
                    "description": description
                ]
                
                db.collection("favorites").addDocument(data: favoriteData) { error in
                    if let error = error {
                        print("Favori öğesi eklenemedi: \(error.localizedDescription)")
                    } else {
                        print("Favori öğesi başarıyla eklendi.")
                    }
                }
            } else {
                print("Resim URL'si alınamadı.")
            }
        }
    }
}

