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
#ifndef mathSupplemental_h
#define mathSupplemental_h

#include <cuda.h>
#include <cuda_fp16.h>
#include <cuda_bf16.h>
#include <stdexcept>
#include <vector_functions.h>
#include "dispatchHelpers.h"


//==============================================================================
// supplemental function delegating macros
//==============================================================================

#define NATIVE_FLOAT16(func, native) \
__device__ inline __half func(const __half& a) { return native(a); }

#define NATIVE_FLOAT162(func, native) \
__device__ inline __half2 func(const __half2& a) { return native(a); }

#if (__CUDA_ARCH__ < 800)
#define NATIVE_BFLOAT16(func, native) \
    __device__ inline __nv_bfloat16 func(const __nv_bfloat16& a) \
    { return func(float(a)); }
#else
#define NATIVE_BFLOAT16(func, native) \
    __device__ inline __nv_bfloat16 func(const __nv_bfloat16& a) { return native(a); }
#endif

#if (__CUDA_ARCH__ < 800)
#define NATIVE_BFLOAT162(func, native) \
    __device__ inline __nv_bfloat162 func(const __nv_bfloat162& a) \
    { return __nv_bfloat162(func(float(a.x)), func(float(a.y))); }
#else
#define NATIVE_BFLOAT162(func, native) \
    __device__ inline __nv_bfloat162 func(const __nv_bfloat162& a) { return native(a); }
#endif

//------------------------------------------------------------------------------
// Promotes the type to a float, does the op, then back to the type. This
// is used for ops that do not natively support half or bfloat types
#define PROMOTED_FLOAT16(func) \
__device__ inline __half func(const __half& a) { return func(float(a)); }

#define PROMOTED_FLOAT162(func) \
__device__ inline __half2 func(const __half2& a) { return __half2(func(a.x), func(a.y)); }

#define PROMOTED_BFLOAT16(func) \
__device__ inline __nv_bfloat16 func(const __nv_bfloat16& a) { return func(float(a)); }

#define PROMOTED_BFLOAT162(func) \
__device__ inline __nv_bfloat162 func(const __nv_bfloat162& a) \
    { return __nv_bfloat162(func(float(a.x)), func(float(a.y))); }

//------------------------------------------------------------------------------
// Promotes the type to a float, does the op, then back to the type. This
// is used for ops that do not natively support half or bfloat types
#define PROMOTED2_FLOAT16(func) \
__device__ inline __half func(const __half& a, const __half& b) \
    { return func(float(a), float(b)); }

#define PROMOTED2_FLOAT162(func) \
__device__ inline __half2 func(const __half2& a, const __half2& b) \
    { return __half2(func(a.x, b.x), func(a.y, b.y)); }

#define PROMOTED2_BFLOAT16(func) \
__device__ inline __nv_bfloat16 func(const __nv_bfloat16& a, const __nv_bfloat16& b) \
    { return func(float(a), float(b)); }

#define PROMOTED2_BFLOAT162(func) \
__device__ inline __nv_bfloat162 func(const __nv_bfloat162& a, const __nv_bfloat162& b) \
    { return __nv_bfloat162(func(float(a.x), float(b.x)), func(float(a.y), float(b.y))); }

//==============================================================================
// supplemental functions
//==============================================================================

// abs
NATIVE_FLOAT16(abs, __habs)
NATIVE_FLOAT162(abs, __habs2)
NATIVE_BFLOAT16(abs, __habs)
NATIVE_BFLOAT162(abs, __habs2)

// acos
PROMOTED_FLOAT16(acos)
PROMOTED_FLOAT162(acos)
PROMOTED_BFLOAT16(acos)
PROMOTED_BFLOAT162(acos)

// acosh
PROMOTED_FLOAT16(acosh)
PROMOTED_FLOAT162(acosh)
PROMOTED_BFLOAT16(acosh)
PROMOTED_BFLOAT162(acosh)

// asin
PROMOTED_FLOAT16(asin)
PROMOTED_FLOAT162(asin)
PROMOTED_BFLOAT16(asin)
PROMOTED_BFLOAT162(asin)

// asinh
PROMOTED_FLOAT16(asinh)
PROMOTED_FLOAT162(asinh)
PROMOTED_BFLOAT16(asinh)
PROMOTED_BFLOAT162(asinh)

// atan
PROMOTED_FLOAT16(atan)
PROMOTED_FLOAT162(atan)
PROMOTED_BFLOAT16(atan)
PROMOTED_BFLOAT162(atan)

// atan2
PROMOTED2_FLOAT16(atan2)
PROMOTED2_FLOAT162(atan2)
PROMOTED2_BFLOAT16(atan2)
PROMOTED2_BFLOAT162(atan2)

// atanh
PROMOTED_FLOAT16(atanh)
PROMOTED_FLOAT162(atanh)
PROMOTED_BFLOAT16(atanh)
PROMOTED_BFLOAT162(atanh)

// cos
NATIVE_FLOAT16(cos, hcos)
NATIVE_FLOAT162(cos, h2cos)
NATIVE_BFLOAT16(cos, hcos)
NATIVE_BFLOAT162(cos, h2cos)

// cosh
PROMOTED_FLOAT16(cosh)
PROMOTED_FLOAT162(cosh)
PROMOTED_BFLOAT16(cosh)
PROMOTED_BFLOAT162(cosh)

// erf
PROMOTED_FLOAT16(erf)
PROMOTED_FLOAT162(erf)
PROMOTED_BFLOAT16(erf)
PROMOTED_BFLOAT162(erf)

// erfc
PROMOTED_FLOAT16(erfc)
PROMOTED_FLOAT162(erfc)
PROMOTED_BFLOAT16(erfc)
PROMOTED_BFLOAT162(erfc)

// exp
NATIVE_FLOAT16(exp, hexp)
NATIVE_FLOAT162(exp, h2exp)
NATIVE_BFLOAT16(exp, hexp)
NATIVE_BFLOAT162(exp, h2exp)

// exp2
NATIVE_FLOAT16(exp2, hexp2)
NATIVE_FLOAT162(exp2, h2exp2)
NATIVE_BFLOAT16(exp2, hexp2)
NATIVE_BFLOAT162(exp2, h2exp2)

// exp10
NATIVE_FLOAT16(exp10, hexp10)
NATIVE_FLOAT162(exp10, h2exp10)
NATIVE_BFLOAT16(exp10, hexp10)
NATIVE_BFLOAT162(exp10, h2exp10)

// expm1
PROMOTED_FLOAT16(expm1)
PROMOTED_FLOAT162(expm1)
PROMOTED_BFLOAT16(expm1)
PROMOTED_BFLOAT162(expm1)

// tgamma
PROMOTED_FLOAT16(tgamma)
PROMOTED_FLOAT162(tgamma)
PROMOTED_BFLOAT16(tgamma)
PROMOTED_BFLOAT162(tgamma)

// hypot
PROMOTED2_FLOAT16(hypot)
PROMOTED2_FLOAT162(hypot)
PROMOTED2_BFLOAT16(hypot)
PROMOTED2_BFLOAT162(hypot)

// log
NATIVE_FLOAT16(log, hlog)
NATIVE_FLOAT162(log, h2log)
NATIVE_BFLOAT16(log, hlog)
NATIVE_BFLOAT162(log, h2log)

// log1p
PROMOTED_FLOAT16(log1p)
PROMOTED_FLOAT162(log1p)
PROMOTED_BFLOAT16(log1p)
PROMOTED_BFLOAT162(log1p)

// log2
NATIVE_FLOAT16(log2, hlog2)
NATIVE_FLOAT162(log2, h2log2)
NATIVE_BFLOAT16(log2, hlog2)
NATIVE_BFLOAT162(log2, h2log2)

// log10
NATIVE_FLOAT16(log10, hlog10)
NATIVE_FLOAT162(log10, h2log10)
NATIVE_BFLOAT16(log10, hlog10)
NATIVE_BFLOAT162(log10, h2log10)

// lgamma
PROMOTED_FLOAT16(lgamma)
PROMOTED_FLOAT162(lgamma)
PROMOTED_BFLOAT16(lgamma)
PROMOTED_BFLOAT162(lgamma)

// pow
PROMOTED2_FLOAT16(pow)
PROMOTED2_FLOAT162(pow)
PROMOTED2_BFLOAT16(pow)
PROMOTED2_BFLOAT162(pow)

// sin
NATIVE_FLOAT16(sin, hsin)
NATIVE_FLOAT162(sin, h2sin)
NATIVE_BFLOAT16(sin, hsin)
NATIVE_BFLOAT162(sin, h2sin)

// sinh
PROMOTED_FLOAT16(sinh)
PROMOTED_FLOAT162(sinh)
PROMOTED_BFLOAT16(sinh)
PROMOTED_BFLOAT162(sinh)

// sqrt
NATIVE_FLOAT16(sqrt, hsqrt)
NATIVE_FLOAT162(sqrt, h2sqrt)
NATIVE_BFLOAT16(sqrt, hsqrt)
NATIVE_BFLOAT162(sqrt, h2sqrt)

// tan
PROMOTED_FLOAT16(tan)
PROMOTED_FLOAT162(tan)
PROMOTED_BFLOAT16(tan)
PROMOTED_BFLOAT162(tan)

// tanh
PROMOTED_FLOAT16(tanh)
PROMOTED_FLOAT162(tanh)
PROMOTED_BFLOAT16(tanh)
PROMOTED_BFLOAT162(tanh)

//==============================================================================
// supplemental + - * / functions
//==============================================================================

// add
template<typename T>
__device__ inline T add(const T& a, const T& b) { return a + b; }
PROMOTED2_BFLOAT162(add)

// divide
template<typename T>
__device__ inline T divide(const T& a, const T& b) { return a / b; }
PROMOTED2_BFLOAT162(divide)

// multiply
template<typename T>
__device__ inline T multiply(const T& a, const T& b) { return a * b; }
PROMOTED2_BFLOAT162(multiply)

// multiply
template<typename T>
__device__ inline T multiplyAdd(const T& a, const T& b, const T& c) { return a * b + c; }

// subtract
template<typename T>
__device__ inline T subtract(const T& a, const T& b) { return a - b; }
PROMOTED2_BFLOAT162(subtract)

//==============================================================================
// supplemental custom functions
//==============================================================================

// neg
template<typename T>
__device__ inline T neg(const T& a) { return -a; }

NATIVE_FLOAT162(neg, __hneg2)
NATIVE_BFLOAT162(neg, __hneg2)

//==============================================================================
// pow Float16
__device__ inline __half pow(const __half& a, const int n) {
    return pow(float(a), n);
}

__device__ inline __half2 pow(const __half2& a, const int n) {
    return __half2(pow(float(a.x), n), pow(float(a.y), n));
}

// pow BFloat16
#if (__CUDA_ARCH__ < 800)
__device__ inline __nv_bfloat16 pow(const __nv_bfloat16& a, const int n) {
    return pow(float(a), n);
}

__device__ inline __nv_bfloat162 pow(const __nv_bfloat162& a, const int n) {
    return __nv_bfloat162(pow(float(a.x), n), pow(float(a.y), n));
}
#else

#endif

//==============================================================================
// root 
template<typename T>
__device__ inline T root(const T& a, const int n) { return pow(a, 1.0f / float(n)); }

//==============================================================================
// sign 
template<typename T>
__device__ inline T sign(const T& a) { return a < T(0) ? T(-1) : T(1); }

__device__ inline uint16_t sign(const uint16_t& a) { return 1; }
__device__ inline uint8_t sign(const uint8_t& a) { return 1; }

// Float16
__device__ inline __half2 sign(const __half2& a) {
    __half2 out; 
    out.x = a.x < __half(0.0f) ? __half(-1.0f) : __half(1.0f); 
    out.y = a.y < __half(0.0f) ? __half(-1.0f) : __half(1.0f); 
    return out;
}

// BFloat16
__device__ inline __nv_bfloat16 sign(const __nv_bfloat16& a) {
    return a < __nv_bfloat16(0.0f) ? __nv_bfloat16(-1.0f) : __nv_bfloat16(1.0f);
}

__device__ inline __nv_bfloat162 sign(const __nv_bfloat162& a) {
    __nv_bfloat162 out;
    out.x = a.x < __nv_bfloat16(0.0f) ? __nv_bfloat16(-1.0f) : __nv_bfloat16(1.0f);
    out.y = a.y < __nv_bfloat16(0.0f) ? __nv_bfloat16(-1.0f) : __nv_bfloat16(1.0f);
    return out;
}

// uchar4
__device__ inline uchar4 sign(const uchar4& a) {
    const uint32_t value = 0x01010101;
    return CAST(uchar4, value);
}

// char4
__device__ inline char4 sign(const char4& a) {
    char4 out;
    out.w = a.w < 0 ? -1 : 1;
    out.x = a.x < 0 ? -1 : 1;
    out.y = a.y < 0 ? -1 : 1;
    out.z = a.z < 0 ? -1 : 1;
    return out;
}

// ushort2
__device__ inline ushort2 sign(const ushort2& a) {
    const uint32_t value = 0x00010001;
    return CAST(ushort2, value);
}

__device__ inline short2 sign(const short2& a) {
    short2 out;
    out.x = a.x < 0 ? -1 : 1;
    out.y = a.y < 0 ? -1 : 1;
    return out;
}

//==============================================================================
// squared 
template<typename T>
__device__ inline T squared(const T& a) { return a * a; }

__device__ inline __nv_bfloat162 squared(const __nv_bfloat162& a) {
    __nv_bfloat162 out;
    out.x = a.x * a.x;
    out.y = a.y * a.y;
    return out;
}

//------------------------------------------------------------------------------
// sigmoid Float16
template<typename T>
__device__ inline T sigmoid(const T& a) { return T(1) / (T(1) + exp(-a)); }

__device__ inline __half2 sigmoid(const __half2& a) {
    const __half2 one = __half2(1, 1);
    return one / (one + exp(-a));
}

PROMOTED_BFLOAT16(sigmoid)
PROMOTED_BFLOAT162(sigmoid)

//==============================================================================
// complex supplemental functions
//==============================================================================

// template<typename I, typename O>
// __CUDA_HOSTDEVICE__ inline O abs(const I& v) {
//     return sqrt(v.real() * v.real() + v.imaginary() * v.imaginary());
// } 

//==============================================================================
// add


//==============================================================================
// SIMD supplemental functions
//==============================================================================

//==============================================================================
// neg

//--------------------------------------
// char4
__device__ inline char4 operator-(const char4& v) {
    auto out = __vneg4(UINT_CREF(v));
    return CAST(char4, out);
}
__device__ inline uchar4 operator-(const uchar4& v) { return v; }

//--------------------------------------
// short2
__device__ inline short2 operator-(const short2& v) {
    auto out = __vneg2(UINT_CREF(v));
    return CAST(short2, out);
}

//==============================================================================
// abs

//--------------------------------------
// char4
__device__ inline char4 abs(const char4& v) {
    auto out = __vabs4(UINT_CREF(v));
    return CAST(char4, out);
}
__device__ inline uchar4 abs(const uchar4& v) { return v; }

//--------------------------------------
// short2
__device__ inline short2 abs(const short2& v) {
    auto out = __vabs2(UINT_CREF(v));
    return CAST(short2, out);
}
__device__ inline ushort2 abs(const ushort2& v) { return v; }

//==============================================================================
// add

//--------------------------------------
// char4
__device__ inline char4 operator+(const char4& a, const char4& b) {
    auto out = __vadd4(UINT_CREF(a), UINT_CREF(b));
    return CAST(char4, out);
}

__device__ inline uchar4 operator+(const uchar4& a, const uchar4& b) {
    auto out = __vadd4(UINT_CREF(a), UINT_CREF(b));
    return CAST(uchar4, out);
}

//--------------------------------------
// short2
__device__ inline short2 operator+(const short2& a, const short2& b) {
    auto out = __vadd2(UINT_CREF(a), UINT_CREF(b));
    return CAST(short2, out);
}

__device__ inline ushort2 operator+(const ushort2& a, const ushort2& b) {
    auto out = __vadd2(UINT_CREF(a), UINT_CREF(b));
    return CAST(ushort2, out);
}

//==============================================================================
// subtract

//--------------------------------------
// char4
__device__ inline char4 operator-(const char4& a, const char4& b) {
    auto out = __vsub4(UINT_CREF(a), UINT_CREF(b));
    return CAST(char4, out);
}

__device__ inline uchar4 operator-(const uchar4& a, const uchar4& b) {
    auto out = __vsub4(UINT_CREF(a), UINT_CREF(b));
    return CAST(uchar4, out);
}

//--------------------------------------
// short2
__device__ inline short2 operator-(const short2& a, const short2& b) {
    auto out = __vsub2(UINT_CREF(a), UINT_CREF(b));
    return CAST(short2, out);
}

__device__ inline ushort2 operator-(const ushort2& a, const ushort2& b) {
    auto out = __vsub2(UINT_CREF(a), UINT_CREF(b));
    return CAST(ushort2, out);
}

//==============================================================================
// multiply

//--------------------------------------
// char4
__device__ inline char4 operator*(const char4& a, const char4& b) {
    char4 out;
    out.x = a.x * b.x;
    out.y = a.y * b.y;
    out.z = a.z * b.z;
    out.w = a.w * b.w;
    return out;
}

__device__ inline uchar4 operator*(const uchar4& a, const uchar4& b) {
    uchar4 out;
    out.x = a.x * b.x;
    out.y = a.y * b.y;
    out.z = a.z * b.z;
    out.w = a.w * b.w;
    return out;
}

//--------------------------------------
// short2
__device__ inline short2 operator*(const short2& a, const short2& b) {
    short2 out;
    out.x = a.x * b.x;
    out.y = a.y * b.y;
    return out;
}

__device__ inline ushort2 operator*(const ushort2& a, const ushort2& b) {
    ushort2 out;
    out.x = a.x * b.x;
    out.y = a.y * b.y;
    return out;
}

//==============================================================================
// divide

//--------------------------------------
// char4
__device__ inline char4 operator/(const char4& a, const char4& b) {
    char4 out;
    out.x = a.x / b.x;
    out.y = a.y / b.y;
    out.z = a.z / b.z;
    out.w = a.w / b.w;
    return out;
}

__device__ inline uchar4 operator/(const uchar4& a, const uchar4& b) {
    uchar4 out;
    out.x = a.x / b.x;
    out.y = a.y / b.y;
    out.z = a.z / b.z;
    out.w = a.w / b.w;
    return out;
}

//--------------------------------------
// short2
__device__ inline short2 operator/(const short2& a, const short2& b) {
    short2 out;
    out.x = a.x / b.x;
    out.y = a.y / b.y;
    return out;
}

__device__ inline ushort2 operator/(const ushort2& a, const ushort2& b) {
    ushort2 out;
    out.x = a.x / b.x;
    out.y = a.y / b.y;
    return out;
}

//==============================================================================
#endif // mathSupplemental_h