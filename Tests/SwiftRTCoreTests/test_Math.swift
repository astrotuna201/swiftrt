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

class test_Math: XCTestCase {
    //==========================================================================
    // support terminal test run
    static var allTests = [
        ("test_Complex", test_juliaMath),
        ("test_abs", test_abs),
        ("test_atan2", test_atan2),
        ("test_erf", test_erf),
        ("test_exp", test_exp),
        ("test_log", test_log),
        ("test_neg", test_neg),
        ("test_sign", test_sign),
        ("test_squared", test_squared),
    ]

    override func setUpWithError() throws {
         log.level = .diagnostic
    }

    override func tearDownWithError() throws {
         log.level = .error
    }

    //--------------------------------------------------------------------------
    func test_juliaMath() {
        typealias CF = Complex<Float>
        let iterations = 3
        let size = (5, 5)
        let tolerance: Float = 4.0
        let C = CF(-0.8, 0.156)
        let first = CF(-1.7, 1.7)
        let last = CF(1.7, -1.7)
        
        var Z = repeating(array(from: first, to: last, (1, size.1)), size)
        print(Z)
        XCTAssert(Z == [
            [CF(-1.7, 1.7), CF(-0.85, 0.85), CF(0.0, 0.0), CF(0.85000014, -0.85000014), CF(1.7, -1.7)],
            [CF(-1.7, 1.7), CF(-0.85, 0.85), CF(0.0, 0.0), CF(0.85000014, -0.85000014), CF(1.7, -1.7)],
            [CF(-1.7, 1.7), CF(-0.85, 0.85), CF(0.0, 0.0), CF(0.85000014, -0.85000014), CF(1.7, -1.7)],
            [CF(-1.7, 1.7), CF(-0.85, 0.85), CF(0.0, 0.0), CF(0.85000014, -0.85000014), CF(1.7, -1.7)],
            [CF(-1.7, 1.7), CF(-0.85, 0.85), CF(0.0, 0.0), CF(0.85000014, -0.85000014), CF(1.7, -1.7)]
        ])
        
        
        var divergence = full(size, iterations)
        XCTAssert(divergence == [
            [3.0, 3.0, 3.0, 3.0, 3.0],
            [3.0, 3.0, 3.0, 3.0, 3.0],
            [3.0, 3.0, 3.0, 3.0, 3.0],
            [3.0, 3.0, 3.0, 3.0, 3.0],
            [3.0, 3.0, 3.0, 3.0, 3.0]
        ])
    }
    
    //--------------------------------------------------------------------------
    func test_abs() {
        // Int32 abs
        let a = array([-1, 2, -3, 4, -5], type: Int32.self)
        XCTAssert(abs(a) == [1, 2, 3, 4, 5])

        // Float16 abs
        let f16 = array([-1, 2, -3, 4, -5], type: Float16.self)
        XCTAssert(abs(f16) == [1, 2, 3, 4, 5])

        // Float abs
        let b = array([-1, 2, -3, 4, -5])
        XCTAssert(abs(b) == [1, 2, 3, 4, 5])
        
        let g = pullback(at: b, in: { abs($0) })(ones(like: b))
        XCTAssert(g == [-1, 1, -1, 1, -1])

        // Complex
        let c = abs(Complex<Float>(3, 4))
        XCTAssert(c == 5)
    }

    //--------------------------------------------------------------------------
    // test_atan2
    func test_atan2() {
        let a = array([[1, 2], [3, 4], [5, 6]])
        let b = array([[1, -2], [-3, 4], [5, -6]])
        let result = atan2(y: a, x: b)
        XCTAssert(result == [[0.7853982, 2.3561945], [2.3561945, 0.7853982], [0.7853982, 2.3561945]])

        let (da, db) = pullback(at: a, b, in: { atan2(y: $0, x: $1) })(ones(like: result))
        XCTAssert(da == [[0.5, -0.25], [-0.16666667, 0.125], [0.099999994, -0.083333336]])
        XCTAssert(db == [[-0.5, -0.25], [-0.16666667, -0.125], [-0.099999994, -0.083333336]])
    }

    //--------------------------------------------------------------------------
    // test_erf
    func test_erf() {
        let a = array([[0, -1], [2, -3], [4, 5]])
        XCTAssert(erf(a) == [[0.0, -0.8427008], [0.9953223, -0.9999779], [1.0, 1.0]])

        let da = pullback(at: a, in: { erf($0) })(ones(like: a))
        XCTAssert(da == [[1.1283792, 0.41510752], [0.020666987, 0.00013925305], [1.2698236e-07, 1.5670867e-11]])
    }
    
    //--------------------------------------------------------------------------
    // test_exp
    func test_exp() {
        let a = array(0..<6)
        let expected = a.map(Foundation.exp)
        XCTAssert(exp(a) == expected)
        
        let b = array([1.0, 2, 3])
        let g = pullback(at: b, in: { exp($0) })(ones(like: b))
        let e = array([2.7182817,  7.389056, 20.085537])
        let ae = elementsAlmostEqual(g, e, tolerance: 0.0001)
        // print(ae)
        let aea = ae.all()
        XCTAssert(aea.element)
    }

    //--------------------------------------------------------------------------
    // test_log
    func test_log() {
        let a = array([0.0, 1, 2, 3, 4, 5], (3, 2))
        let expected = a.map(Foundation.log)
        XCTAssert(log(a).flatArray == expected)

        let b = array([1.0, -2.0, 3.0])
        let g = pullback(at: b, in: { log($0) })(ones(like: b))
        let e = array([1.0, -0.5, 0.33333334])
        XCTAssert(elementsAlmostEqual(g, e, tolerance: 0.0001).all().element)
    }

    //--------------------------------------------------------------------------
    // test_neg
    func test_neg() {
        let a = array(0..<6, (3, 2))
        let expected = a.map(-)
        XCTAssert(neg(a).flatArray == expected)

        let b = -a
        XCTAssert(b.flatArray == expected)

        let c = array([1.0, -2.0, 3.0])
        let g = pullback(at: c, in: { (-$0) })(ones(like: c))
        XCTAssert(g == [-1, -1, -1])
    }

    //--------------------------------------------------------------------------
    // test_sign
    func test_sign() {
        let a = array([-1, 2, -3, 4])
        XCTAssert(sign(a) == [-1, 1, -1, 1])

        let b = array([-1.0, 2.0, -3.0, 4.0])
        let g = pullback(at: b, in: { sign($0) })(ones(like: b))
        XCTAssert(g == [0, 0, 0, 0])
    }

    //--------------------------------------------------------------------------
    // test_squared
    func test_squared() {
        let a = array([[0, -1], [2, -3], [4, 5]])
        XCTAssert(a.squared() == [[0, 1], [4, 9], [16, 25]])

        let b = array([1.0, -2.0, 3.0])
        let g = pullback(at: b, in: { $0.squared() })(ones(like: b))
        XCTAssert(g == [2, -4, 6])
    }
}
