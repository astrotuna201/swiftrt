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
/// Platform
/// a platform represents a collection of installed devices on a
/// compute node, such as (cpu, cuda, tpu, ...)
public protocol Platform: class, Logging {
    // types
    associatedtype Device: ComputeDevice

    /// the number of async cpu queues to create
    static var defaultCpuQueueCount: Int { get }
    /// the number of queues per accelerator device to create
    static var defaultAcceleratorQueueCount: Int { get }
    /// a collection of available compute devices
    var devices: [Device] { get }
    /// returns an id to a discrete memory device to support unit tests
    var discreteMemoryDeviceId: Int { get }
    /// name used for logging
    var name: String { get }
    /// the current device queue to direct work
    var queueStack: [Device.Queue] { get set }
    /// queue used to synchronize data interchange with the application thread
    var appThreadQueue: Device.Queue { get }
}

public extension Platform {
    /// the currently active queue that platform functions will use
    /// - Returns: the current device queue
    @inlinable @_transparent
    var currentDevice: Device {
        devices[queueStack.last!.deviceIndex]
    }

    /// the currently active queue that platform functions will use
    /// - Returns: the current device queue
    @inlinable var currentQueue: Device.Queue {
        assert(Thread.current == queueStack.last!.creatorThread,
               "queues may not be shared across threads")
        return queueStack.last!
    }
    
    /// selects the specified device queue for output
    /// - Parameters:
    ///  - device: the device to use. Device 0 is the cpu
    ///  - queue: the queue on the device to use
    @inlinable func use(device: Int, queue: Int = 0) {
        queueStack[queueStack.count - 1] = validQueue(device, queue)
    }
    
    /// selects the application thread data interchange queue within
    /// the scope of the body
    @inlinable func useSyncQueue() {
        queueStack[queueStack.count - 1] = appThreadQueue
    }
    
    /// selects the application thread data interchange queue within
    /// the scope of the body
    /// - Parameters:
    ///  - body: a closure where the device queue will be used
    @inlinable func usingSyncQueue<R>(_ body: () -> R) -> R {
        queueStack.append(appThreadQueue)
        defer { _ = queueStack.popLast() }
        return body()
    }
    
    /// selects the specified device queue for output within the scope of
    /// the body
    /// - Parameters:
    ///  - device: the device to use. Device 0 is the cpu
    ///  - queue: the queue on the device to use
    ///  - body: a closure where the device queue will be used
    @inlinable func using<R>(device: Int, queue: Int = 0, _ body: () -> R) -> R {
        // push the selection onto the queue stack
        queueStack.append(validQueue(device, queue))
        defer { _ = queueStack.popLast() }
        return body()
    }
    
    /// selects the specified queue on the current device for output
    /// within the scope of the body
    /// - Parameters:
    ///  - queue: the queue on the device to use
    ///  - body: a closure where the device queue will be used
    @inlinable func using<R>(queue: Int, _ body: () -> R) -> R {
        // push the selection onto the queue stack
        queueStack.append(validQueue(currentQueue.deviceIndex, queue))
        defer { _ = queueStack.popLast() }
        return body()
    }

    // peforms a mod on the indexes to guarantee they are mapped into bounds
    @inlinable func validQueue(
        _ deviceId: Int,
        _ queueId: Int
    ) -> Device.Queue {
        let device = devices[deviceId % devices.count]
        assert(device.queues.count > 0, "the number of available queues is 0")
        return device.queues[queueId % device.queues.count]
    }
}

//==============================================================================
// queue API
@inlinable public func use(device: Int, queue: Int = 0) {
    Context.local.platform.use(device: device, queue: queue)
}

@inlinable public func useSyncQueue() { Context.local.platform.useSyncQueue() }

@inlinable public func usingSyncQueue<R>(_ body: () -> R) -> R {
    Context.local.platform.usingSyncQueue(body)
}

@inlinable public func using<R>(device: Int, queue: Int = 0,
                                _ body: () -> R) -> R {
    Context.local.platform.using(device: device, queue: queue, body)
}

@inlinable public func using<R>(queue: Int, _ body: () -> R) -> R {
    Context.local.platform.using(queue: queue, body)
}

//==============================================================================
/// the type used for memory indexing on discrete devices
public typealias DeviceIndex = Int32

//==============================================================================
/// NanPropagation
public enum NanPropagation: Int, Codable {
    case propagate, noPropagate
}

//==============================================================================
/// ReductionOp
public enum ReductionOp: Int, Codable {
    case add
    case mean
    case mul
    case min
    case max
    case amax
    case asum
    case sqrtSumSquares
    case mulNonZeros
    case compare
}

public typealias ReduceOpFinal<R: MutableCollection> = (R.Element) -> R.Element

//==============================================================================
/// PlatformError
/// platform errors
public enum PlatformError : Error {
    case functionFailure(location: String, message: String)
    case rangeError(String)
}

//==============================================================================
public enum EvaluationMode {
    /// operation is used to perform inference
    case inferring
    /// operation is used to perform training
    case training
}

//==============================================================================
/// ComputeDevice
/// a compute device represents a physical platform device (cpu, gpu, ...)
public protocol ComputeDevice: class, Logging {
    associatedtype Queue: DeviceQueue
    
    /// the index of the device in the `devices` collection
    var index: Int { get }
    /// name used for diagnostics
    var name: String { get }
    /// a collection of device queues for scheduling work
    var queues: [Queue] { get }
    /// specifies the type of device memory for data transfer
    var memoryType: MemoryType { get }
    /// the number of queues available for execution. The user can set
    /// this value to change the number of queues available for execution.
}

//==============================================================================
/// DeviceMemory
public protocol DeviceMemory: class, Logging {
    /// base address and size of buffer
    var buffer: UnsafeMutableRawBufferPointer { get }
    /// index of device where memory is located
    var deviceIndex: Int { get }
    /// the diagnostic name of the memory
    var name: String? { get set }
    /// mutable raw pointer to memory buffer to simplify driver calls
    var pointer: UnsafeMutableRawPointer { get }
    /// optional string for diagnostics
    var releaseMessage: String? { get set }
    /// specifies the device memory type for data transfer
    var type: MemoryType { get }
    /// version
    var version: Int { get set }
}

//==============================================================================
/// QueueEvent
/// A queue event is a barrier synchronization object that is
/// - created by a `DeviceQueue`
/// - recorded on a queue to create a barrier
/// - waited on by one or more threads for group synchronization
public protocol QueueEvent: class, Logging {
    /// the id of the event for diagnostics
    var id: Int { get }
    /// the last time the event was recorded
    var recordedTime: Date? { get set }

    /// measure elapsed time since another event
    func elapsedTime(since other: QueueEvent) -> TimeInterval?
    
    /// signals that the event has occurred
    func signal()
    
    /// will block the caller until the timeout has elapsed if one
    /// was specified during init, otherwise it will block forever
    func wait()
}

//==============================================================================
public extension QueueEvent {
    /// elapsedTime
    /// computes the timeinterval between two queue event recorded times
    /// - Parameter other: the other event used to compute the interval
    /// - Returns: the elapsed interval. Will return `nil` if this event or
    ///   the other have not been recorded.
    @inlinable func elapsedTime(since other: QueueEvent) -> TimeInterval? {
        guard let time = recordedTime,
            let other = other.recordedTime else { return nil }
        return time.timeIntervalSince(other)
    }
}

//==============================================================================
/// QueueEventOptions
public struct QueueEventOptions: OptionSet {
    public let rawValue: Int
    public static let timing       = QueueEventOptions(rawValue: 1 << 0)
    public static let interprocess = QueueEventOptions(rawValue: 1 << 1)
    
    @inlinable public init() { self.rawValue = 0 }
    @inlinable public init(rawValue: Int) { self.rawValue = rawValue }
}

public enum QueueEventError: Error {
    case timedOut
}

//==============================================================================
/// MemoryType
public enum MemoryType {
    /// the memory is unified with the cpu address space
    case unified
    /// the memory is in a discrete memory address space on another device
    /// and is not directly accessible by the cpu
    case discrete
}

public enum DeviceQueueMode {
    /// the device queue schedule work asynchronously
    case async
    /// the device queue will execute work immediately before returning
    case sync
}

//==============================================================================
/// QueueId
/// a unique device queue identifier that is used to index
/// through the platform device tree for directing workflow
public struct QueueId {
    public let device: Int
    public let queue: Int
    
    @inlinable public init(_ device: Int, _ queue: Int) {
        self.device = device
        self.queue = queue
    }
}

//==============================================================================
// assert messages
public let _messageQueueThreadViolation =
"a queue can only be accessed by the thread that created it"

//==============================================================================
/// DeviceError
public enum DeviceError : Error {
    case allocationFailed
    case initializeFailed
    case queueError(idPath: [Int], message: String)
    case timeout(idPath: [Int], message: String)
}

//==============================================================================
/// ScalarType
/// Used primarily for serialization, C APIs, and Cuda kernels
public enum ScalarType: Int {
    // floating point
    case real16F, complex16F
    case real16BF, complex16BF
    case real32F, complex32F
    case real64F, complex64F

    // integer
    case real4I, real4U, complex4I, complex4U
    case real8I, real8U, complex8I, complex8U
    case real16I, real16U, complex16I, complex16U
    case real32I, real32U, complex32I, complex32U
    case real64U, real64I, complex64I, complex64U

    // non numeric
    case bool
}

// TODO: extend to all supported types
//
public protocol ScalarElement: StorageElement {
    static var type: ScalarType { get }
    static var zeroPointer: UnsafeRawPointer { get }
    static var onePointer: UnsafeRawPointer { get }
}

extension Int8: ScalarElement {
    @inlinable public static var type: ScalarType { .real8I }
    
    public static var zero: Self = 0
    @inlinable public
    static var zeroPointer: UnsafeRawPointer { UnsafeRawPointer(&zero) }
    
    public static var one: Self = 1
    @inlinable public
    static var onePointer: UnsafeRawPointer { UnsafeRawPointer(&one) }
}

extension UInt8: ScalarElement {
    @inlinable public static var type: ScalarType { .real8U }
    
    public static var zero: Self = 0
    @inlinable public
    static var zeroPointer: UnsafeRawPointer { UnsafeRawPointer(&zero) }
    
    public static var one: Self = 1
    @inlinable public
    static var onePointer: UnsafeRawPointer { UnsafeRawPointer(&one) }
}

extension Float: ScalarElement {
    @inlinable public static var type: ScalarType { .real32F }
    
    public static var zero: Self = 0
    @inlinable public
    static var zeroPointer: UnsafeRawPointer { UnsafeRawPointer(&zero) }
    
    public static var one: Self = 1
    @inlinable public
    static var onePointer: UnsafeRawPointer { UnsafeRawPointer(&one) }
}

extension Float16: ScalarElement {
    @inlinable public static var type: ScalarType { .real16F }
    
    public static var zero: Self = Float16(0)
    @inlinable public
    static var zeroPointer: UnsafeRawPointer { UnsafeRawPointer(&zero) }
    
    public static var one: Self = Float16(1)
    @inlinable public
    static var onePointer: UnsafeRawPointer { UnsafeRawPointer(&one) }
}

extension Double: ScalarElement {
    @inlinable public static var type: ScalarType { .real64F }
    
    public static var zero: Self = 0
    @inlinable public
    static var zeroPointer: UnsafeRawPointer { UnsafeRawPointer(&zero) }
    
    public static var one: Self = 1
    @inlinable public
    static var onePointer: UnsafeRawPointer { UnsafeRawPointer(&one) }
}

