//
//  ElapsedTimeManager.swift
//  Broadcasting
//
//  Created by Uldis Zingis on 28/06/2021.
//

import Foundation

class ElapsedTimeAndDataManager: ObservableObject {
    @Published var timeElapsed: String = ""
    @Published var dataUsed: String = "0 KB"

    private var isRunning: Bool = false
    private var timer = Timer()
    private var elapsed: Int = 0 {
        didSet {
            timeElapsed = formatToTimeString(elapsed)
        }
    }
    private var dataUsedBeforeStart: Int = 0
    private let byteCountFormatter = ByteCountFormatter()

    func start() {
        guard !isRunning else { return }
        dataUsedBeforeStart = DeviceDataUsage.dataUsed
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            self?.elapsed += 1
            let usedBefore = self?.dataUsedBeforeStart ?? 0
            self?.dataUsed = self?.byteCountFormatter.string(fromByteCount: Int64(DeviceDataUsage.dataUsed - usedBefore)) ?? ""
        }
        isRunning = true
    }

    func stop() {
        timer.invalidate()
        dataUsed = "0 KB"
        elapsed = 0
        isRunning = false
    }

    private func formatToTimeString(_ seconds: Int) -> String {
        let h: Int = seconds / 3600
        let m: Int = (seconds / 60) % 60
        let s: Int = seconds % 60
        var time = String(format: " %2u:%02u  ", m, s)
        if h > 0 {
            time = String(format: " %u:%02u:%02u  ", h, m, s)
        }
        return time
    }
}
