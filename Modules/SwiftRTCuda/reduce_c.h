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
#pragma once
#include "srt_cdefs.h"

// make visible to Swift as C API
#ifdef __cplusplus
extern "C" {
#endif

//==============================================================================

cudaError_t srtReduceAll(
    const void* x, const srtTensorDescriptor* xDesc,
    void* out, const srtTensorDescriptor* oDesc,
    const size_t* axes,
    const size_t  axesCount,
    cudaStream_t stream);

cudaError_t srtReduceSum(
    const void* x, const srtTensorDescriptor* xDesc,
    void* out, const srtTensorDescriptor* oDesc,
    const size_t* axes,
    const size_t  axesCount,
    cudaStream_t stream);

//==============================================================================
#ifdef __cplusplus
}
#endif
