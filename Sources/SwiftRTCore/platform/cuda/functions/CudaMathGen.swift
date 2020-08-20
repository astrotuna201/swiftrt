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
import SwiftRTCuda
import Numerics

// gyb utility docs
// https://nshipster.com/swift-gyb/

//******************************************************************************
//
// DO NOT EDIT. THIS FILE IS GENERATED FROM .swift.gyb file
//
//******************************************************************************

//==============================================================================
// DeviceQueue functions with default cpu delegation
extension CudaQueue {
    //--------------------------------------------------------------------------
    @inlinable func abs<S,E>(
        _ x: Tensor<S,E>, 
        _ out: inout Tensor<S,E>
    ) where E.Value: Comparable & SignedNumeric {
        assert(out.isContiguous, _messageElementsMustBeContiguous)
        guard useGpu else { cpu_abs(x, &out); return }

        let status = out.withMutableTensor(using: self) { oData, o in
            x.withTensor(using: self) { xData, x in
                srtAbs(xData, x, oData, o, stream)
            }
        }
        cpuFallback(status) { $0.abs(x, &out) }
    }

    //--------------------------------------------------------------------------
    @inlinable func acos<S,E>(
        _ x: Tensor<S,E>, 
        _ out: inout Tensor<S,E>
    ) where E.Value: Real {
        assert(out.isContiguous, _messageElementsMustBeContiguous)
        guard useGpu else { cpu_acos(x, &out); return }

        let status = out.withMutableTensor(using: self) { oData, o in
            x.withTensor(using: self) { xData, x in
                srtAcos(xData, x, oData, o, stream)
            }
        }
        cpuFallback(status) { $0.acos(x, &out) }
    }

    //--------------------------------------------------------------------------
    @inlinable func acosh<S,E>(
        _ x: Tensor<S,E>, 
        _ out: inout Tensor<S,E>
    ) where E.Value: Real {
        assert(out.isContiguous, _messageElementsMustBeContiguous)
        guard useGpu else { cpu_acosh(x, &out); return }

        let status = out.withMutableTensor(using: self) { oData, o in
            x.withTensor(using: self) { xData, x in
                srtAcosh(xData, x, oData, o, stream)
            }
        }
        cpuFallback(status) { $0.acosh(x, &out) }
    }

    //--------------------------------------------------------------------------
    @inlinable func asin<S,E>(
        _ x: Tensor<S,E>, 
        _ out: inout Tensor<S,E>
    ) where E.Value: Real {
        assert(out.isContiguous, _messageElementsMustBeContiguous)
        guard useGpu else { cpu_asin(x, &out); return }

        let status = out.withMutableTensor(using: self) { oData, o in
            x.withTensor(using: self) { xData, x in
                srtAsin(xData, x, oData, o, stream)
            }
        }
        cpuFallback(status) { $0.asin(x, &out) }
    }

    //--------------------------------------------------------------------------
    @inlinable func asinh<S,E>(
        _ x: Tensor<S,E>, 
        _ out: inout Tensor<S,E>
    ) where E.Value: Real {
        assert(out.isContiguous, _messageElementsMustBeContiguous)
        guard useGpu else { cpu_asinh(x, &out); return }

        let status = out.withMutableTensor(using: self) { oData, o in
            x.withTensor(using: self) { xData, x in
                srtAsinh(xData, x, oData, o, stream)
            }
        }
        cpuFallback(status) { $0.asinh(x, &out) }
    }

    //--------------------------------------------------------------------------
    @inlinable func atan<S,E>(
        _ x: Tensor<S,E>, 
        _ out: inout Tensor<S,E>
    ) where E.Value: Real {
        assert(out.isContiguous, _messageElementsMustBeContiguous)
        guard useGpu else { cpu_atan(x, &out); return }

        let status = out.withMutableTensor(using: self) { oData, o in
            x.withTensor(using: self) { xData, x in
                srtAtan(xData, x, oData, o, stream)
            }
        }
        cpuFallback(status) { $0.atan(x, &out) }
    }

    //--------------------------------------------------------------------------
    @inlinable func atanh<S,E>(
        _ x: Tensor<S,E>, 
        _ out: inout Tensor<S,E>
    ) where E.Value: Real {
        assert(out.isContiguous, _messageElementsMustBeContiguous)
        guard useGpu else { cpu_atanh(x, &out); return }

        let status = out.withMutableTensor(using: self) { oData, o in
            x.withTensor(using: self) { xData, x in
                srtAtanh(xData, x, oData, o, stream)
            }
        }
        cpuFallback(status) { $0.atanh(x, &out) }
    }

    //--------------------------------------------------------------------------
    @inlinable func cos<S,E>(
        _ x: Tensor<S,E>, 
        _ out: inout Tensor<S,E>
    ) where E.Value: Real {
        assert(out.isContiguous, _messageElementsMustBeContiguous)
        guard useGpu else { cpu_cos(x, &out); return }

        let status = out.withMutableTensor(using: self) { oData, o in
            x.withTensor(using: self) { xData, x in
                srtCos(xData, x, oData, o, stream)
            }
        }
        cpuFallback(status) { $0.cos(x, &out) }
    }

    //--------------------------------------------------------------------------
    @inlinable func cosh<S,E>(
        _ x: Tensor<S,E>, 
        _ out: inout Tensor<S,E>
    ) where E.Value: Real {
        assert(out.isContiguous, _messageElementsMustBeContiguous)
        guard useGpu else { cpu_cosh(x, &out); return }

        let status = out.withMutableTensor(using: self) { oData, o in
            x.withTensor(using: self) { xData, x in
                srtCosh(xData, x, oData, o, stream)
            }
        }
        cpuFallback(status) { $0.cosh(x, &out) }
    }

    //--------------------------------------------------------------------------
    @inlinable func erf<S,E>(
        _ x: Tensor<S,E>, 
        _ out: inout Tensor<S,E>
    ) where E.Value: Real {
        assert(out.isContiguous, _messageElementsMustBeContiguous)
        guard useGpu else { cpu_erf(x, &out); return }

        let status = out.withMutableTensor(using: self) { oData, o in
            x.withTensor(using: self) { xData, x in
                srtErf(xData, x, oData, o, stream)
            }
        }
        cpuFallback(status) { $0.erf(x, &out) }
    }

    //--------------------------------------------------------------------------
    @inlinable func erfc<S,E>(
        _ x: Tensor<S,E>, 
        _ out: inout Tensor<S,E>
    ) where E.Value: Real {
        assert(out.isContiguous, _messageElementsMustBeContiguous)
        guard useGpu else { cpu_erfc(x, &out); return }

        let status = out.withMutableTensor(using: self) { oData, o in
            x.withTensor(using: self) { xData, x in
                srtErfc(xData, x, oData, o, stream)
            }
        }
        cpuFallback(status) { $0.erfc(x, &out) }
    }

    //--------------------------------------------------------------------------
    @inlinable func exp<S,E>(
        _ x: Tensor<S,E>, 
        _ out: inout Tensor<S,E>
    ) where E.Value: Real {
        assert(out.isContiguous, _messageElementsMustBeContiguous)
        guard useGpu else { cpu_exp(x, &out); return }

        let status = out.withMutableTensor(using: self) { oData, o in
            x.withTensor(using: self) { xData, x in
                srtExp(xData, x, oData, o, stream)
            }
        }
        cpuFallback(status) { $0.exp(x, &out) }
    }

    //--------------------------------------------------------------------------
    @inlinable func exp2<S,E>(
        _ x: Tensor<S,E>, 
        _ out: inout Tensor<S,E>
    ) where E.Value: Real {
        assert(out.isContiguous, _messageElementsMustBeContiguous)
        guard useGpu else { cpu_exp2(x, &out); return }

        let status = out.withMutableTensor(using: self) { oData, o in
            x.withTensor(using: self) { xData, x in
                srtExp2(xData, x, oData, o, stream)
            }
        }
        cpuFallback(status) { $0.exp2(x, &out) }
    }

    //--------------------------------------------------------------------------
    @inlinable func exp10<S,E>(
        _ x: Tensor<S,E>, 
        _ out: inout Tensor<S,E>
    ) where E.Value: Real {
        assert(out.isContiguous, _messageElementsMustBeContiguous)
        guard useGpu else { cpu_exp10(x, &out); return }

        let status = out.withMutableTensor(using: self) { oData, o in
            x.withTensor(using: self) { xData, x in
                srtExp10(xData, x, oData, o, stream)
            }
        }
        cpuFallback(status) { $0.exp10(x, &out) }
    }

    //--------------------------------------------------------------------------
    @inlinable func expMinusOne<S,E>(
        _ x: Tensor<S,E>, 
        _ out: inout Tensor<S,E>
    ) where E.Value: Real {
        assert(out.isContiguous, _messageElementsMustBeContiguous)
        guard useGpu else { cpu_expMinusOne(x, &out); return }

        let status = out.withMutableTensor(using: self) { oData, o in
            x.withTensor(using: self) { xData, x in
                srtExpMinusOne(xData, x, oData, o, stream)
            }
        }
        cpuFallback(status) { $0.expMinusOne(x, &out) }
    }

    //--------------------------------------------------------------------------
    @inlinable func gamma<S,E>(
        _ x: Tensor<S,E>, 
        _ out: inout Tensor<S,E>
    ) where E.Value: Real {
        assert(out.isContiguous, _messageElementsMustBeContiguous)
        guard useGpu else { cpu_gamma(x, &out); return }

        let status = out.withMutableTensor(using: self) { oData, o in
            x.withTensor(using: self) { xData, x in
                srtGamma(xData, x, oData, o, stream)
            }
        }
        cpuFallback(status) { $0.gamma(x, &out) }
    }

    //--------------------------------------------------------------------------
    @inlinable func log<S,E>(
        _ x: Tensor<S,E>, 
        _ out: inout Tensor<S,E>
    ) where E.Value: Real {
        assert(out.isContiguous, _messageElementsMustBeContiguous)
        guard useGpu else { cpu_log(x, &out); return }

        let status = out.withMutableTensor(using: self) { oData, o in
            x.withTensor(using: self) { xData, x in
                srtLog(xData, x, oData, o, stream)
            }
        }
        cpuFallback(status) { $0.log(x, &out) }
    }

    //--------------------------------------------------------------------------
    @inlinable func log2<S,E>(
        _ x: Tensor<S,E>, 
        _ out: inout Tensor<S,E>
    ) where E.Value: Real {
        assert(out.isContiguous, _messageElementsMustBeContiguous)
        guard useGpu else { cpu_log2(x, &out); return }

        let status = out.withMutableTensor(using: self) { oData, o in
            x.withTensor(using: self) { xData, x in
                srtLog2(xData, x, oData, o, stream)
            }
        }
        cpuFallback(status) { $0.log2(x, &out) }
    }

    //--------------------------------------------------------------------------
    @inlinable func log10<S,E>(
        _ x: Tensor<S,E>, 
        _ out: inout Tensor<S,E>
    ) where E.Value: Real {
        assert(out.isContiguous, _messageElementsMustBeContiguous)
        guard useGpu else { cpu_log10(x, &out); return }

        let status = out.withMutableTensor(using: self) { oData, o in
            x.withTensor(using: self) { xData, x in
                srtLog10(xData, x, oData, o, stream)
            }
        }
        cpuFallback(status) { $0.log10(x, &out) }
    }

    //--------------------------------------------------------------------------
    @inlinable func logGamma<S,E>(
        _ x: Tensor<S,E>, 
        _ out: inout Tensor<S,E>
    ) where E.Value: Real {
        assert(out.isContiguous, _messageElementsMustBeContiguous)
        guard useGpu else { cpu_logGamma(x, &out); return }

        let status = out.withMutableTensor(using: self) { oData, o in
            x.withTensor(using: self) { xData, x in
                srtLogGamma(xData, x, oData, o, stream)
            }
        }
        cpuFallback(status) { $0.logGamma(x, &out) }
    }

    //--------------------------------------------------------------------------
    @inlinable func neg<S,E>(
        _ x: Tensor<S,E>, 
        _ out: inout Tensor<S,E>
    ) where E.Value: SignedNumeric {
        assert(out.isContiguous, _messageElementsMustBeContiguous)
        guard useGpu else { cpu_neg(x, &out); return }

        let status = out.withMutableTensor(using: self) { oData, o in
            x.withTensor(using: self) { xData, x in
                srtNeg(xData, x, oData, o, stream)
            }
        }
        cpuFallback(status) { $0.neg(x, &out) }
    }

    //--------------------------------------------------------------------------
    @inlinable func sign<S,E>(
        _ x: Tensor<S,E>, 
        _ out: inout Tensor<S,E>
    ) where E.Value: Comparable & SignedNumeric {
        assert(out.isContiguous, _messageElementsMustBeContiguous)
        guard useGpu else { cpu_sign(x, &out); return }

        let status = out.withMutableTensor(using: self) { oData, o in
            x.withTensor(using: self) { xData, x in
                srtSign(xData, x, oData, o, stream)
            }
        }
        cpuFallback(status) { $0.sign(x, &out) }
    }

    //--------------------------------------------------------------------------
    @inlinable func sin<S,E>(
        _ x: Tensor<S,E>, 
        _ out: inout Tensor<S,E>
    ) where E.Value: Real {
        assert(out.isContiguous, _messageElementsMustBeContiguous)
        guard useGpu else { cpu_sin(x, &out); return }

        let status = out.withMutableTensor(using: self) { oData, o in
            x.withTensor(using: self) { xData, x in
                srtSin(xData, x, oData, o, stream)
            }
        }
        cpuFallback(status) { $0.sin(x, &out) }
    }

    //--------------------------------------------------------------------------
    @inlinable func sinh<S,E>(
        _ x: Tensor<S,E>, 
        _ out: inout Tensor<S,E>
    ) where E.Value: Real {
        assert(out.isContiguous, _messageElementsMustBeContiguous)
        guard useGpu else { cpu_sinh(x, &out); return }

        let status = out.withMutableTensor(using: self) { oData, o in
            x.withTensor(using: self) { xData, x in
                srtSinh(xData, x, oData, o, stream)
            }
        }
        cpuFallback(status) { $0.sinh(x, &out) }
    }

    //--------------------------------------------------------------------------
    @inlinable func sqrt<S,E>(
        _ x: Tensor<S,E>, 
        _ out: inout Tensor<S,E>
    ) where E.Value: Real {
        assert(out.isContiguous, _messageElementsMustBeContiguous)
        guard useGpu else { cpu_sqrt(x, &out); return }

        let status = out.withMutableTensor(using: self) { oData, o in
            x.withTensor(using: self) { xData, x in
                srtSqrt(xData, x, oData, o, stream)
            }
        }
        cpuFallback(status) { $0.sqrt(x, &out) }
    }

    //--------------------------------------------------------------------------
    @inlinable func squared<S,E>(
        _ x: Tensor<S,E>, 
        _ out: inout Tensor<S,E>
    ) where E.Value: Numeric {
        assert(out.isContiguous, _messageElementsMustBeContiguous)
        guard useGpu else { cpu_squared(x, &out); return }

        let status = out.withMutableTensor(using: self) { oData, o in
            x.withTensor(using: self) { xData, x in
                srtSquared(xData, x, oData, o, stream)
            }
        }
        cpuFallback(status) { $0.squared(x, &out) }
    }

    //--------------------------------------------------------------------------
    @inlinable func tan<S,E>(
        _ x: Tensor<S,E>, 
        _ out: inout Tensor<S,E>
    ) where E.Value: Real {
        assert(out.isContiguous, _messageElementsMustBeContiguous)
        guard useGpu else { cpu_tan(x, &out); return }

        let status = out.withMutableTensor(using: self) { oData, o in
            x.withTensor(using: self) { xData, x in
                srtTan(xData, x, oData, o, stream)
            }
        }
        cpuFallback(status) { $0.tan(x, &out) }
    }

    //--------------------------------------------------------------------------
    @inlinable func tanh<S,E>(
        _ x: Tensor<S,E>, 
        _ out: inout Tensor<S,E>
    ) where E.Value: Real {
        assert(out.isContiguous, _messageElementsMustBeContiguous)
        guard useGpu else { cpu_tanh(x, &out); return }

        let status = out.withMutableTensor(using: self) { oData, o in
            x.withTensor(using: self) { xData, x in
                srtTanh(xData, x, oData, o, stream)
            }
        }
        cpuFallback(status) { $0.tanh(x, &out) }
    }

}

