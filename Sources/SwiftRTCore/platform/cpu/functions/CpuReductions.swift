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
// Cpu device queue function implementations
extension CpuFunctions where Self: DeviceQueue {
  //--------------------------------------------------------------------------
  @inlinable public func cpu_abssum<S, E>(
    _ x: Tensor<S, E>,
    _ out: inout Tensor<S, E>
  ) where E.Value: SignedNumeric & Comparable {
    diagnostic(
      .queueCpu, "abssum(\(x.name)) on \(name)",
      categories: .queueCpu)
    if out.count == 1 {
      mapReduce(x, &out, E.Value.zero) { $0 + Swift.abs($1) }
    } else {
      reduceAlongAxes(x, &out, E.Value.zero) { $0 + Swift.abs($1) }
    }
  }

  //--------------------------------------------------------------------------
  @inlinable public func cpu_all<S>(
    _ x: Tensor<S, Bool>,
    _ out: inout Tensor<S, Bool>
  ) {
    diagnostic(.queueCpu, "all(\(x.name)) on \(name)", categories: .queueCpu)
    if out.count == 1 {
      mapReduce(x, &out, true) { $0 && $1 }
    } else {
      reduceAlongAxes(x, &out, true) { $0 && $1 }
    }
  }

  //--------------------------------------------------------------------------
  @inlinable public func cpu_any<S>(
    _ x: Tensor<S, Bool>,
    _ out: inout Tensor<S, Bool>
  ) {
    diagnostic(.queueCpu, "any(\(x.name)) on \(name)", categories: .queueCpu)
    if out.count == 1 {
      mapReduce(x, &out, false) { $0 || $1 }
    } else {
      reduceAlongAxes(x, &out, false) { $0 || $1 }
    }
  }

  //--------------------------------------------------------------------------
  @inlinable public func cpu_sum<S, E>(
    _ x: Tensor<S, E>,
    _ out: inout Tensor<S, E>
  ) where E.Value: AdditiveArithmetic {
    diagnostic(.queueCpu, "sum(\(x.name)) on \(name)", categories: .queueCpu)
    if out.count == 1 {
      mapReduce(x, &out, E.Value.zero, +)
    } else {
      reduceAlongAxes(x, &out, E.Value.zero, +)
    }
  }

  //--------------------------------------------------------------------------
  // this doesn't use `mapReduce` because it has to do a final op on
  // the reduction out inside the async closure
  //
  @inlinable public func cpu_mean<S, E>(
    _ x: Tensor<S, E>,
    _ out: inout Tensor<S, E>
  ) where E.Value: AlgebraicField {
    diagnostic(.queueCpu, "mean(\(x.name)) on \(name)", categories: .queueCpu)

    // the reduction count is the product of the reduced dimensions
    var prod = x.count
    if out.count > 1 {
      prod = 1
      for i in 0..<S.rank where out.shape[i] == 1 { prod *= x.shape[i] }
    }
    let scale = 1 / E.Value(exactly: prod)!

    // sum
    if out.count == 1 {
      mapReduce(x, &out, E.Value.zero, +)
    } else {
      reduceAlongAxes(x, &out, E.Value.zero, +)
    }

    // inplace divide by count
    mapOp(&out) { $0 * scale }
  }

  //--------------------------------------------------------------------------
  @inlinable public func cpu_min<S, E>(
    _ x: Tensor<S, E>,
    _ out: inout Tensor<S, E>
  ) where E.Value: Comparable & ComparableLimits {
    diagnostic(
      .queueCpu, "min(\(x.name)) on \(name)",
      categories: .queueCpu)
    if out.count == 1 {
      mapReduce(x, &out, E.Value.highest) { Swift.min($0, $1) }
    } else {
      reduceAlongAxes(x, &out, E.Value.highest) { Swift.min($0, $1) }
    }
  }

  //--------------------------------------------------------------------------
  @inlinable public func cpu_argmin<S, E>(
    _ x: Tensor<S, E>,
    _ out: inout Tensor<S, E>
  ) where E.Value: Comparable & ComparableLimits {
    diagnostic(
      .queueCpu, "argmin(\(x.name)) on \(name)",
      categories: .queueCpu)
    if out.count == 1 {
      mapReduce(x, &out, E.Value.highest) { Swift.min($0, $1) }
    } else {
      reduceAlongAxes(x, &out, E.Value.highest) { Swift.min($0, $1) }
    }
  }

  //--------------------------------------------------------------------------
  @inlinable public func cpu_max<S, E>(
    _ x: Tensor<S, E>,
    _ out: inout Tensor<S, E>
  ) where E.Value: Comparable & ComparableLimits {
    diagnostic(
      .queueCpu, "max(\(x.name)) on \(name)",
      categories: .queueCpu)
    if out.count == 1 {
      mapReduce(x, &out, E.Value.lowest) { $0 > $1 ? $0 : $1 }
    } else {
      reduceAlongAxes(x, &out, E.Value.lowest) { $0 > $1 ? $0 : $1 }
    }
  }

  //--------------------------------------------------------------------------
  @inlinable public func cpu_argmax<S, E>(
    _ x: Tensor<S, E>,
    _ out: inout Tensor<S, E>
  ) where E.Value: Comparable & ComparableLimits {
    diagnostic(
      .queueCpu, "argmax(\(x.name)) on \(name)",
      categories: .queueCpu)
    if out.count == 1 {
      mapReduce(x, &out, E.Value.lowest) { $0 > $1 ? $0 : $1 }
    } else {
      reduceAlongAxes(x, &out, E.Value.lowest) { $0 > $1 ? $0 : $1 }
    }
  }

  //--------------------------------------------------------------------------
  @inlinable public func cpu_prod<S, E>(
    _ x: Tensor<S, E>,
    _ out: inout Tensor<S, E>
  ) where E.Value: Numeric {
    diagnostic(.queueCpu, "prod(\(x.name)) on \(name)", categories: .queueCpu)
    if out.count == 1 {
      mapReduce(x, &out, E.Value.one, *)
    } else {
      reduceAlongAxes(x, &out, E.Value.one, *)
    }
  }

  //--------------------------------------------------------------------------
  @inlinable public func cpu_prodNonZeros<S, E>(
    _ x: Tensor<S, E>,
    _ out: inout Tensor<S, E>
  ) where E.Value: Numeric {
    diagnostic(
      .queueCpu, "prodNonZeros(\(x.name)) on \(name)",
      categories: .queueCpu)
    if out.count == 1 {
      mapReduce(x, &out, E.Value.one) { $1 == 0 ? $0 : $0 * $1 }
    } else {
      reduceAlongAxes(x, &out, E.Value.one) { $1 == 0 ? $0 : $0 * $1 }
    }
  }
}

//==============================================================================
// CpuQueue functions with default cpu delegation
extension CpuQueue {
  //--------------------------------------------------------------------------
  //--------------------------------------------------------------------------
  @inlinable public func abssum<S, E>(
    _ x: Tensor<S, E>,
    _ out: inout Tensor<S, E>
  ) where E.Value: SignedNumeric & Comparable {
    cpu_abssum(x, &out)
  }
  //--------------------------------------------------------------------------
  @inlinable public func all<S>(
    _ x: Tensor<S, Bool>,
    _ out: inout Tensor<S, Bool>
  ) { cpu_all(x, &out) }
  //--------------------------------------------------------------------------
  @inlinable public func any<S>(
    _ x: Tensor<S, Bool>,
    _ out: inout Tensor<S, Bool>
  ) { cpu_any(x, &out) }
  //--------------------------------------------------------------------------
  @inlinable public func sum<S, E>(
    _ x: Tensor<S, E>,
    _ out: inout Tensor<S, E>
  ) where E.Value: AdditiveArithmetic { cpu_sum(x, &out) }
  //--------------------------------------------------------------------------
  @inlinable public func mean<S, E>(
    _ x: Tensor<S, E>,
    _ out: inout Tensor<S, E>
  ) where E.Value: AlgebraicField { cpu_mean(x, &out) }
  //--------------------------------------------------------------------------
  @inlinable public func min<S, E>(
    _ x: Tensor<S, E>,
    _ out: inout Tensor<S, E>
  ) where E.Value: Comparable & ComparableLimits { cpu_min(x, &out) }
  //--------------------------------------------------------------------------
  @inlinable public func argmin<S, E>(
    _ x: Tensor<S, E>,
    _ out: inout Tensor<S, E>
  ) where E.Value: Comparable & ComparableLimits { cpu_argmin(x, &out) }
  //--------------------------------------------------------------------------
  @inlinable public func max<S, E>(
    _ x: Tensor<S, E>,
    _ out: inout Tensor<S, E>
  ) where E.Value: Comparable & ComparableLimits { cpu_max(x, &out) }
  //--------------------------------------------------------------------------
  @inlinable public func argmax<S, E>(
    _ x: Tensor<S, E>,
    _ out: inout Tensor<S, E>
  ) where E.Value: Comparable & ComparableLimits { cpu_argmax(x, &out) }
  //--------------------------------------------------------------------------
  @inlinable public func prod<S, E>(
    _ x: Tensor<S, E>,
    _ out: inout Tensor<S, E>
  ) where E.Value: Numeric {
    cpu_prod(x, &out)
  }
  //--------------------------------------------------------------------------
  @inlinable public func prodNonZeros<S, E>(
    _ x: Tensor<S, E>,
    _ out: inout Tensor<S, E>
  ) where E.Value: Numeric {
    cpu_prodNonZeros(x, &out)
  }
}
