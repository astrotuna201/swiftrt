//******************************************************************************
// Copyright 2020 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
import Foundation
import CCuda

//==============================================================================
/// CudaDevice
public class CudaDevice: ComputeDevice {
    // properties
    public let id: Int
    public let gpuId: Int
    public let logInfo: LogInfo
    public let memoryType: MemoryType
    public let name: String
    public var queues: [CudaQueue]
    public var properties: [CudaDeviceProperties : String]

    @inlinable public init(
        id: Int,
        parent parentLogInfo: LogInfo,
        queueMode: DeviceQueueMode
    ) {
        let isCpuDevice = id == 0
        self.id = id
        self.gpuId = id - 1
        self.name = isCpuDevice ? "cpu:0" : "gpu:\(gpuId)"
        self.logInfo = parentLogInfo.child(name)
        self.properties = [:]

        // create queues
        var numQueues: Int
        if isCpuDevice {
            //------------------------------------------------------------------
            memoryType = .unified
            numQueues = 1
            self.queues = [CudaQueue(parent: logInfo,
                                     gpuDeviceId: 0,
                                     deviceName: name,
                                     cpuQueueMode: queueMode,
                                     useGpu: false)]
        } else {
            //------------------------------------------------------------------
            memoryType = .discrete
            numQueues = 3
            self.queues = []
            for _ in 0..<numQueues {
                queues.append(CudaQueue(parent: logInfo,
                              gpuDeviceId: gpuId,
                              deviceName: name,
                              cpuQueueMode: queueMode,
                              useGpu: !isCpuDevice))
            }
            getCudaDeviceProperties()
        }
    }

    //--------------------------------------------------------------------------
    @inlinable func getCudaDeviceProperties() {
        do {
            // get device properties
            var props = cudaDeviceProp()
            try cudaCheck(status: cudaGetDeviceProperties(&props, 0))
            let nameCapacity = MemoryLayout.size(ofValue: props.name)
            let deviceName = withUnsafePointer(to: &props.name) {
                $0.withMemoryRebound(to: UInt8.self, capacity: nameCapacity) {
                    String(cString: $0)
                }
            }
            properties = [
                .deviceName : deviceName,
                .computeCapability : "\(props.major).\(props.minor)",
                .globalMemory : "\(props.totalGlobalMem / (1024 * 1024)) MB",
                .multiprocessors : "\(props.multiProcessorCount)",
                .unifiedAddressing : "\(memoryType == .unified ? "yes" : "no")",
            ]
		} catch {
            writeLog("Failed to read device properites. \(error)")
        }
    }
}

//==============================================================================
// CudaDeviceProperties
public enum CudaDeviceProperties: Int {
    case deviceName, globalMemory, computeCapability, multiprocessors, unifiedAddressing
}

