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
/// ShapedBuffer
public protocol ShapedBuffer: Collection {
    associatedtype Element
    associatedtype Shape: ShapeProtocol

    var bufferPointer: UnsafePointer<Element> { get }
    var shape: Shape { get }
}

//==============================================================================
/// ElementBuffer
public struct ElementBuffer<Element, Shape>: ShapedBuffer
    where Shape: ShapeProtocol
{
    public typealias Index = Shape.Index
    public let bufferPointer: UnsafePointer<Element>
    public var count: Int { shape.count }
    public let shape: Shape

    @inlinable public var endIndex: Index { shape.endIndex }
    @inlinable public var startIndex: Index { shape.startIndex }

    //-----------------------------------
    // initializers
    @inlinable
    public init<T>(_ tensor: T, _ buffer: UnsafeBufferPointer<Element>)
        where T: TensorView, T.Shape == Shape
    {
        assert(tensor.viewOffset + tensor.shape.spanCount <= buffer.count)
        self.shape = tensor.shape
        self.bufferPointer = UnsafePointer(buffer.baseAddress!)
    }
    
    //-----------------------------------
    // Collection
    @inlinable @inline(__always)
    public func index(after i: Index) -> Index { shape.index(after: i) }

    @inlinable
    public subscript(index: Index) -> Element {
        bufferPointer[shape[index]]
    }
}

//==============================================================================
/// MutableShapedBuffer
public protocol MutableShapedBuffer: MutableCollection {
    associatedtype Element
    associatedtype Shape: ShapeProtocol

    var bufferPointer: UnsafeMutablePointer<Element> { get }
    var shape: Shape { get }
}

//==============================================================================
/// MutableElementBuffer
public struct MutableElementBuffer<Element, Shape>: MutableShapedBuffer
    where Shape: ShapeProtocol
{
    public typealias Index = Shape.Index
    public let bufferPointer: UnsafeMutablePointer<Element>
    public var count: Int { shape.count }
    public let shape: Shape
    
    @inlinable public var endIndex: Index { shape.endIndex }
    @inlinable public var startIndex: Index { shape.startIndex }
    
    //-----------------------------------
    // initializers
    @inlinable
    public init(_ shape: Shape, _ rawBuffer: UnsafeMutableRawBufferPointer) {
        let buffer = rawBuffer.bindMemory(to: Element.self)
        assert(buffer.count == shape.spanCount)
        self.shape = shape
        self.bufferPointer = UnsafeMutablePointer(buffer.baseAddress!)
    }
    
    //-----------------------------------
    // Collection
    @inlinable @inline(__always)
    public func index(after i: Index) -> Index { shape.index(after: i) }

    @inlinable
    public subscript(index: Index) -> Element {
        get { bufferPointer[shape[index]] }
        set { bufferPointer[shape[index]] = newValue }
    }
}
