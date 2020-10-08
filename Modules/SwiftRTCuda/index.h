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
#if !defined(__index_h__)
#define __index_h__

#include <assert.h>
#include <vector_types.h>
#include "commonCDefs.h"

//==============================================================================
// TensorDescriptor
// C++ enhanced wrapper
struct TensorDescriptor: srtTensorDescriptor {
    inline bool isDense() const { return count == spanCount; }
    inline bool isStrided() const { return !isDense(); }
    inline bool isSingle() const { return spanCount == 1; }
};

static_assert(sizeof(TensorDescriptor) == sizeof(srtTensorDescriptor),
    "TensorDescriptor is a c++ wrapper and cannot contain additional members");


// statically cast types from C interface to c++ type
#define Cast2TensorDescriptorsA(pa, po) \
const TensorDescriptor& aDesc = static_cast<const TensorDescriptor&>(*pa); \
const TensorDescriptor& oDesc = static_cast<const TensorDescriptor&>(*po); \

#define Cast2TensorDescriptorsAB(pa, pb, po) \
const TensorDescriptor& aDesc = static_cast<const TensorDescriptor&>(*pa); \
const TensorDescriptor& bDesc = static_cast<const TensorDescriptor&>(*pb); \
const TensorDescriptor& oDesc = static_cast<const TensorDescriptor&>(*po); \

#define Cast2TensorDescriptorsABC(pa, pb, pc, po) \
const TensorDescriptor& aDesc = static_cast<const TensorDescriptor&>(*pa); \
const TensorDescriptor& bDesc = static_cast<const TensorDescriptor&>(*pb); \
const TensorDescriptor& cDesc = static_cast<const TensorDescriptor&>(*pc); \
const TensorDescriptor& oDesc = static_cast<const TensorDescriptor&>(*po); \

//==============================================================================
/// Logical
/// converts grid, block, thread indexes into a logical position
template<size_t Rank>
struct Logical {
    // initializer
    __device__ __forceinline__ Logical(
        const uint3& blockIdx,
        const dim3& blockDim,
        const uint3& threadIdx
    ) {
        static_assert(Rank <= 3, "only Rank 1 - 3 are implemented");
        if (Rank == 1) {
            position[0] = blockIdx.x * blockDim.x + threadIdx.x;
        } else if (Rank == 2) {
            position[0] = blockIdx.y * blockDim.y + threadIdx.y;
            position[1] = blockIdx.x * blockDim.x + threadIdx.x;
        } else {
            position[0] = blockIdx.z * blockDim.z + threadIdx.z;
            position[1] = blockIdx.y * blockDim.y + threadIdx.y;
            position[2] = blockIdx.x * blockDim.x + threadIdx.x;
        }
    }

    // subscript
    __device__ __forceinline__ uint32_t operator[](int i) const {
        return position[i];
    }

    private:
        // properties
        uint32_t position[Rank];
};

//==============================================================================
/// Single
/// index used for single element value parameters 
struct Single {
    static const int Rank = 1;
    typedef Logical<1> Logical;

    // initializer
    __host__ Single(const TensorDescriptor& tensor) { }

    /// isInBounds
    /// `true` if the given logical position is within the bounds of
    /// the indexed space
    /// - Parameters:
    ///  - position: the logical position to test
    /// - Returns: `true` if the position is within the shape
    __device__ __forceinline__ bool isInBounds(const Logical& position) const {
        return position[0] == 0;
    }

    /// linear
    /// - Returns: all positions map to the single value, so always returns 0 
    __device__ __forceinline__ 
    uint32_t linear(const Logical& position) const { return 0; }

    __device__ __forceinline__ 
    uint32_t sequence(const Logical& position) const {
        return position[0];
    }
};

//==============================================================================
/// Flat
/// a flat dense 1D index
struct Flat {
    // types
    static const int Rank = 1;
    typedef Logical<Rank> Logical;

    // properties
    uint32_t count;

    //----------------------------------
    // initializer
    __host__ Flat(const TensorDescriptor& tensor) {
        assert(tensor.count == tensor.spanCount);
        count = tensor.count;
    }

    /// isInBounds
    /// `true` if the given logical position is within the bounds of
    /// the indexed space
    /// - Parameters:
    ///  - position: the logical position to test
    /// - Returns: `true` if the position is within the shape
    __device__ __forceinline__ bool isInBounds(const Logical& position) const {
        return position[0] < count;
    }

    //----------------------------------
    __device__ __forceinline__ 
    uint32_t linear(const Logical& position) const {
        return position[0];
    }

    //--------------------------------------------------------------------------
    // the logical sequence position
    __device__ __forceinline__ 
    uint32_t sequence(const Logical& position) const {
        return position[0];
    }
};

//==============================================================================
/// Strided
template<int _Rank>
struct Strided {
    // types
    static const int Rank = _Rank;
    typedef Logical<Rank> Logical;

    // properties
    uint32_t count;
    uint32_t shape[Rank];
    uint32_t strides[Rank];

    //--------------------------------------------------------------------------
    // initializer
    __host__ Strided(const TensorDescriptor& tensor) {
        count = tensor.count;
        for (int i = 0; i < Rank; ++i) {
            assert(tensor.shape[i] <= UINT32_MAX && tensor.strides[i] <= UINT32_MAX);
            shape[i] = uint32_t(tensor.shape[i]);
            strides[i] = uint32_t(tensor.strides[i]);
        }
    }

    //--------------------------------------------------------------------------
    /// isInBounds
    /// `true` if the given logical position is within the bounds of
    /// the indexed space
    /// - Parameters:
    ///  - position: the logical position to test
    /// - Returns: `true` if the position is within the shape
    __device__ __forceinline__ bool isInBounds(const Logical& position) const {
        bool inBounds = position[0] < shape[0];
        #pragma unroll
        for (int i = 1; i < Rank; i++) {
            inBounds = inBounds && position[i] < shape[i];
        }
        return inBounds;
    }

    //--------------------------------------------------------------------------
    // the linear buffer position
    __device__ __forceinline__ 
    uint32_t linear(const Logical& position) const {
        uint32_t index = 0;
        #pragma unroll
        for (int i = 0; i < Rank; i++) {
            index += position[i] * strides[i];
        }
        return index;
    }
};

//==============================================================================
/// StridedSeq
/// used to calculate strided indexes and sequence positions
/// to support generators
template<int R>
struct StridedSeq: Strided<R> {
    // properties
    uint32_t logicalStrides[R];

    //--------------------------------------------------------------------------
    // initializer
    __host__ StridedSeq(const TensorDescriptor& tensor) : Strided<R>(tensor) {
        for (int i = 0; i < R; ++i) {
            assert(tensor.shape[i] <= UINT32_MAX && tensor.strides[i] <= UINT32_MAX);
            logicalStrides[i] = uint32_t(tensor.logicalStrides[i]);
        }
    }

    //--------------------------------------------------------------------------
    // the logical sequence position
    __device__ __forceinline__  
    uint32_t sequence(const typename Strided<R>::Logical& position) const {
        uint32_t index = 0;
        #pragma unroll
        for (int i = 0; i < R; i++) {
            index += position[i] * logicalStrides[i];
        }
        return index;
    }
};

#endif // __index_h__