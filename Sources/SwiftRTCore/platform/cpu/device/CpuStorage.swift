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
import Dispatch

//==============================================================================
/// CpuStorage
/// A synchronous host memory element storage buffer
public final class CpuStorage: StorageBuffer {
    // StorageBuffer protocol properties
    public let alignment: Int
    public let byteCount: Int
    public let id: Int
    public let isReadOnly: Bool
    public let isReference: Bool
    public var isZero: Bool
    
    /// the last queue used to write storage
    public var lastQueue: Platform.Device.Queue?

    @usableFromInline var _name: String = defaultTensorName
    @inlinable public var name: String {
        get {
            _name != defaultTensorName ? _name : "\(defaultTensorName)(\(id))"
        }
        set { _name = newValue }
    }

    // implementation properties
    public let hostBuffer: UnsafeMutableRawBufferPointer

    //--------------------------------------------------------------------------
    // init(type:count:name:
    @inlinable public init<Element>(
        storedType: Element.Type,
        count: Int,
        name: String
    ) {
        assert(MemoryLayout<Element>.size != 0,
               "type: \(Element.self) is size 0")
        _name = name
        alignment = MemoryLayout<Element>.alignment
        byteCount = MemoryLayout<Element>.size * count
        id = Platform.objectId.next
        isReadOnly = false
        isReference = false
        isZero = false

        hostBuffer = UnsafeMutableRawBufferPointer.allocate(
            byteCount: byteCount,
            alignment: alignment)

        #if DEBUG
        diagnostic(.alloc, "\(self.name) " +
            "\(Element.self)[\(count)]", categories: .dataAlloc)
        #endif
    }

    //--------------------------------------------------------------------------
    /// `init(storedElement:name:
    public convenience init<Element>(storedElement: Element, name: String) {
        // TODO: change to data member to avoid heap alloc
        self.init(storedType: Element.self, count: 1, name: name)
        hostBuffer.bindMemory(to: Element.self)[0] = storedElement
    }
    
    //--------------------------------------------------------------------------
    /// `init(storedElement:name:
    public convenience init<Element>(
        storedElement: Element,
        name: String
    ) where Element: Numeric {
        // TODO: change to data member to avoid heap alloc
        self.init(storedType: Element.self, count: 1, name: name)
        hostBuffer.bindMemory(to: Element.self)[0] = storedElement
        isZero = storedElement == 0
    }

    //--------------------------------------------------------------------------
    // init(other:queue:
    @inlinable public init<Element>(
        type: Element.Type,
        copying other: CpuStorage,
        using queue: Platform.Device.Queue
    ) {
        alignment = other.alignment
        byteCount = other.byteCount
        id = Platform.objectId.next
        isReadOnly = other.isReadOnly
        isReference = other.isReference
        isZero = other.isZero
        _name = other._name
        if isReference {
            hostBuffer = other.hostBuffer
        } else {
            hostBuffer = UnsafeMutableRawBufferPointer.allocate(
                byteCount: other.byteCount,
                alignment: other.alignment)
            hostBuffer.copyMemory(from: UnsafeRawBufferPointer(other.hostBuffer))
        }
    }

    //--------------------------------------------------------------------------
    // init(buffer:name:
    @inlinable public init<Element>(
        referenceTo buffer: UnsafeBufferPointer<Element>,
        name: String
    ) {
        _name = name
        alignment = MemoryLayout<Element>.alignment
        byteCount = MemoryLayout<Element>.size * buffer.count
        let buff = UnsafeMutableBufferPointer(mutating: buffer)
        hostBuffer = UnsafeMutableRawBufferPointer(buff)
        id = Platform.objectId.next
        isReadOnly = true
        isReference = true
        isZero = false

        diagnostic(.reference, "\(self.name) " +
            "\(Element.self)[\(buffer.count)]", categories: .dataAlloc)
    }
    
    //--------------------------------------------------------------------------
    // init(type:buffer:name:
    @inlinable public init<Element>(
        referenceTo buffer: UnsafeMutableBufferPointer<Element>,
        name: String
    ) {
        _name = name
        alignment = MemoryLayout<Element>.alignment
        byteCount = MemoryLayout<Element>.size * buffer.count
        hostBuffer = UnsafeMutableRawBufferPointer(buffer)
        id = Platform.objectId.next
        isReadOnly = false
        isReference = true
        isZero = false

        diagnostic(.reference, "\(self.name) " +
            "\(Element.self)[\(buffer.count)]", categories: .dataAlloc)
    }
    
    //--------------------------------------------------------------------------
    // streaming
    @inlinable
    public init<S, Stream>(block shape: S, bufferedBlocks: Int, stream: Stream)
        where S: TensorShape, Stream: BufferStream
    {
        fatalError()
    }
    
    //--------------------------------------------------------------------------
    // deinit
    @inlinable deinit {
        // wait for any pending writes to complete
        lastQueue?.waitForCompletion()
        
        if !isReference {
            hostBuffer.deallocate()
            diagnostic(.release, self.name, categories: .dataAlloc)
        }
    }

    //--------------------------------------------------------------------------
    // synchronize
    @inlinable public func synchronize(
        _ queue: Platform.Device.Queue,
        willWrite: Bool
    ) {
        // synchronize only if switching queues
        if let last = lastQueue, last.id != queue.id {
            diagnostic(.sync, "\(queue.name) will wait for" +
                        " \(last.name) to " +
                        "\(willWrite ? "write" : "read") \(name)",
                       categories: .queueSync)
            if queue.mode == .sync {
                last.waitForCompletion()
            } else {
                queue.wait(for: last.recordEvent())
            }
        }
        if queue.mode == .async { lastQueue = queue }
    }
    
    //--------------------------------------------------------------------------
    // read
    @inlinable public func read<Element>(
        type: Element.Type,
        at index: Int,
        count: Int,
        using queue: Platform.Device.Queue
    ) -> UnsafeBufferPointer<Element> {
        synchronize(queue, willWrite: false)
        // advance to typed starting position
        let start = hostBuffer.baseAddress!
            .bindMemory(to: Element.self, capacity: count)
            .advanced(by: index)
        // return read only buffer pointer
        return UnsafeBufferPointer(start: start, count: count)
    }
    
    //--------------------------------------------------------------------------
    // readWrite
    @inlinable public func readWrite<Element>(
        type: Element.Type,
        at index: Int,
        count: Int,
        using queue: Platform.Device.Queue
    ) -> UnsafeMutableBufferPointer<Element> {
        synchronize(queue, willWrite: true)
        // advance to typed starting position
        let start = hostBuffer.baseAddress!
            .bindMemory(to: Element.self, capacity: count)
            .advanced(by: index)
        // return read/write buffer pointer
        return UnsafeMutableBufferPointer(start: start, count: count)
    }
    
    //--------------------------------------------------------------------------
    /// waitForCompletion
    /// blocks the caller until pending operations have completed
    @inlinable public func waitForCompletion() {
        lastQueue?.waitForCompletion()
    }
}

