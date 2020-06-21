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

//==============================================================================
/// CpuFunctions
public protocol CpuFunctions { }

//==============================================================================
/// CpuQueue
/// a final version of the default device queue which executes functions
/// synchronously on the cpu
public final class CpuQueue: DeviceQueue, CpuFunctions {
    // properties
    public let creatorThread: Thread
    public var defaultQueueEventOptions: QueueEventOptions
    public let deviceId: Int
    public let deviceName: String
    public let id: Int
    public let logInfo: LogInfo
    public let memoryType: MemoryType
    public let mode: DeviceQueueMode
    public let name: String
    public let queue: DispatchQueue
    public let usesCpu: Bool
    
    //--------------------------------------------------------------------------
    // initializers
    @inlinable public init(
        parent logInfo: LogInfo,
        deviceId: Int,
        deviceName: String,
        memoryType: MemoryType,
        mode: DeviceQueueMode
    ) {
        self.id = Context.nextQueueId
        self.name = "q\(id)"
        self.logInfo = logInfo.flat(name)
        self.deviceId = deviceId
        self.deviceName = deviceName
        self.creatorThread = Thread.current
        self.defaultQueueEventOptions = QueueEventOptions()
        self.memoryType = memoryType
        self.mode = mode
        self.queue = DispatchQueue(label: "\(deviceName)_\(name)")
        self.usesCpu = true
        
        diagnostic("\(createString) queue: \(deviceName)_\(name)  " +
                    "mode: \(mode)", categories: .queueAlloc)
    }
    
    deinit {
        // make sure all scheduled work is complete before exiting
        waitUntilQueueIsComplete()
        diagnostic("\(releaseString) queue: \(deviceName)_\(name)",
                   categories: .queueAlloc)
    }
}
