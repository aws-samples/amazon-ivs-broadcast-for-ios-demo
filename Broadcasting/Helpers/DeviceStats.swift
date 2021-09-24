//
//  DeviceStats.swift
//  Broadcasting
//
//  Created by Uldis Zingis on 18/06/2021.
//

import Foundation
import Combine

class DeviceStats: ObservableObject {
    @Published var cpu: Int = 0
    @Published var memory: Int = 0
    @Published var temperature: String = "-"

    var timer: Timer = Timer()

    init() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateStats), userInfo: nil, repeats: true)
        updateStats()
    }

    deinit {
        timer.invalidate()
    }

    @objc private func updateStats() {
        cpu = Int(cpuUsage())
        memory = Int(memoryUsage())
        temperature = thermalUsage()
    }

    private func cpuUsage() -> Double {
        var kr: kern_return_t
        var task_info_count: mach_msg_type_number_t

        task_info_count = mach_msg_type_number_t(TASK_INFO_MAX)
        var tinfo = [integer_t](repeating: 0, count: Int(task_info_count))

        kr = task_info(mach_task_self_, task_flavor_t(TASK_BASIC_INFO), &tinfo, &task_info_count)
        if kr != KERN_SUCCESS {
            return -1
        }

        var temp = [thread_act_t]()
        var thread_list: thread_act_array_t? = UnsafeMutablePointer<UInt32>.allocate(capacity: temp.count)
        thread_list?.initialize(from: &temp, count: temp.count)
        var thread_count: mach_msg_type_number_t = 0

        defer {
            if let thread_list = thread_list {
                vm_deallocate(mach_task_self_, vm_address_t(UnsafePointer(thread_list).pointee), vm_size_t(thread_count))
            }
        }

        kr = task_threads(mach_task_self_, &thread_list, &thread_count)

        if kr != KERN_SUCCESS {
            return -1
        }

        var tot_cpu: Double = 0

        if let thread_list = thread_list {

            for j in 0 ..< Int(thread_count) {
                var thread_info_count = mach_msg_type_number_t(THREAD_INFO_MAX)
                var thinfo = [integer_t](repeating: 0, count: Int(thread_info_count))
                kr = thread_info(thread_list[j], thread_flavor_t(THREAD_BASIC_INFO),
                                 &thinfo, &thread_info_count)
                if kr != KERN_SUCCESS {
                    return -1
                }

                let threadBasicInfo = convertThreadInfoToThreadBasicInfo(thinfo)

                if threadBasicInfo.flags != TH_FLAGS_IDLE {
                    tot_cpu += (Double(threadBasicInfo.cpu_usage) / Double(TH_USAGE_SCALE)) * 100.0
                }
            } // for each thread
        }

        return tot_cpu
    }

    private func memoryUsage() -> Double {
        var taskInfo = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        let _: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }

        return Double(taskInfo.resident_size / 1000000)
    }

    private func thermalUsage() -> String {
        switch ProcessInfo().thermalState {
        case .critical:
            return "critical"
        case .fair:
            return "fair"
        case .nominal:
            return "nominal"
        case .serious:
            return "serious"
        @unknown default:
            return "unknown"
        }
    }

    private func convertThreadInfoToThreadBasicInfo(_ threadInfo: [integer_t]) -> thread_basic_info {
        var result = thread_basic_info()

        result.user_time = time_value_t(seconds: threadInfo[0], microseconds: threadInfo[1])
        result.system_time = time_value_t(seconds: threadInfo[2], microseconds: threadInfo[3])
        result.cpu_usage = threadInfo[4]
        result.policy = threadInfo[5]
        result.run_state = threadInfo[6]
        result.flags = threadInfo[7]
        result.suspend_count = threadInfo[8]
        result.sleep_time = threadInfo[9]

        return result
    }
}
