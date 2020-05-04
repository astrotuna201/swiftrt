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
/// DeviceQueue
/// Used to schedule and execute computations
public protocol DeviceQueue: Logging {
    /// the thread that created this queue. Used to protect against
    /// accidental cross thread access
    var creatorThread: Thread { get }
    /// used to configure event creation
    var defaultQueueEventOptions: QueueEventOptions { get set }
    /// the id of the associated device
    var deviceId: Int { get }
    /// the name of the associated device, used in diagnostics
    var deviceName: String { get }
    /// the id of the queue
    var id: Int { get }
    /// the logging configuration for the queue
    var logInfo: LogInfo { get }
    /// the type of memory associated with the queue's device
    var memoryType: MemoryType { get }
    /// the name of the queue for diagnostics
    var name: String { get }

    //--------------------------------------------------------------------------
    /// allocate
    func allocate(byteCount: Int, heapIndex: Int) throws -> DeviceMemory
    ///
    func copyAsync(from memory: DeviceMemory, to other: DeviceMemory)
    ///
    func createEvent(options: QueueEventOptions) -> QueueEvent
    ///
    func record(event: QueueEvent) -> QueueEvent
    ///
    func wait(for event: QueueEvent)
    ///
    func waitUntilQueueIsComplete()
}

//==============================================================================
// default implementation
extension DeviceQueue {
    //--------------------------------------------------------------------------
    // allocate
    @inlinable public func allocate(
        byteCount: Int,
        heapIndex: Int
    ) throws -> DeviceMemory {
        // allocate a host memory buffer
        let buffer = UnsafeMutableRawBufferPointer.allocate(
                byteCount: byteCount, alignment: MemoryLayout<Double>.alignment)
        
        return DeviceMemory(buffer: buffer, memoryType: memoryType,
                            { buffer.deallocate() })
    }
    
    //--------------------------------------------------------------------------
    /// createEvent
    /// creates an event object used for queue synchronization
    @inlinable public func createEvent(
        options: QueueEventOptions
    ) -> QueueEvent {
        let event = CpuQueueEvent(options: options)
        diagnostic("\(createString) QueueEvent(\(event.id)) on " +
                    "\(deviceName)_\(name)", categories: .queueAlloc)
        return event
    }
    
    //--------------------------------------------------------------------------
    /// record(event:
    @discardableResult
    @inlinable public func record(
        event: QueueEvent
    ) -> QueueEvent {
        diagnostic("\(recordString) QueueEvent(\(event.id)) on " +
                    "\(deviceName)_\(name)", categories: .queueSync)
        
        // set event time
        if defaultQueueEventOptions.contains(.timing) {
            var timeStampedEvent = event
            timeStampedEvent.recordedTime = Date()
            return timeStampedEvent
        } else {
            return event
        }
    }
    
    //--------------------------------------------------------------------------
    /// wait(for event:
    /// waits until the event has occurred
    @inlinable public func wait(
        for event: QueueEvent
    ) {
        guard !event.occurred else { return }
        diagnostic("\(waitString) QueueEvent(\(event.id)) on " +
                    "\(deviceName)_\(name)", categories: .queueSync)
        do {
            try event.wait()
        } catch {
            // there is no recovery here
            writeLog("\(error)")
            fatalError()
        }
    }
    
    //--------------------------------------------------------------------------
    // waitUntilQueueIsComplete
    // the synchronous queue completes work as it is queued,
    // so it is always complete
    @inlinable public func waitUntilQueueIsComplete() { }
    
    //--------------------------------------------------------------------------
    // copyAsync
    @inlinable public func copyAsync(
        from memory: DeviceMemory,
        to other: DeviceMemory
    ) {
        assert(memory.memoryType == .unified && other.memoryType == .unified)
        let buffer = UnsafeRawBufferPointer(memory.buffer)
        other.buffer.copyMemory(from: buffer)
    }
}
