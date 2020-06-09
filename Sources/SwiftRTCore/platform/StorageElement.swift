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
import Numerics

//==============================================================================
/// StorageElement
/// tensor elements conform to `StorageElement`, which enables reading, writing,
/// and operating on data types that are not native to the Swift language,
/// but can be native and optimal for gpus
public protocol StorageElement {
    associatedtype Stored
    associatedtype Value
    
    /// alignment
    /// the Value alignment with the Stored type for the given logical index
    /// For example `Int1` the alignment is 0 - 7, Int4 0 - 1
    /// Normal types like Float are always 0
    /// - Parameter index: the logical element index
    /// - Returns: the value position with the stored element
    static func alignment(_ index: Int) -> Int
    
    /// storedCount
    /// the number of `Stored` elements needed to contain the specified
    /// number of `Value` elements
    /// - Parameter count: the number of value elements
    /// - Returns: the storage count
    static func storedCount(_ count: Int) -> Int
    
    /// storedIndex
    /// the stored index will be less than the logical index for packed
    /// bit types such as `Int4`
    /// - Parameter index: the logical buffer index
    /// - Returns: the stored index
    static func storedIndex(_ index: Int) -> Int
    
    /// storedRange
    /// the stored count will be less than the logical count for packed
    /// bit types such as `Int4`. Unlike `storedIndex`, it rounds up.
    /// - Parameters:
    ///  - start: the logical buffer starting index
    ///  - count: the number of logical elements spanned
    /// - Returns: the stored starting index and count
    static func storedRange(start: Int, count: Int)
    -> (storedStart: Int, storedCount: Int)

    /// value
    /// converts from `Stored` type to `Value` type
    /// - Parameters:
    ///  - index: the logical buffer index for the element. This is used
    ///  - stored: the stored representation of the element
    ///    to calculate the subelement position for packed elements
    /// - Returns: the element interchange Value. For example, an `Int1`
    ///   element is interchanged with the caller as an `Int`
    static func value(at index: Int, from stored: Stored) -> Value
    
    /// store
    /// writes a value into a storage location
    /// - Parameters:
    ///  - value: the element value to store. For package element types,
    ///    it is an error if the interchange Value exceeds the
    ///    range of the packed type.
    ///  - index: the logical buffer index for the element. This is used
    ///    to calculate the subelement position for packed elements
    ///  - stored: a reference to the storage location. Packed elements
    ///    are combined (or'ed) when written.
    static func store(value: Value, at index: Int, to stored: inout Stored)

    /// stored
    /// converts the Value interchange type to the Stored type
    /// - Parameters:
    ///  - value: the element value to store
    static func stored(value: Value) -> Stored
}

//==============================================================================
// Note: The default behavior for whole native elements is simply pass through
// which should be discarded by the compiler and impose no performance
// penalty

// Stored == Value
public extension StorageElement where Stored == Value {
    @inlinable static func storedIndex(_ index: Int) -> Int { index }
    @inlinable static func storedCount(_ count: Int) -> Int { count }
    @inlinable static func alignment(_ index: Int) -> Int { 0 }
    @inlinable static func stored(value: Value) -> Stored { value }

    @inlinable static func storedRange(start: Int, count: Int)
    -> (storedStart: Int, storedCount: Int) { (start, count) }

    @inlinable static func value(
        at index: Int, from stored: Stored
    ) -> Value { stored }
    
    @inlinable static func store(
        value: Value,
        at index: Int,
        to stored: inout Stored
    ) { stored = value }
}

//==============================================================================
/// PackedStorageElement
/// packed elements are bit field types that are not represented as
/// whole number types. The associated `Stored` type is used to contain
/// 2 or more packed values. Examples are the `UInt1` and `UInt4` types.
public protocol PackedStorageElement: StorageElement {
    /// the shift count used to transform a logical index into a stored index
    static var indexShift: Int { get }
    /// the shift count used to shift the value mask for reading and
    /// writing values to the storage location
    static var maskingShift: Int { get }
    /// the mask used to isolate a value within the stored type
    static var valueMask: Stored { get }
    /// the minimum value used for range checking
    static var valueMin: Value { get }
    /// the maximum value used for range checking
    static var valueMax: Value { get }
}

//------------------------------------------------------------------------------
// common implementations
public extension PackedStorageElement {
    @inlinable static func alignment(_ index: Int) -> Int {
        (index % (1 << indexShift))
    }
    
    @inlinable static func packedShift(_ index: Int) -> Int {
        alignment(index) << maskingShift
    }
    
    @inlinable static func storedIndex(_ index: Int) -> Int {
        index >> indexShift
    }
    
    @inlinable static func storedCount(_ count: Int) -> Int {
        storedIndex(count - 1) + 1
    }
    
    @inlinable static func storedRange(start: Int, count: Int)
    -> (storedStart: Int, storedCount: Int)
    {
        let storedStart = storedIndex(start)
        let storedCount = storedIndex(start + count - 1) - storedStart + 1
        return (storedStart, storedCount)
    }
}

//------------------------------------------------------------------------------
// integer conversion implementations
public extension PackedStorageElement
    where Value: BinaryInteger, Stored: BinaryInteger
{
    @inlinable static func value(at index: Int, from stored: Stored) -> Value {
        Value(stored >> packedShift(index) & valueMask)
    }
    
    @inlinable static func store(
        value: Value, at index: Int, to stored: inout Stored
    ) {
        assert(value >= valueMin && value <= valueMax)
        let positionShift = packedShift(index)

        // clear current value
        stored &= ~(valueMask << positionShift)
        
        // write new value
        stored |= Stored(value) << positionShift
    }
    
    @inlinable static func stored(value: Value) -> Stored { Stored(value) }
}

//==============================================================================
/// Bool1
/// convenience type processed as `Int1` on the gpu
public struct Bool1: PackedStorageElement {
    public typealias Stored = UInt8
    public typealias Value = Bool
    @inlinable public static var indexShift: Int { 3 }
    @inlinable public static var maskingShift: Int { 0 }
    @inlinable public static var valueMask: Stored { 0x1 }
    @inlinable public static var valueMin: Value { false }
    @inlinable public static var valueMax: Value { true }
    
    @inlinable public static func value(
        at index: Int,
        from stored: UInt8
    ) -> Bool {
        (stored >> packedShift(index) & valueMask) != 0
    }
    
    @inlinable public static func store(
        value: Bool,
        at index: Int,
        to stored: inout UInt8
    ) {
        let positionShift = packedShift(index)
        
        // clear current value
        stored &= ~(valueMask << positionShift)
        
        // write new value
        stored |= Stored(value ? 1 : 0) << positionShift
    }
    
    @inlinable public static func stored(value: Bool) -> UInt8 {
        value ? 1 : 0
    }
}

extension Tensor where TensorElement == Bool1 {
    @inlinable public init(_ other: Tensor<Shape, UInt1>) {
        shape = other.shape
        strides = other.strides
        storage = other.storage
        storageBase = other.storageBase
        layout = other.layout
        isShared = other.isShared
        count = other.count
        stridedSpanCount = other.stridedSpanCount
        logicalStrides = other.logicalStrides
        logicalElements = LogicalElements(count,
                                          shape,
                                          strides,
                                          storage,
                                          storageBase,
                                          layout,
                                          stridedSpanCount)
    }
}

//==============================================================================
/// UInt1
public struct UInt1: PackedStorageElement {
    public typealias Stored = UInt8
    public typealias Value = Int
    @inlinable public static var indexShift: Int { 3 }
    @inlinable public static var maskingShift: Int { 0 }
    @inlinable public static var valueMask: Stored { 0x1 }
    @inlinable public static var valueMin: Value { 0 }
    @inlinable public static var valueMax: Value { 1 }
}

extension Tensor where TensorElement == UInt1 {
    @inlinable public init(_ other: Tensor<Shape, Bool1>) {
        shape = other.shape
        strides = other.strides
        storage = other.storage
        storageBase = other.storageBase
        layout = other.layout
        isShared = other.isShared
        count = other.count
        stridedSpanCount = other.stridedSpanCount
        logicalStrides = other.logicalStrides
        logicalElements = LogicalElements(count,
                                          shape,
                                          strides,
                                          storage,
                                          storageBase,
                                          layout,
                                          stridedSpanCount)
    }
}

//==============================================================================
/// UInt4
public struct UInt4: PackedStorageElement {
    public typealias Stored = UInt8
    public typealias Value = Int
    @inlinable public static var indexShift: Int { 1 }
    @inlinable public static var maskingShift: Int { 2 }
    @inlinable public static var valueMask: Stored { 0x0F }
    @inlinable public static var valueMin: Value { 0 }
    @inlinable public static var valueMax: Value { 15 }
}

//==============================================================================
// non native types that automatically cast to a native type during iteration
extension Float16: StorageElement {
    @inlinable public static func storedIndex(_ index: Int) -> Int { index }
    @inlinable public static func storedCount(_ count: Int) -> Int { count }
    @inlinable public static func alignment(_ index: Int) -> Int { 0 }

    @inlinable public static func value(
        at index: Int, from stored: Self
    ) -> Float { Float(stored) }
    
    @inlinable public static func store(
        value: Float, at index: Int, to stored: inout Self
    ) { stored = Self(value) }

    @inlinable public static func stored(value: Float) -> Self { Self(value) }

    @inlinable public static func storedRange(start: Int, count: Int)
    -> (storedStart: Int, storedCount: Int) { (start, count) }
}

//==============================================================================
// standard native type conformance
extension Bool: StorageElement {
    public typealias Stored = Self
    public typealias Value = Self
}

extension Int8: StorageElement {
    public typealias Stored = Self
    public typealias Value = Self
}

extension UInt8: StorageElement {
    public typealias Stored = Self
    public typealias Value = Self
}

extension Int16: StorageElement {
    public typealias Stored = Self
    public typealias Value = Self
}

extension UInt16: StorageElement {
    public typealias Stored = Self
    public typealias Value = Self
}

extension Int32: StorageElement {
    public typealias Stored = Self
    public typealias Value = Self
}

extension UInt32: StorageElement {
    public typealias Stored = Self
    public typealias Value = Self
}

extension Float: StorageElement {
    public typealias Stored = Self
    public typealias Value = Self
}

extension Double: StorageElement {
    public typealias Stored = Self
    public typealias Value = Self
}

extension Complex: StorageElement {
    public typealias Stored = Self
    public typealias Value = Self
}

//==============================================================================
/// BufferElements
/// Iterates the buffer elements in order, independent of logical orientation
/// this is used for elementwise operations

// Note: this copies the host buffer so that it can be accessed asynchronously
// without copy-on-write issues
public struct BufferElements<Shape, TensorElement>: MutableCollection
    where Shape: TensorShape, TensorElement: StorageElement
{
    // properties
    public let hostBuffer: UnsafeMutableBufferPointer<TensorElement.Stored>
    public let isSingleElement: Bool
    public let startIndex: Int
    public let endIndex: Int
    
    //--------------------------------------------------------------------------
    /// init(tensor:
    /// creates a storage buffer iterator for reading tensor elments
    ///
    /// - Parameters:
    ///  - tensor: the tensor that will be read
    @inlinable public init(tensor: Tensor<Shape, TensorElement>) {
        assert(tensor.isBufferIterable, "tensor layout is not buffer iterable")

        // make the data range available for reading by the cpu
        isSingleElement = tensor.isSingleElement
        let buffer = tensor.read()
        
        // Init members and note that this does not actually mutate, even
        // though we commonly hold a mutable buffer pointer
        let p = UnsafeMutablePointer(mutating: buffer.baseAddress)
        hostBuffer = UnsafeMutableBufferPointer(start: p, count: buffer.count)
        
        // `startIndex` is the logical position of the first
        // `Value` type within the `Stored` type.
        // For Int1 the alignment is 0 - 7, Int4 0 - 1, for
        // normal types like Float, it is always 0
        startIndex = TensorElement.alignment(tensor.storageBase)
        endIndex = startIndex + tensor.count
    }
    
    //--------------------------------------------------------------------------
    /// init(mutating:
    /// creates a storage buffer iterator for reading/writing tensor elments
    ///
    /// - Parameters:
    ///  - tensor: the tensor that will be written
    @inlinable public init(tensor: inout Tensor<Shape, TensorElement>) {
        assert(tensor.isBufferIterable, "tensor layout is not buffer iterable")

        // convert logical base and strided span count to stored.
        // They will not be equal for packed element types like `Int4`
        isSingleElement = tensor.isSingleElement

        // make the data range available for reading/writing by the cpu
        hostBuffer = tensor.readWrite()
        
        // `startIndex` is the logical position of the first
        // `Value` type within the `Stored` type.
        // For Int1 the alignment is 0 - 7, Int4 0 - 1, for
        // normal types like Float, it is always 0
        startIndex = TensorElement.alignment(tensor.storageBase)
        endIndex = startIndex + tensor.count
    }
    
    //--------------------------------------------------------------------------
    // index(after:
    @inlinable public func index(after i: Int) -> Int {
        i + 1
    }
    
    //--------------------------------------------------------------------------
    // subscript
    @inlinable public subscript(position: Int) -> TensorElement.Value {
        get {
            if isSingleElement {
                return TensorElement.value(at: startIndex, from: hostBuffer[0])
            } else {
                let si = TensorElement.storedIndex(position)
                return TensorElement.value(at: position, from: hostBuffer[si])
            }
        }
        
        set(v) {
            if isSingleElement {
                TensorElement.store(value: v, at: startIndex, to: &hostBuffer[0])
            } else {
                let si = TensorElement.storedIndex(position)
                TensorElement.store(value: v, at: position, to: &hostBuffer[si])
            }
        }
    }
}

//==============================================================================
/// LogicalElements
/// a class that maps `ElementIndex`s to storage values via the current
/// dynamic layout.
public final class LogicalElements<Shape, TensorElement>: MutableCollection
where Shape: TensorShape, TensorElement: StorageElement
{
    // properties
    public typealias Index = ElementIndex<Shape>
    public let alignment: Int
    public var hostBuffer: UnsafeMutableBufferPointer<TensorElement.Stored>
    public weak var storage: StorageBufferType!
    public let storedBase: Int
    public let storedCount: Int
    public let strides: Shape
    public let layout: Layout
    public let startIndex: Index
    public let endIndex: Index

    //--------------------------------------------------------------------------
    /// init(tensor:
    /// creates a storage buffer iterator for reading tensor elments
    ///
    /// - Parameters:
    ///  - tensor: the tensor that will be read
    @inlinable public convenience init(tensor: Tensor<Shape, TensorElement>) {
        self.init(tensor.count,
                  tensor.shape,
                  tensor.strides,
                  tensor.storage,
                  tensor.storageBase,
                  tensor.layout,
                  tensor.stridedSpanCount)
    }
    
    //--------------------------------------------------------------------------
    /// init
    /// This initializer is called by `Tensor` initializers to setup for
    /// possible direct element indexing by the user. The host buffer is
    /// set to `nil` and requires that `synchronizeForReadWrite` be called
    /// before any access to storage.
    /// `Tensor.startIndex` and `Tensor.makeIndex` call this function each
    /// time to transparently sync for the user.
    @inlinable public init(
        _ count: Int,
        _ shape: Shape,
        _ strides: Shape,
        _ storage: StorageBufferType,
        _ storageBase: Int,
        _ layout: Layout,
        _ stridedSpanCount: Int
    ) {
        assert(shape.elementCount() == count, "shape count mismatch")
        self.alignment = TensorElement.alignment(storageBase)
        self.strides = strides
        self.storage = storage
        self.layout = layout
        let (storedBase, storedCount) =
                TensorElement.storedRange(start: storageBase,
                                          count: stridedSpanCount)
        self.storedBase = storedBase
        self.storedCount = storedCount
        startIndex = Index(Shape.zero, 0)
        endIndex = Index(shape, count)
        hostBuffer = UnsafeMutableBufferPointer(start: nil, count: 0)
    }
    
    //--------------------------------------------------------------------------
    // synchronizeForRead
    @inlinable public func synchronizeForRead() {
        let buff = storage.read(type: TensorElement.Stored.self,
                                at: storedBase, count: storedCount)
        // this never actually mutates
        let p = UnsafeMutablePointer(mutating: buff.baseAddress)
        hostBuffer = UnsafeMutableBufferPointer(start: p, count: buff.count)
    }
    
    //--------------------------------------------------------------------------
    // synchronizeForReadWrite
    @inlinable public func synchronizeForReadWrite() {
        hostBuffer = storage.readWrite(type: TensorElement.Stored.self,
                                       at: storedBase, count: storedCount)
    }
    
    //--------------------------------------------------------------------------
    // index(after:
    @inlinable public func index(after i: Index) -> Index {
        switch layout {
        case .row, .col:
            return i.incremented(between: startIndex, and: endIndex)
        }
    }
    
    //--------------------------------------------------------------------------
    // subscript
    @inlinable public subscript(position: Index) -> TensorElement.Value {
        get {
            switch layout {
            case .row, .col:
                // get logical strided linear element position
                let i = position.linearIndex(strides) + alignment
                
                // convert to stored index which might be less for packed elements
                let si = TensorElement.storedIndex(i)
                return TensorElement.value(at: i, from: hostBuffer[si])
            }
        }
        
        set {
            switch layout {
            case .row, .col:
                // get logical strided linear element position
                let i = position.linearIndex(strides) + alignment
                
                // convert to stored index which might be less for packed elements
                let si = TensorElement.storedIndex(i)
                TensorElement.store(value: newValue, at: i, to: &hostBuffer[si])
            }
        }
    }
}

//==============================================================================
/// StridedElements
/// Iterates storage elements using logical index coordinates and strides
public struct StridedElements<Shape, TensorElement>: MutableCollection
where Shape: TensorShape, TensorElement: StorageElement
{
    // properties
    public typealias Index = ElementIndex<Shape>
    public let alignment: Int
    public let hostBuffer: UnsafeMutableBufferPointer<TensorElement.Stored>
    public let strides: Shape
    public let startIndex: Index
    public let endIndex: Index
    
    //--------------------------------------------------------------------------
    /// init(tensor:
    /// creates a storage buffer iterator for reading tensor elments
    ///
    /// - Parameters:
    ///  - tensor: the tensor that will be read
    @inlinable public init(tensor: Tensor<Shape, TensorElement>) {
        let buff = tensor.read()
        let p = UnsafeMutablePointer(mutating: buff.baseAddress)
        hostBuffer = UnsafeMutableBufferPointer(start: p, count: buff.count)
        alignment = TensorElement.alignment(tensor.storageBase)
        strides = tensor.strides
        startIndex = Index(Shape.zero, 0)
        endIndex = Index(tensor.shape, tensor.count)
    }
    
    //--------------------------------------------------------------------------
    /// init(mutating:
    /// creates a storage buffer iterator for reading/writing tensor elments
    ///
    /// - Parameters:
    ///  - tensor: the tensor that will be written
    @inlinable public init(tensor: inout Tensor<Shape, TensorElement>) {
        hostBuffer = tensor.readWrite()
        alignment = TensorElement.alignment(tensor.storageBase)
        strides = tensor.strides
        startIndex = Index(Shape.zero, 0)
        endIndex = Index(tensor.shape, tensor.count)
    }
    
    //--------------------------------------------------------------------------
    /// init(mutating:strides:
    /// creates a storage buffer iterator for reading/writing tensor elments
    ///
    /// - Parameters:
    ///  - tensor: the tensor that will be written
    @inlinable public init(
        mutating tensor: Tensor<Shape, TensorElement>,
        _ shape: Shape,
        _ strides: Shape
    ) {
        // override for reduction projection
        self.strides = strides
        
        // convert logical base and strided span count to stored.
        // They will not be equal for packed element types like `Int4`
        let (storedBase, storedCount) = TensorElement
                .storedRange(start: tensor.storageBase,
                             count: tensor.stridedSpanCount)
        
        // make the data range available for reading/writing by the cpu
        hostBuffer = tensor.storage.readWrite(type: TensorElement.Stored.self,
                                              at: storedBase, count: storedCount)
        alignment = TensorElement.alignment(tensor.storageBase)
        startIndex = Index(Shape.zero, 0)
        endIndex = Index(shape, shape.elementCount())
    }
    
    //--------------------------------------------------------------------------
    // index(after:
    @inlinable public func index(after i: Index) -> Index {
        i.incremented(between: startIndex, and: endIndex)
    }
    
    //--------------------------------------------------------------------------
    // subscript
    @inlinable public subscript(position: Index) -> TensorElement.Value {
        get {
            // get logical strided linear element position
            let i = position.linearIndex(strides) + alignment
            
            // convert to stored index which might be less for packed elements
            let si = TensorElement.storedIndex(i)
            return TensorElement.value(at: i, from: hostBuffer[si])
        }
        
        set {
            // get logical strided linear element position
            let i = position.linearIndex(strides) + alignment
            
            // convert to stored index which might be less for packed elements
            let si = TensorElement.storedIndex(i)
            TensorElement.store(value: newValue, at: i, to: &hostBuffer[si])
        }
    }
}
