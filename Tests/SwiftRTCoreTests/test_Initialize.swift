//******************************************************************************
// Copyright 2019 Google LLC
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
import XCTest
import Foundation
import SwiftRT

class test_Initialize: XCTestCase {
    //==========================================================================
    // support terminal test run
    static var allTests = [
        ("test_castElements", test_castElements),
        ("test_copy", test_copy),
        ("test_copyOnWrite", test_copyOnWrite),
        ("test_columnMajorDataView", test_columnMajorDataView),
        ("test_indenting", test_indenting),
        ("test_perfCreateTensorR2", test_perfCreateTensorR2),
        ("test_perfReadOnlyAccess", test_perfReadOnlyAccess),
        ("test_perfReadWriteAccess", test_perfReadWriteAccess),
        ("test_repeatElement", test_repeatElement),
        ("test_repeatRowVector", test_repeatRowVector),
        ("test_repeatColVector", test_repeatColVector),
        ("test_concatenateMatrixRows", test_concatenateMatrixRows),
        ("test_concatenateMatrixCols", test_concatenateMatrixCols),
        ("test_concatenateGradients", test_concatenateGradients),
    ]
    

    //--------------------------------------------------------------------------
    func test_castElements() {
        let fMatrix = array(0..<6, (3, 2))
        let iMatrix = TensorR2<Int32>(fMatrix)
        XCTAssert(iMatrix == [[0, 1], [2, 3], [4, 5]])
    }

    //--------------------------------------------------------------------------
    func test_copy() {
        let a = array(1...3)
        var b = array(repeatElement(0, count: 3))
        SwiftRT.copy(from: a, to: &b)
        XCTAssert(b == [1, 2, 3])
    }
    
    //--------------------------------------------------------------------------
    func test_copyOnWrite() {
//        Context.log.level = .diagnostic
        let a = array(0..<6, (3, 2))
        XCTAssert(a[1, 1] == 3)
        
        // copy shares the same storage
        var b = a
        XCTAssert(b[1, 1] == 3)
        
        // mutate b
        b[1, 1] = 7
        // m1's data should be unchanged
        XCTAssert(a[1, 1] == 3)
        XCTAssert(b[1, 1] == 7)
    }
    
    //--------------------------------------------------------------------------
    //   0, 1,
    //   2, 3,
    //   4, 5
    func test_columnMajorDataView() {
        let cm = array([0, 2, 4, 1, 3, 5], (3, 2), type: Int32.self, order: .F)
        XCTAssert(cm == [[0, 1], [2, 3], [4, 5]])
    }

    //--------------------------------------------------------------------------
    func test_indenting() {
        let a = array(0..<4)
        let b = Tensor2(indenting: a)
        XCTAssert(b.shape == [1, a.count])
    }
    
    //--------------------------------------------------------------------------
    func test_perfCreateTensorR2() {
        #if !DEBUG
        let iterations = 100000
        var count = 0
        measure {
            for _ in 0..<iterations {
                let a = empty((2, 2))
                count += a.count
            }
        }
        XCTAssert(count > 0)
        #endif
    }
    
    //--------------------------------------------------------------------------
    func test_perfReadOnlyAccess() {
        #if !DEBUG
        let iterations = 100000
        var value: Float = 0
        let a = array(1...4, (2, 2))
        
        measure {
            for _ in 1...iterations {
                value += a[0, 0]
            }
        }
        XCTAssert(value > 0)
        #endif
    }
    
    //--------------------------------------------------------------------------
    func test_perfReadWriteAccess() {
        #if !DEBUG
        let iterations = 100000
        let value: Float = 1
        var a = array(1...4, (2, 2))

        measure {
            for _ in 1...iterations {
                a[0, 0] += value
            }
        }
        XCTAssert(a[0, 0] > 0)
        #endif
    }

    //--------------------------------------------------------------------------
    func test_repeatElement() {
        let a = repeating(42, (2, 3, 10), type: Int32.self)
        let expected = [Int32](repeating: 42, count: a.count)
        XCTAssert(a.flatArray == expected)
    }
    
    //--------------------------------------------------------------------------
    func test_repeatRowVector() {
        let m = repeating(array(0...4, (1, 5)), (5, 5))
        XCTAssert(m == [
            [0, 1, 2, 3, 4],
            [0, 1, 2, 3, 4],
            [0, 1, 2, 3, 4],
            [0, 1, 2, 3, 4],
            [0, 1, 2, 3, 4],
        ])
    }
    
    //--------------------------------------------------------------------------
    func test_repeatColVector() {
        let m = repeating(array(0...4, (5, 1)), (5, 5))
        XCTAssert(m == [
            [0, 0, 0, 0, 0],
            [1, 1, 1, 1, 1],
            [2, 2, 2, 2, 2],
            [3, 3, 3, 3, 3],
            [4, 4, 4, 4, 4],
        ])
    }
    
    //--------------------------------------------------------------------------
    func test_concatenateMatrixRows() {
        let a = array(1...6, (2, 3))
        let b = array(7...12, (2, 3))
        let c = concatenate(a, b)
        XCTAssert(c.shape == [4, 3])
        XCTAssert(c == [
            [1,  2,  3],
            [4,  5,  6],
            [7,  8,  9],
            [10, 11, 12],
        ])
        
        
    }
    
    //--------------------------------------------------------------------------
    func test_concatenateMatrixCols() {
        let a = array(1...6, (2, 3))
        let b = array(7...12, (2, 3))
        let c = concatenate(a, b, axis: 1)
        XCTAssert(c.shape == [2, 6])
        XCTAssert(c == [
            [1,  2,  3, 7,  8,  9],
            [4,  5,  6, 10, 11, 12],
        ])
    }

    //--------------------------------------------------------------------------
    func test_concatenateGradients() {
        let a1 = array([1, 2, 3, 4, 5])
        let b1 = array([6, 7, 8, 9, 10])
        let a2 = array([1, 1, 1, 1, 1])
        let b2 = array([1, 1, 1, 1, 1])
        let (g1, g2) = gradient(at: a2, b2) { a, b in
            concatenate(a1 * a, b1 * b, axis: -1).sum().element
        }
        XCTAssertEqual(a1, g1)
        XCTAssertEqual(b1, g2)
    }
}
