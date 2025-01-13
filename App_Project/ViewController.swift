import UIKit

class ViewController: UIViewController {

    // Uyarıyı gösterecek değişken
    var noInternetAlert: UIAlertController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // İnternet bağlantısı durumu değiştiğinde bildirimi al
        NotificationCenter.default.addObserver(self, selector: #selector(handleNoInternet), name: .noInternetConnection, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleInternetRestored), name: .internetConnectionRestored, object: nil)
    }
    
    @objc func handleNoInternet() {
        showNoInternetAlert()
    }
    
    @objc func handleInternetRestored() {
        dismissNoInternetAlert()
    }
    
    func showNoInternetAlert() {
        // Eğer önceden bir uyarı gösteriliyorsa, yeni uyarı gösterilmeden önce eski uyarıyı kaldırıyoruz
        if noInternetAlert == nil {
            noInternetAlert = UIAlertController(title: "İnternet Bağlantısı",
                                                 message: "İnternet bağlantınız kesildi. Lütfen bir ağa bağlanın.",
                                                 preferredStyle: .alert)
            noInternetAlert?.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
            self.present(noInternetAlert!, animated: true, completion: nil)
        }
    }
    
    func dismissNoInternetAlert() {
        noInternetAlert?.dismiss(animated: true, completion: nil)
        noInternetAlert = nil
    }
}

