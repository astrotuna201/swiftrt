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
import CCuda

//==============================================================================
// DeviceQueue functions with default cpu delegation
extension CudaQueue {
    //--------------------------------------------------------------------------
    @inlinable public func add<S,E>(
        _ lhs: Tensor<S,E>, _ rhs: Tensor<S,E>,
        _ result: inout Tensor<S,E>
    ) where S: TensorShape, E.Value: AdditiveArithmetic {
        guard useGpu else { cpu_add(lhs, rhs, &result); return }
    }

    //--------------------------------------------------------------------------
    @inlinable public func copy<S,E>(
        from a: Tensor<S,E>, 
        to b: inout Tensor<S,E>
    ) where S: TensorShape {
        guard useGpu else { cpu_copy(from: a, to: &b); return }

        // simple memcpy
        if a.order == b.order {
            if a.isContiguous && b.isContiguous {
                cudaCheck(cudaMemcpyAsync(
                    // dst
                    b.deviceReadWrite(using: self), 
                    // src
                    a.deviceRead(using: self), 
                    // count
                    MemoryLayout<E>.size * a.count, 
                    /// kind
                    cudaMemcpyDeviceToDevice, 
                    // stream
                    self.stream))
            } else {
                fatalError("strided copy not implemented yet")
            }
        } else {
            // swizzle transform

        }
    }

    //--------------------------------------------------------------------------
    // https://docs.nvidia.com/cuda/cublas/index.html#using-the-cublasLt-api
    // samples: https://github.com/NVIDIA/CUDALibrarySamples/tree/master/cuBLASLt
    @inlinable func matmul<E>(
        _ lhs: TensorR2<E>, _ transposeLhs: Bool,
        _ rhs: TensorR2<E>, _ transposeRhs: Bool,
        _ result: inout TensorR2<E>
    ) where E.Value: Numeric {
        guard useGpu else {
            cpu_matmul(lhs, transposeLhs, rhs, transposeRhs, &result)
            return 
        }
        
    }
    //--------------------------------------------------------------------------
    @inlinable func matmul<E>(
        _ lhs: TensorR3<E>, _ transposeLhs: Bool,
        _ rhs: TensorR3<E>, _ transposeRhs: Bool,
        _ result: inout TensorR3<E>
    ) where E.Value: Numeric {
        guard useGpu else {
            cpu_matmul(lhs, transposeLhs, rhs, transposeRhs, &result)
            return 
        }

    }
}