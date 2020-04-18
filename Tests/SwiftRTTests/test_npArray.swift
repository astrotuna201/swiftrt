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

class test_npArray: XCTestCase {
    //==========================================================================
    // support terminal test run
    static var allTests = [
        ("test_array", test_array),
        ("test_empty", test_empty),
        ("test_emptyLike", test_emptyLike),
        ("test_ones", test_ones),
        ("test_onesLike", test_onesLike),
        ("test_onesView", test_onesView),
        ("test_zeros", test_zeros),
        ("test_zerosLike", test_zerosLike),
        ("test_full", test_full),
        ("test_fullLike", test_fullLike),
        ("test_identity", test_identity),
        ("test_eye", test_eye),
    ]
    

    //==========================================================================
    // test_array
    func test_array() {
        // Rank1
        let b: [Int8] = [0, 1, 2]
        let _ = array(b)
        let _ = array(b, dtype: Int32.self)
        let _ = array(b, dtype: Double.self)

        let dt: [DType] = [1.5, 2.5, 3.5]
        let _ = array(dt)
        let _ = array(dt, dtype: Int32.self)
        let _ = array(dt, dtype: Double.self)

        let d: [Double] = [1.5, 2.5, 3.5]
        let _ = array(d)
        let _ = array(d, dtype: Int32.self)
        
        let _ = array([[0, 1, 2], [3, 4, 5]])
        let _ = array([0, 1, 2, 3, 4, 5], (2, 3))
        let _ = array(0..<6, (2, 3))
        
//        let a3 = array([[[0, 1, 2], [3, 4, 5]], [[6, 7, 8], [9, 10, 11]]])
//        let af4 = array(0..<120, (2, 3, 4, 5))

//        for r in 0..<a1.shape[0] {
//            for c in 0..<a1.shape[1] {
//                print(a[r, c])
//            }
//        }
        
    }

    //==========================================================================
    // test_empty
    func test_empty() {
        // T0
        let _ = empty()
        let _ = empty(dtype: Int.self)

        // T1
        let _ = empty(3)
        let _ = empty(3, order: .F)
        let _ = empty(3, dtype: Int.self)
        let _ = empty(3, dtype: Int.self, order: .F)

        // T2
        let _ = empty((2, 3))
        let _ = empty((2, 3), order: .F)
        let _ = empty((2, 3), dtype: Int.self)
        let _ = empty((2, 3), dtype: Int.self, order: .F)
        
        print(empty((2, 3), dtype: Int.self))
    }

    //==========================================================================
    // test_emptyLike
    func test_emptyLike() {
        let proto = empty((2, 3))
        
        let _ = empty(like: proto)
        let _ = empty(like: proto, shape: (6))
        let _ = empty(like: proto, shape: (1, 2, 3))
        let _ = empty(like: proto, order: .F)
        let _ = empty(like: proto, order: .F, shape: (1, 2, 3))
        let _ = empty(like: proto, dtype: Int.self)
        let _ = empty(like: proto, dtype: Int.self, shape: (1, 2, 3))
        let _ = empty(like: proto, dtype: Int.self, order: .F, shape: (1, 2, 3))
    }
    
    //==========================================================================
    // test_ones
    func test_ones() {
        // T0
        let _ = ones()
        let _ = ones(dtype: Int.self)

        // T1
        let _ = ones(3)
        let _ = ones(3, order: .F)
        let _ = ones(3, dtype: Int.self)
        let _ = ones(3, dtype: Int.self, order: .F)

        // T2
        let _ = ones((2, 3))
        let _ = ones((2, 3), order: .F)
        let _ = ones((2, 3), dtype: Int.self)
        let _ = ones((2, 3), dtype: Int.self, order: .F)
    }

    //==========================================================================
    // test_onesLike
    func test_onesLike() {
        let proto = ones((2, 3))
        
        let _ = ones(like: proto)
        let _ = ones(like: proto, shape: (6))
        let _ = ones(like: proto, shape: (1, 2, 3))
        let _ = ones(like: proto, order: .F)
        let _ = ones(like: proto, order: .F, shape: (1, 2, 3))
        let _ = ones(like: proto, dtype: Int.self)
        let _ = ones(like: proto, dtype: Int.self, shape: (1, 2, 3))
        let _ = ones(like: proto, dtype: Int.self, order: .F, shape: (1, 2, 3))
    }
    
    //==========================================================================
    // test_onesView
    func test_onesView() {
        let t1 = ones((4, 3), dtype: Int.self)
        let view = t1[1...2, ...]
        XCTAssert(view == [[1, 1, 1], [1, 1, 1]])
    }
    
    //==========================================================================
    // test_zeros
    func test_zeros() {
        // T0
        let _ = zeros()
        let _ = zeros(dtype: Int.self)

        // T1
        let _ = zeros(3)
        let _ = zeros(3, order: .F)
        let _ = zeros(3, dtype: Int.self)
        let _ = zeros(3, dtype: Int.self, order: .F)

        // T2
        let _ = zeros((2, 3))
        let _ = zeros((2, 3), order: .F)
        let _ = zeros((2, 3), dtype: Int.self)
        let _ = zeros((2, 3), dtype: Int.self, order: .F)
    }

    //==========================================================================
    // test_zerosLike
    func test_zerosLike() {
        let proto = zeros((2, 3))
        
        let _ = zeros(like: proto)
        let _ = zeros(like: proto, shape: (6))
        let _ = zeros(like: proto, shape: (1, 2, 3))
        let _ = zeros(like: proto, order: .F)
        let _ = zeros(like: proto, order: .F, shape: (1, 2, 3))
        let _ = zeros(like: proto, dtype: Int.self)
        let _ = zeros(like: proto, dtype: Int.self, shape: (1, 2, 3))
        let _ = zeros(like: proto, dtype: Int.self, order: .F, shape: (1, 2, 3))
    }
    
    //==========================================================================
    // test_full
    func test_full() {
        // T0
        let _ = full(42)
        let _ = full(42, dtype: Int.self)

        // T1
        let _ = full(3)
        let _ = full(3, 42, order: .F)
        let _ = full(3, 42, dtype: Int.self)
        let _ = full(3, 42, dtype: Int.self, order: .F)

        // T2
        let _ = full((2, 3), 42)
        let _ = full((2, 3), 42, order: .F)
        let _ = full((2, 3), 42, dtype: Int.self)
        let _ = full((2, 3), 42, dtype: Int.self, order: .F)
    }

    //==========================================================================
    // test_fullLike
    func test_fullLike() {
        let proto = empty((2, 3))
        
        let _ = full(like: proto, 42)
        let _ = full(like: proto, 42, shape: (6))
        let _ = full(like: proto, 42, shape: (1, 2, 3))
        let _ = full(like: proto, 42, order: .F)
        let _ = full(like: proto, 42, order: .F, shape: (1, 2, 3))
        let _ = full(like: proto, 42, dtype: Int.self)
        let _ = full(like: proto, 42, dtype: Int.self, shape: (1, 2, 3))
        let _ = full(like: proto, 42, dtype: Int.self, order: .F, shape: (1, 2, 3))
    }

    //==========================================================================
    // test_identity
    func test_identity() {
//        let _ = identity(3)
//        let _ = identity(3, order: .F)
//        let _ = identity(3, dtype: Int.self)
//        let _ = identity(3, dtype: Int.self, order: .F)
    }

    //==========================================================================
    // test_eye
    func test_eye() {
        // TODO
//        // verify signature combinations
//        let _ = eye(2)
//        let _ = eye(3, k: 1)
//        let _ = eye(4, 3, k: -1, dtype: Int.self)
//        let _ = eye(3, dtype: Int.self, order: .F)
//        print(eye(3, k: 0, dtype: Int.self))
//        // check plus
//        XCTAssert(eye(3, k: 1) == [
//            [0, 1, 0],
//            [0, 0, 1],
//            [0, 0, 0],
//        ])
//
//        // check subview plus
//        XCTAssert(eye(4, k: 1)[..<3, 1...] == [
//            [0, 1, 0],
//            [0, 0, 1],
//            [0, 0, 0],
//        ])
//
//        // check minus
//        XCTAssert(eye(3, k: -1) == [
//            [0, 0, 0],
//            [1, 0, 0],
//            [0, 1, 0],
//        ])
//
//        // check subview minus
//        XCTAssert(eye(4, k: -1)[1..., ..<3] == [
//            [0, 0, 0],
//            [1, 0, 0],
//            [0, 1, 0],
//        ])
    }
}
