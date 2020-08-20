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
// DeviceQueue functions with default cpu delegation
extension DeviceQueue where Self: CpuFunctions
{
    //--------------------------------------------------------------------------
    @inlinable func abs<S,E>(_ x: Tensor<S,E>, _ out: inout Tensor<S,E>)
    where E.Value: Comparable & SignedNumeric {
        cpu_abs(x, &out)
    }
    //--------------------------------------------------------------------------
    @inlinable func acos<S,E>(_ x: Tensor<S,E>, _ out: inout Tensor<S,E>)
    where E.Value: Real { cpu_acos(x, &out) }
    //--------------------------------------------------------------------------
    @inlinable func acosh<S,E>(_ x: Tensor<S,E>, _ out: inout Tensor<S,E>)
    where E.Value: Real { cpu_acosh(x, &out) }
    //--------------------------------------------------------------------------
    @inlinable public func add<S,E>(
        _ lhs: Tensor<S,E>, _ rhs: Tensor<S,E>,
        _ out: inout Tensor<S,E>
    ) where E.Value: AdditiveArithmetic {
        cpu_add(lhs, rhs, &out)
    }
    //--------------------------------------------------------------------------
    @inlinable func and<S,E>(_ lhs: Tensor<S,E>, _ rhs: Tensor<S,E>,
                             _ out: inout Tensor<S,E>)
    where E.Value == Bool { cpu_and(lhs, rhs, &out) }
    //--------------------------------------------------------------------------
    @inlinable func asin<S,E>(_ x: Tensor<S,E>, _ out: inout Tensor<S,E>)
    where E.Value: Real { cpu_asin(x, &out) }
    //--------------------------------------------------------------------------
    @inlinable func asinh<S,E>(_ x: Tensor<S,E>, _ out: inout Tensor<S,E>)
    where E.Value: Real { cpu_asinh(x, &out) }
    //--------------------------------------------------------------------------
    @inlinable func atan<S,E>(_ x: Tensor<S,E>, _ out: inout Tensor<S,E>)
    where E.Value: Real { cpu_atan(x, &out) }
    //--------------------------------------------------------------------------
    @inlinable func atan2<S,E>(_ y: Tensor<S,E>, _ x: Tensor<S,E>,
                               _ out: inout Tensor<S,E>)
    where E.Value: Real { cpu_atan2(y, x, &out) }
    //--------------------------------------------------------------------------
    @inlinable func atanh<S,E>(_ x: Tensor<S,E>, _ out: inout Tensor<S,E>)
    where E.Value: Real { cpu_atanh(x, &out) }
    //--------------------------------------------------------------------------
    @inlinable func cast<S, E, RE>(from buffer: Tensor<S,E>,
                                   to out: inout Tensor<S,RE>)
    where E.Value: BinaryFloatingPoint, RE.Value: BinaryInteger
    { cpu_cast(from: buffer, to: &out) }
    //--------------------------------------------------------------------------
    @inlinable func cast<S, E, RE>(from buffer: Tensor<S,E>,
                                   to out: inout Tensor<S,RE>)
    where E.Value: BinaryInteger, RE.Value: BinaryFloatingPoint
    { cpu_cast(from: buffer, to: &out) }
    //--------------------------------------------------------------------------
    @inlinable func copy<S,E>(from a: Tensor<S,E>, to b: inout Tensor<S,E>)
    where S: TensorShape { cpu_copy(from: a, to: &b) }
    //--------------------------------------------------------------------------
    @inlinable func cos<S,E>(_ x: Tensor<S,E>, _ out: inout Tensor<S,E>)
    where E.Value: Real { cpu_cos(x, &out) }
    //--------------------------------------------------------------------------
    @inlinable func cosh<S,E>(_ x: Tensor<S,E>, _ out: inout Tensor<S,E>)
    where E.Value: Real { cpu_cosh(x, &out) }
    //--------------------------------------------------------------------------
    @inlinable func delay(_ interval: TimeInterval) { cpu_delay(interval) }
    //--------------------------------------------------------------------------
    @inlinable func div<S,E>(_ lhs: Tensor<S,E>, _ rhs: Tensor<S,E>,
                             _ out: inout Tensor<S,E>)
    where E.Value: AlgebraicField { cpu_div(lhs, rhs, &out) }
    //--------------------------------------------------------------------------
    @inlinable func elementsAlmostEqual<S,E>(
        _ lhs: Tensor<S,E>,
        _ rhs: Tensor<S,E>,
        _ tolerance: E.Value,
        _ out: inout Tensor<S,Bool>
    ) where E.Value: SignedNumeric & Comparable {
        cpu_elementsAlmostEqual(lhs, rhs, tolerance, &out)
    }
    //--------------------------------------------------------------------------
    @inlinable func equal<S,E>(_ lhs: Tensor<S,E>, _ rhs: Tensor<S,E>,
                               _ out: inout Tensor<S,Bool>)
    where E.Value: Equatable { cpu_equal(lhs, rhs, &out) }
    //--------------------------------------------------------------------------
    @inlinable func erf<S,E>(_ x: Tensor<S,E>, _ out: inout Tensor<S,E>)
    where E.Value: Real { cpu_erf(x, &out) }
    //--------------------------------------------------------------------------
    @inlinable func erfc<S,E>(_ x: Tensor<S,E>, _ out: inout Tensor<S,E>)
    where E.Value: Real { cpu_erfc(x, &out) }
    //--------------------------------------------------------------------------
    @inlinable func exp<S,E>(_ x: Tensor<S,E>, _ out: inout Tensor<S,E>)
    where E.Value: Real { cpu_exp(x, &out) }
    //--------------------------------------------------------------------------
    @inlinable func exp2<S,E>(_ x: Tensor<S,E>, _ out: inout Tensor<S,E>)
    where E.Value: Real { cpu_exp2(x, &out) }
    //--------------------------------------------------------------------------
    @inlinable func exp10<S,E>(_ x: Tensor<S,E>, _ out: inout Tensor<S,E>)
    where E.Value: Real { cpu_exp10(x, &out) }
    //--------------------------------------------------------------------------
    @inlinable func expMinusOne<S,E>(_ x: Tensor<S,E>, _ out: inout Tensor<S,E>)
    where E.Value: Real { cpu_expMinusOne(x, &out) }
    //--------------------------------------------------------------------------
    @inlinable func gamma<S,E>(_ x: Tensor<S,E>, _ out: inout Tensor<S,E>)
    where E.Value: Real { cpu_gamma(x, &out) }
    //--------------------------------------------------------------------------
    @inlinable func greater<S,E>(_ lhs: Tensor<S,E>, _ rhs: Tensor<S,E>,
                                 _ out: inout Tensor<S,Bool>)
    where E.Value: Comparable { cpu_greater(lhs, rhs, &out) }
    //--------------------------------------------------------------------------
    @inlinable func greaterOrEqual<S,E>(
        _ lhs: Tensor<S,E>, _ rhs: Tensor<S,E>,
        _ out: inout Tensor<S,Bool>
    ) where E.Value: Comparable {
        cpu_greaterOrEqual(lhs, rhs, &out)
    }
    //--------------------------------------------------------------------------
    @inlinable func hypot<S,E>(_ x: Tensor<S,E>, _ y: Tensor<S,E>,
                               _ out: inout Tensor<S,E>)
    where E.Value: Real { cpu_hypot(x, y, &out) }
    //--------------------------------------------------------------------------
    @inlinable func less<S,E>(_ lhs: Tensor<S,E>, _ rhs: Tensor<S,E>,
                              _ out: inout Tensor<S,Bool>)
    where E.Value: Comparable { cpu_less(lhs, rhs, &out) }
    //--------------------------------------------------------------------------
    @inlinable func lessOrEqual<S,E>(_ lhs: Tensor<S,E>, _ rhs: Tensor<S,E>,
                                     _ out: inout Tensor<S,Bool>)
    where E.Value: Comparable { cpu_lessOrEqual(lhs, rhs, &out) }
    //--------------------------------------------------------------------------
    @inlinable func log<S,E>(_ x: Tensor<S,E>, _ out: inout Tensor<S,E>)
    where E.Value: Real { cpu_log(x, &out) }
    //--------------------------------------------------------------------------
    @inlinable func log<S,E>(onePlus x: Tensor<S,E>, _ out: inout Tensor<S,E>)
    where E.Value: Real { cpu_log(onePlus: x, &out) }
    //--------------------------------------------------------------------------
    @inlinable func log2<S,E>(_ x: Tensor<S,E>, _ out: inout Tensor<S,E>)
    where E.Value: Real { cpu_log2(x, &out) }
    //--------------------------------------------------------------------------
    @inlinable func log10<S,E>(_ x: Tensor<S,E>, _ out: inout Tensor<S,E>)
    where E.Value: Real { cpu_log10(x, &out) }
    //--------------------------------------------------------------------------
    @inlinable func logGamma<S,E>(_ x: Tensor<S,E>, _ out: inout Tensor<S,E>)
    where E.Value: Real { cpu_logGamma(x, &out) }
    //--------------------------------------------------------------------------
//    @inlinable func matmul2<E>(type: E.Type) -> DeviceMatmul2<E>
//    where E: StorageElement, E.Value: StorageElement & Numeric { CpuMatmul2<E>() }
    //--------------------------------------------------------------------------
    @inlinable func matmul<E>(
        _ lhs: TensorR2<E>, _ transposeLhs: Bool,
        _ rhs: TensorR2<E>, _ transposeRhs: Bool,
        _ out: inout TensorR2<E>
    ) where E.Value: Numeric {
        cpu_matmul(lhs, transposeLhs, rhs, transposeRhs, &out)
    }
    //--------------------------------------------------------------------------
    @inlinable func matmul<E>(
        _ lhs: TensorR3<E>, _ transposeLhs: Bool,
        _ rhs: TensorR3<E>, _ transposeRhs: Bool,
        _ out: inout TensorR3<E>
    ) where E.Value: Numeric {
        cpu_matmul(lhs, transposeLhs, rhs, transposeRhs, &out)
    }
    //--------------------------------------------------------------------------
    @inlinable func max<S,E>(_ lhs: Tensor<S,E>, _ rhs: Tensor<S,E>,
                             _ out: inout Tensor<S,E>)
    where E.Value: Comparable { cpu_max(lhs, rhs, &out) }
    //--------------------------------------------------------------------------
    @inlinable func min<S,E>(_ lhs: Tensor<S,E>, _ rhs: Tensor<S,E>,
                             _ out: inout Tensor<S,E>)
    where E.Value: Comparable { cpu_min(lhs, rhs, &out) }
    //--------------------------------------------------------------------------
    @inlinable func mul<S,E>(_ lhs: Tensor<S,E>, _ rhs: Tensor<S,E>,
                             _ out: inout Tensor<S,E>)
    where E.Value: Numeric { cpu_mul(lhs, rhs, &out) }
    //--------------------------------------------------------------------------
    @inlinable func neg<S,E>(_ x: Tensor<S,E>, _ out: inout Tensor<S,E>)
    where E.Value: SignedNumeric { cpu_neg(x, &out) }
    //--------------------------------------------------------------------------
    @inlinable func notEqual<S,E>(_ lhs: Tensor<S,E>, _ rhs: Tensor<S,E>,
                                  _ out: inout Tensor<S,Bool>)
    where E.Value: Equatable { cpu_notEqual(lhs, rhs, &out) }
    //--------------------------------------------------------------------------
    @inlinable func or<S,E>(_ lhs: Tensor<S,E>, _ rhs: Tensor<S,E>,
                          _ out: inout Tensor<S,E>)
    where E.Value == Bool { cpu_or(lhs, rhs, &out) }
    //--------------------------------------------------------------------------
    @inlinable func pow<S,E>(_ x: Tensor<S,E>, _ y: Tensor<S,E>,
                             _ out: inout Tensor<S,E>)
    where E.Value: Real { cpu_pow(x, y, &out) }
    //--------------------------------------------------------------------------
    @inlinable func pow<S, E>(_ x: Tensor<S,E>, _ n: Int,
                              _ out: inout Tensor<S,E>)
    where E.Value: Real { cpu_pow(x, n, &out) }
    //--------------------------------------------------------------------------
    @inlinable func replace<S,E>(
        _ x: Tensor<S,E>, _ y: Tensor<S,E>,
        _ condition: Tensor<S,Bool>,
        _ out: inout Tensor<S,E>)
    { cpu_replace(x, y, condition, &out) }
    //--------------------------------------------------------------------------
    @inlinable func root<S,E>(_ x: Tensor<S,E>, _ n: Int,
                              _ out: inout Tensor<S,E>)
    where E.Value: Real { cpu_root(x, n, &out) }
    //--------------------------------------------------------------------------
    @inlinable func sigmoid<S,E>(_ x: Tensor<S,E>, _ out: inout Tensor<S,E>)
    where E.Value: Real { cpu_sigmoid(x, &out) }
    //--------------------------------------------------------------------------
    @inlinable func sign<S,E>(_ x: Tensor<S,E>, _ out: inout Tensor<S,E>)
    where E.Value: Comparable & SignedNumeric {
        cpu_sign(x, &out)
    }
    //--------------------------------------------------------------------------
    @inlinable func sin<S,E>(_ x: Tensor<S,E>, _ out: inout Tensor<S,E>)
    where E.Value: Real { cpu_sin(x, &out) }
    //--------------------------------------------------------------------------
    @inlinable func sinh<S,E>(_ x: Tensor<S,E>, _ out: inout Tensor<S,E>)
    where E.Value: Real { cpu_sinh(x, &out) }
    //--------------------------------------------------------------------------
    @inlinable func subtract<S,E>(
        _ lhs: Tensor<S,E>, _ rhs: Tensor<S,E>,
        _ out: inout Tensor<S,E>
    ) where E.Value: AdditiveArithmetic {
        cpu_subtract(lhs,rhs,&out)
    }
    //--------------------------------------------------------------------------
    @inlinable func sqrt<S,E>(_ x: Tensor<S,E>, _ out: inout Tensor<S,E>)
    where E.Value: Real { cpu_sqrt(x, &out) }
    //--------------------------------------------------------------------------
    @inlinable func squared<S,E>(_ x: Tensor<S,E>, _ out: inout Tensor<S,E>)
    where E.Value: Numeric { cpu_squared(x, &out) }
    //--------------------------------------------------------------------------
    @inlinable func tan<S,E>(_ x: Tensor<S,E>, _ out: inout Tensor<S,E>)
    where E.Value: Real { cpu_tan(x, &out) }
    //--------------------------------------------------------------------------
    @inlinable func tanh<S,E>(_ x: Tensor<S,E>, _ out: inout Tensor<S,E>)
    where E.Value: Real { cpu_tanh(x, &out) }
}

//==============================================================================
// DeviceQueue specialized derivative delegation
extension DeviceQueue where Self: CpuFunctions
{
    //--------------------------------------------------------------------------
    @inlinable func vjpMin<S,E>(
        _ x: Tensor<S,E>, _ y: Tensor<S,E>, _ scale: Tensor<S,E>,
        _ out: inout Tensor<S,E>)
    where E.Value: Comparable & Numeric
    { cpu_vjpMin(x, y, scale, &out) }

    @inlinable func vjpMin<S,E>(
        _ x: Tensor<S,E>, _ y: Tensor<S,E>, _ scale: Tensor<S,E>,
        _ resultTrue: inout Tensor<S,E>, _ resultFalse: inout Tensor<S,E>)
    where E.Value: Comparable & Numeric
    { cpu_vjpMin(x, y, scale, &resultTrue, &resultFalse) }
    
    //--------------------------------------------------------------------------
    @inlinable func vjpMax<S,E>(
        _ x: Tensor<S,E>, _ y: Tensor<S,E>, _ scale: Tensor<S,E>,
        _ out: inout Tensor<S,E>)
    where E.Value: Comparable & Numeric
    { cpu_vjpMax(x, y, scale, &out) }

    @inlinable func vjpMax<S,E>(
        _ x: Tensor<S,E>, _ y: Tensor<S,E>, _ scale: Tensor<S,E>,
        _ resultTrue: inout Tensor<S,E>, _ resultFalse: inout Tensor<S,E>)
    where E.Value: Comparable & Numeric
    { cpu_vjpMax(x, y, scale, &resultTrue, &resultFalse) }
}

//==============================================================================
// Cpu device queue function implementations
extension CpuFunctions where Self: DeviceQueue
{
    //--------------------------------------------------------------------------
    @inlinable func cpu_abs<S,E>(_ x: Tensor<S,E>, _ out: inout Tensor<S,E>)
    where E.Value: Comparable & SignedNumeric {
        mapOp("cpu_abs", x, &out) { Swift.abs($0) }
    }
    
    //--------------------------------------------------------------------------
    @inlinable func cpu_acos<S,E>(_ x: Tensor<S,E>, _ out: inout Tensor<S,E>)
    where E.Value: Real {
        mapOp("cpu_acos", x, &out) { .acos($0) }
    }
    
    //--------------------------------------------------------------------------
    @inlinable func cpu_acosh<S,E>(_ x: Tensor<S,E>, _ out: inout Tensor<S,E>)
    where E.Value: Real {
        mapOp("cpu_acosh", x, &out) { .acosh($0) }
    }
    
    //--------------------------------------------------------------------------
    @inlinable func cpu_add<S,E>(_ lhs: Tensor<S,E>, _ rhs: Tensor<S,E>,
                                 _ out: inout Tensor<S,E>)
    where E.Value: AdditiveArithmetic {
        mapOpAdd("cpu_add", lhs, rhs, &out)
    }
    
    //--------------------------------------------------------------------------
    @inlinable func cpu_and<S,E>(_ lhs: Tensor<S,E>, _ rhs: Tensor<S,E>,
                                 _ out: inout Tensor<S,E>)
    where E.Value == Bool {
        mapOp("cpu_and", lhs, rhs, &out) { $0 && $1 }
    }
    
    //--------------------------------------------------------------------------
    @inlinable func cpu_asin<S,E>(_ x: Tensor<S,E>, _ out: inout Tensor<S,E>)
    where E.Value: Real {
        mapOp("cpu_asin", x, &out) { .asin($0) }
    }
    
    //--------------------------------------------------------------------------
    @inlinable func cpu_asinh<S,E>(_ x: Tensor<S,E>, _ out: inout Tensor<S,E>)
    where E.Value: Real {
        mapOp("cpu_asinh", x, &out) { .asinh($0) }
    }
    
    //--------------------------------------------------------------------------
    @inlinable func cpu_atan<S,E>(_ x: Tensor<S,E>, _ out: inout Tensor<S,E>)
    where E.Value: Real {
        mapOp("cpu_atan", x, &out) { .atan($0) }
    }
    
    //--------------------------------------------------------------------------
    @inlinable func cpu_atan2<S,E>(_ y: Tensor<S,E>, _ x: Tensor<S,E>,
                                   _ out: inout Tensor<S,E>)
    where E.Value: Real {
        mapOp("cpu_atan2", y, x, &out) { .atan2(y: $0, x: $1) }
    }
    
    //--------------------------------------------------------------------------
    @inlinable func cpu_atanh<S,E>(_ x: Tensor<S,E>, _ out: inout Tensor<S,E>)
    where E.Value: Real {
        mapOp("cpu_atanh", x, &out) { .atanh($0) }
    }
    
    //--------------------------------------------------------------------------
    // FloatingPoint -> Integer
    @inlinable func cpu_cast<S, E, RE>(
        from buffer: Tensor<S,E>,
        to out: inout Tensor<S,RE>
    ) where E.Value: BinaryFloatingPoint,
            RE.Value: BinaryInteger {
        mapOp("cpu_cast", buffer, &out) { RE.Value($0) }
    }
    
    //--------------------------------------------------------------------------
    // Integer -> FloatingPoint
    @inlinable func cpu_cast<S, E, RE>(
        from buffer: Tensor<S,E>,
        to out: inout Tensor<S,RE>
    ) where E.Value: BinaryInteger,
            RE.Value: BinaryFloatingPoint {
        mapOp("cpu_cast", buffer, &out) { RE.Value($0) }
    }
    
    //--------------------------------------------------------------------------
    @inlinable func cpu_copy<S,E>(from a: Tensor<S,E>, to b: inout Tensor<S,E>)
    where S: TensorShape {
        mapOp("cpu_copy", a, &b) { $0 }
    }
    
    //--------------------------------------------------------------------------
    @inlinable func cpu_cos<S,E>(_ x: Tensor<S,E>, _ out: inout Tensor<S,E>)
    where E.Value: Real {
        mapOp("cpu_cos", x, &out) { .cos($0) }
    }
    
    //--------------------------------------------------------------------------
    @inlinable func cpu_cosh<S,E>(_ x: Tensor<S,E>, _ out: inout Tensor<S,E>)
    where E.Value: Real {
        mapOp("cpu_cosh", x, &out) { .cosh($0) }
    }
    
    //--------------------------------------------------------------------------
    @inlinable func cpu_delay(_ interval: TimeInterval) {
        assert(Thread.current === creatorThread, _messageQueueThreadViolation)
        Thread.sleep(forTimeInterval: interval)
    }
    
    //--------------------------------------------------------------------------
    @inlinable func cpu_div<S,E>(_ lhs: Tensor<S,E>, _ rhs: Tensor<S,E>,
                                 _ out: inout Tensor<S,E>)
    where E.Value: AlgebraicField {
        mapOpDiv("cpu_div", lhs, rhs, &out)
    }
    
    //--------------------------------------------------------------------------
    @inlinable func cpu_elementsAlmostEqual<S,E>(
        _ lhs: Tensor<S,E>,
        _ rhs: Tensor<S,E>,
        _ tolerance: E.Value,
        _ out: inout Tensor<S,Bool>)
    where E.Value: SignedNumeric & Comparable {
        mapOp("cpu_elementsAlmostEqual",
              lhs, rhs, &out) { Swift.abs($0 - $1) <= tolerance }
    }
    
    //--------------------------------------------------------------------------
    @inlinable func cpu_equal<S,E>(_ lhs: Tensor<S,E>, _ rhs: Tensor<S,E>,
                                   _ out: inout Tensor<S,Bool>)
    where E.Value: Equatable {
        mapOp("cpu_equal", lhs, rhs, &out, ==)
    }
    
    //--------------------------------------------------------------------------
    @inlinable func cpu_erf<S,E>(_ x: Tensor<S,E>, _ out: inout Tensor<S,E>)
    where E.Value: Real {
        mapOp("cpu_erf", x, &out) { .erf($0) }
    }
    
    //--------------------------------------------------------------------------
    @inlinable func cpu_erfc<S,E>(_ x: Tensor<S,E>, _ out: inout Tensor<S,E>)
    where E.Value: Real {
        mapOp("cpu_erfc", x, &out) { .erfc($0) }
    }
    
    //--------------------------------------------------------------------------
    @inlinable func cpu_exp<S,E>(_ x: Tensor<S,E>, _ out: inout Tensor<S,E>)
    where E.Value: Real {
        mapOp("cpu_exp", x, &out) { .exp($0) }
    }
    
    //--------------------------------------------------------------------------
    @inlinable func cpu_exp2<S,E>(_ x: Tensor<S,E>, _ out: inout Tensor<S,E>)
    where E.Value: Real {
        mapOp("cpu_exp2", x, &out) { .exp2($0) }
    }
    
    //--------------------------------------------------------------------------
    @inlinable func cpu_exp10<S,E>(_ x: Tensor<S,E>, _ out: inout Tensor<S,E>)
    where E.Value: Real {
        mapOp("cpu_exp10", x, &out) { .exp10($0) }
    }
    
    //--------------------------------------------------------------------------
    @inlinable func cpu_expMinusOne<S,E>(_ x: Tensor<S,E>, _ out: inout Tensor<S,E>)
    where E.Value: Real {
        mapOp("cpu_expMinusOne", x, &out) { .expMinusOne($0) }
    }
    
    //--------------------------------------------------------------------------
    @inlinable func cpu_gamma<S,E>(_ x: Tensor<S,E>, _ out: inout Tensor<S,E>)
    where E.Value: Real {
        mapOp("cpu_gamma", x, &out) { .gamma($0) }
    }
    
    //--------------------------------------------------------------------------
    @inlinable func cpu_greater<S,E>(_ lhs: Tensor<S,E>, _ rhs: Tensor<S,E>,
                                     _ out: inout Tensor<S,Bool>)
    where E.Value: Comparable {
        mapOp("cpu_greater", lhs, rhs, &out, >)
    }
    
    //--------------------------------------------------------------------------
    @inlinable func cpu_greaterOrEqual<S,E>(
        _ lhs: Tensor<S,E>, _ rhs: Tensor<S,E>,
        _ out: inout Tensor<S,Bool>)
    where E.Value: Comparable {
        mapOp("cpu_greaterOrEqual", lhs, rhs, &out, >=)
    }
    
    //--------------------------------------------------------------------------
    @inlinable func cpu_hypot<S,E>(_ x: Tensor<S,E>, _ y: Tensor<S,E>,
                                   _ out: inout Tensor<S,E>)
    where E.Value: Real {
        mapOp("cpu_hypot", x, y, &out) { .hypot($0, $1) }
    }
    
    //--------------------------------------------------------------------------
    @inlinable func cpu_less<S,E>(_ lhs: Tensor<S,E>, _ rhs: Tensor<S,E>,
                                  _ out: inout Tensor<S,Bool>)
    where E.Value: Comparable {
        mapOp("cpu_less", lhs, rhs, &out, <)
    }
    
    //--------------------------------------------------------------------------
    @inlinable func cpu_lessOrEqual<S,E>(_ lhs: Tensor<S,E>, _ rhs: Tensor<S,E>,
                                         _ out: inout Tensor<S,Bool>)
    where E.Value: Comparable {
        mapOp("cpu_lessOrEqual", lhs, rhs, &out, <=)
    }
    
    //--------------------------------------------------------------------------
    @inlinable func cpu_log<S,E>(_ x: Tensor<S,E>, _ out: inout Tensor<S,E>)
    where E.Value: Real {
        mapOp("cpu_log", x, &out) { .log($0) }
    }
    
    //--------------------------------------------------------------------------
    @inlinable func cpu_log<S,E>(onePlus x: Tensor<S,E>, _ out: inout Tensor<S,E>)
    where E.Value: Real {
        mapOp("cpu_log", x, &out) { .log(onePlus: $0) }
    }
    
    //--------------------------------------------------------------------------
    @inlinable func cpu_log2<S,E>(_ x: Tensor<S,E>, _ out: inout Tensor<S,E>)
    where E.Value: Real {
        mapOp("cpu_log2", x, &out) { .log2($0) }
    }
    
    //--------------------------------------------------------------------------
    @inlinable func cpu_log10<S,E>(_ x: Tensor<S,E>, _ out: inout Tensor<S,E>)
    where E.Value: Real {
        mapOp("cpu_log10", x, &out) { .log10($0) }
    }
    
    //--------------------------------------------------------------------------
    @inlinable func cpu_logGamma<S,E>(_ x: Tensor<S,E>, _ out: inout Tensor<S,E>)
    where E.Value: Real {
        mapOp("cpu_logGamma", x, &out) { .logGamma($0) }
    }
    
    //--------------------------------------------------------------------------
    @inlinable func cpu_matmul<E>(
        _ lhs: TensorR2<E>, _ transposeLhs: Bool,
        _ rhs: TensorR2<E>, _ transposeRhs: Bool,
        _ out: inout TensorR2<E>
    ) where E.Value: Numeric {
        let lhs = transposeLhs ? lhs.t : lhs
        let rhs = transposeRhs ? rhs.t : rhs
        assert(out.shape[0] == lhs.shape[0] &&
                out.shape[1] == rhs.shape[1],
               "matmul inner dimensions must be equal")
        //-------------------------------
        // simple place holder
        for r in 0..<out.shape[0] {
            let row = lhs[r, ...]
            for c in 0..<out.shape[1] {
                let col = rhs[..., c]
                out[r, c] = zip(row, col).reduce(into: 0) { $0 += $1.0 * $1.1 }
            }
        }
    }
    
    //--------------------------------------------------------------------------
    @inlinable func cpu_matmul<E>(
        _ lhs: TensorR3<E>, _ transposeLhs: Bool,
        _ rhs: TensorR3<E>, _ transposeRhs: Bool,
        _ out: inout TensorR3<E>
    ) where E.Value: Numeric {
        let lhs = transposeLhs ? lhs.t : lhs
        let rhs = transposeRhs ? rhs.t : rhs
        assert(out.shape[0] == lhs.shape[0] &&
                out.shape[1] == lhs.shape[1] &&
                out.shape[2] == rhs.shape[2],
               "matmul inner dimensions must be equal")
        //-------------------------------
        // simple place holder
        for n in 0..<out.shape[0] {
            for r in 0..<out.shape[1] {
                let row = lhs[n, r, ...]
                for c in 0..<out.shape[2] {
                    let col = rhs[n, ..., c]
                    out[n, r, c] = zip(row, col).reduce(into: 0) { $0 += $1.0 * $1.1 }
                }
            }
        }
    }
    
    //--------------------------------------------------------------------------
    @inlinable func cpu_max<S,E>(_ lhs: Tensor<S,E>, _ rhs: Tensor<S,E>,
                                 _ out: inout Tensor<S,E>)
    where E.Value: Comparable {
        mapOp("cpu_max", lhs, rhs, &out) { $0 >= $1 ? $0 : $1 }
    }
    
    //--------------------------------------------------------------------------
    @inlinable func cpu_min<S,E>(_ lhs: Tensor<S,E>, _ rhs: Tensor<S,E>,
                                 _ out: inout Tensor<S,E>)
    where E.Value: Comparable {
        mapOp("cpu_min", lhs, rhs, &out) { Swift.min($0, $1) }
    }
    
    //--------------------------------------------------------------------------
    @inlinable func cpu_mul<S,E>(_ lhs: Tensor<S,E>, _ rhs: Tensor<S,E>,
                                 _ out: inout Tensor<S,E>)
    where E.Value: Numeric {
        mapOpMul("cpu_mul", lhs, rhs, &out)
    }
    
    //--------------------------------------------------------------------------
    @inlinable func cpu_neg<S,E>(_ x: Tensor<S,E>, _ out: inout Tensor<S,E>)
    where E.Value: SignedNumeric {
        mapOp("cpu_neg", x, &out, -)
    }
    
    //--------------------------------------------------------------------------
    @inlinable func cpu_notEqual<S,E>(_ lhs: Tensor<S,E>, _ rhs: Tensor<S,E>,
                                      _ out: inout Tensor<S,Bool>)
    where E.Value: Equatable {
        mapOp("cpu_notEqual", lhs, rhs, &out, !=)
    }
    
    //--------------------------------------------------------------------------
    @inlinable func cpu_or<S,E>(_ lhs: Tensor<S,E>, _ rhs: Tensor<S,E>,
                                _ out: inout Tensor<S,E>)
    where E.Value == Bool {
        mapOp("cpu_or", lhs, rhs, &out) { $0 || $1 }
    }
    
    //--------------------------------------------------------------------------
    @inlinable func cpu_pow<S,E>(_ x: Tensor<S,E>, _ y: Tensor<S,E>,
                                 _ out: inout Tensor<S,E>)
    where E.Value: Real {
        mapOp("cpu_pow", x, y, &out) { .pow($0, $1) }
    }
    
    //--------------------------------------------------------------------------
    @inlinable func cpu_pow<S, E>(_ x: Tensor<S,E>, _ n: Int,
                                  _ out: inout Tensor<S,E>)
    where E.Value: Real {
        mapOp("cpu_pow", x, &out) { .pow($0, n) }
    }
    
    //--------------------------------------------------------------------------
    @inlinable func cpu_replace<S,E>(
        _ x: Tensor<S,E>, _ y: Tensor<S,E>,
        _ condition: Tensor<S,Bool>,
        _ out: inout Tensor<S,E>)
    {
        mapOp("cpu_replace", condition, y, x, &out) { $0 ? $1 : $2 }
    }
    
    //--------------------------------------------------------------------------
    @inlinable func cpu_root<S,E>(_ x: Tensor<S,E>, _ n: Int,
                                  _ out: inout Tensor<S,E>)
    where E.Value: Real {
        mapOp("cpu_root", x, &out) { .root($0, n) }
    }
    
    //--------------------------------------------------------------------------
    @inlinable func cpu_sigmoid<S,E>(_ x: Tensor<S,E>, _ out: inout Tensor<S,E>)
    where E.Value: Real {
        mapOp("cpu_sigmoid", x, &out) { 1 / (1 + .exp(-$0)) }
    }
    
    //--------------------------------------------------------------------------
    @inlinable func cpu_sign<S,E>(_ x: Tensor<S,E>, _ out: inout Tensor<S,E>)
    where E.Value: Comparable & SignedNumeric {
        mapOp("cpu_sign", x, &out) { $0 < 0 ? -1 : 1 }
    }
    
    //--------------------------------------------------------------------------
    @inlinable func cpu_sin<S,E>(_ x: Tensor<S,E>, _ out: inout Tensor<S,E>)
    where E.Value: Real {
        mapOp("cpu_sin", x, &out) { .sin($0) }
    }
    
    //--------------------------------------------------------------------------
    @inlinable func cpu_sinh<S,E>(_ x: Tensor<S,E>, _ out: inout Tensor<S,E>)
    where E.Value: Real {
        mapOp("cpu_sinh", x, &out) { .sinh($0) }
    }
    
    //--------------------------------------------------------------------------
    @inlinable func cpu_subtract<S,E>(
        _ lhs: Tensor<S,E>, _ rhs: Tensor<S,E>,
        _ out: inout Tensor<S,E>)
    where E.Value: AdditiveArithmetic {
        mapOpSub("cpu_subtract", lhs, rhs, &out)
    }
    
    //--------------------------------------------------------------------------
    @inlinable func cpu_sqrt<S,E>(_ x: Tensor<S,E>, _ out: inout Tensor<S,E>)
    where E.Value: Real {
        mapOp("cpu_sqrt", x, &out) { .sqrt($0) }
    }
    
    //--------------------------------------------------------------------------
    @inlinable func cpu_squared<S,E>(_ x: Tensor<S,E>, _ out: inout Tensor<S,E>)
    where E.Value: Numeric {
        mapOp("cpu_squared", x, &out) { $0 * $0 }
    }
    
    //--------------------------------------------------------------------------
    @inlinable func cpu_tan<S,E>(_ x: Tensor<S,E>, _ out: inout Tensor<S,E>)
    where E.Value: Real {
        mapOp("cpu_tan", x, &out) { .tan($0) }
    }
    
    @inlinable func cpu_tanh<S,E>(_ x: Tensor<S,E>, _ out: inout Tensor<S,E>)
    where E.Value: Real {
        mapOp("cpu_tanh", x, &out) { .tanh($0) }
    }
    
    //==========================================================================
    // specialized derivative implementations
    //==========================================================================
    /// cpu_vjpMin
    @inlinable func cpu_vjpMin<S,E>(
        _ x: Tensor<S,E>, _ y: Tensor<S,E>, _ scale: Tensor<S,E>,
        _ out: inout Tensor<S,E>)
    where E.Value: Comparable & Numeric {
        mapOp("cpu_vjpMin", x, y, scale, &out) { $0 <= $1 ? $2 : E.Value.zero }
    }
    /// cpu_vjpMin
    @inlinable func cpu_vjpMin<S,E>(
        _ x: Tensor<S,E>, _ y: Tensor<S,E>, _ scale: Tensor<S,E>,
        _ resultTrue: inout Tensor<S,E>, _ resultFalse: inout Tensor<S,E>)
    where E.Value: Comparable & Numeric {
        mapOp("cpu_vjpMin", x, y, scale, &resultTrue, &resultFalse) {
            $0 <= $1 ? ($2, E.Value.zero) : (E.Value.zero, $2)
        }
    }
    
    //--------------------------------------------------------------------------
    /// cpu_vjpMax
    @inlinable func cpu_vjpMax<S,E>(
        _ x: Tensor<S,E>, _ y: Tensor<S,E>, _ scale: Tensor<S,E>,
        _ out: inout Tensor<S,E>)
    where E.Value: Comparable & Numeric {
        mapOp("cpu_vjpMax", x, y, scale, &out) { $0 >= $1 ? $2 : E.Value.zero }
    }
    /// cpu_vjpMax
    @inlinable func cpu_vjpMax<S,E>(
        _ x: Tensor<S,E>, _ y: Tensor<S,E>, _ scale: Tensor<S,E>,
        _ resultTrue: inout Tensor<S,E>, _ resultFalse: inout Tensor<S,E>)
    where E.Value: Comparable & Numeric {
        mapOp("cpu_vjpMax", x, y, scale, &resultTrue, &resultFalse) {
            $0 >= $1 ? ($2, E.Value.zero) : (E.Value.zero, $2)
        }
    }
}
