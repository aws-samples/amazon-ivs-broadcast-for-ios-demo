//
//  NetworkMonitor.swift
//  Broadcasting
//
//  Created by Uldis Zingis on 29/06/2021.
//

import Network

class MonitorNetwork {
    private var networkMonitor = NWPathMonitor()
    private var onNetworkAvailable: () -> Void

    init(onNetworkAvailable: @escaping () -> Void) {
        self.onNetworkAvailable = onNetworkAvailable

        networkMonitor.pathUpdateHandler = { [weak self] path in
            if path.status == .satisfied {
                self?.onNetworkAvailable()
                self?.networkMonitor.cancel()
            }
        }

        networkMonitor.start(queue: DispatchQueue(label: "NetworkMonitor"))
    }
}
