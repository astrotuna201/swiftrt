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
#ifndef fillOps_h
#define fillOps_h

#include "commonCDefs.h"


// make visible to Swift as C API
#ifdef __cplusplus
extern "C" {
#endif

//==============================================================================
/// srtCopy
/// copies elements from x to out, optionally casting and reordering elements
cudaError_t srtCopy(
    const void* x, const srtTensorDescriptor* xDesc,
    void* out, const srtTensorDescriptor* oDesc,
    cudaStream_t stream);

cudaError_t srtFill(
    void* out, const srtTensorDescriptor* oDesc,
    const void* element,
    cudaStream_t stream);

cudaError_t srtFillWithRange(
    void* out, const srtTensorDescriptor* oDesc,
    const long lower,
    const long upper, 
    cudaStream_t stream);

cudaError_t srtEye(
    void* out, const srtTensorDescriptor* oDesc,
    const long offset,
    cudaStream_t stream);

cudaError_t srtFillRandomUniform(
    void* out, const srtTensorDescriptor* oDesc,
    const void* lower,
    const void* upper,
    const uint64_t seed,
    cudaStream_t stream);

cudaError_t srtFillRandomNormal(
    void* out, const srtTensorDescriptor* oDesc,
    const void* mean,
    const void* std,
    const uint64_t seed,
    cudaStream_t stream);

cudaError_t srtFillRandomNormalTensorArgs(
    void* out, const srtTensorDescriptor* oDesc,
    const void* meanTensor,
    const void* stdTensor,
    const uint64_t seed,
    cudaStream_t stream);

cudaError_t srtFillRandomTruncatedNormal(
    void* out, const srtTensorDescriptor* oDesc,
    const void* mean,
    const void* std,
    const uint64_t seed,
    cudaStream_t stream);

cudaError_t srtFillRandomTruncatedNormalTensorArgs(
    void* out, const srtTensorDescriptor* oDesc,
    const void* meanTensor,
    const void* stdTensor,
    const uint64_t seed,
    cudaStream_t stream);

//==============================================================================
#ifdef __cplusplus
}
#endif

#endif // fillOps_h