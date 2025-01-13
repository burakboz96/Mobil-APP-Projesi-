import Foundation
import Network

class NetworkManager {

    static let shared = NetworkManager()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitorQueue")

    var isConnected: Bool = true

    private init() {}

    func startMonitoring() {
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { path in
            if path.status == .unsatisfied {
                self.isConnected = false
                NotificationCenter.default.post(name: .noInternetConnection, object: nil)
            } else {
                self.isConnected = true
                NotificationCenter.default.post(name: .internetConnectionRestored, object: nil)
            }
        }
    }
}

