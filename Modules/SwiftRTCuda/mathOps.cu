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
#include "dispatchHelpers.h"
#include "mathOps.h"
#include "mathSupplemental.h"
#include <type_traits>

//==============================================================================
// Swift importable C interface functions
//==============================================================================

//------------------------------------------------------------------------------
Op1(Abs, abs, (isSame<T,Out>() && isNumeric<T>()) || isComplex<T>())

cudaError_t srtAbs(
    const void* a, const srtTensorDescriptor* paDesc,
    void* out, const srtTensorDescriptor* poDesc,
    cudaStream_t stream
) {
    Cast2TensorDescriptorsA(paDesc, poDesc)
    return select<Abs>(a, aDesc, out, oDesc, stream);
}

//------------------------------------------------------------------------------
Op1(Acos, acos, (isSame<T,Out>() && isFloating<T>()))

// Must be promoted types
cudaError_t srtAcos(
    const void* a, const srtTensorDescriptor* paDesc,
    void* out, const srtTensorDescriptor* poDesc,
    cudaStream_t stream
) {
    Cast2TensorDescriptorsA(paDesc, poDesc)
    return select<Acos>(a, aDesc, out, oDesc, stream);
}

//------------------------------------------------------------------------------
Op1(Acosh, acosh, (isSame<T,Out>() && isFloating<T>()))

cudaError_t srtAcosh(
    const void* a, const srtTensorDescriptor* paDesc,
    void* out, const srtTensorDescriptor* poDesc,
    cudaStream_t stream
) {
    Cast2TensorDescriptorsA(paDesc, poDesc)
    return select<Acosh>(a, aDesc, out, oDesc, stream);
}

//------------------------------------------------------------------------------
Op2(Add, add, (isSame<T,Out>() && isNumeric<T>()))

cudaError_t srtAdd(
    const void* a, const srtTensorDescriptor* paDesc,
    const void* b, const srtTensorDescriptor* pbDesc,
    void* out, const srtTensorDescriptor* poDesc,
    cudaStream_t stream
) {
    Cast2TensorDescriptorsAB(paDesc, pbDesc, poDesc)
    return select<Add>(a, aDesc, b, bDesc, out, oDesc, stream);
}

//------------------------------------------------------------------------------
cudaError_t srtAddTE(
    const void* a, const srtTensorDescriptor* paDesc,
    const void* element,
    void* out, const srtTensorDescriptor* poDesc,
    cudaStream_t stream
) {
    Cast2TensorDescriptorsA(paDesc, poDesc)
    return select<Add>(a, aDesc, element, out, oDesc, stream);
}

//------------------------------------------------------------------------------
Op1(Asin, asin, (isSame<T,Out>() && isFloating<T>()))

cudaError_t srtAsin(
    const void* a, const srtTensorDescriptor* paDesc,
    void* out, const srtTensorDescriptor* poDesc,
    cudaStream_t stream)
{
    Cast2TensorDescriptorsA(paDesc, poDesc)
    return select<Asin>(a, aDesc, out, oDesc, stream);
}

//------------------------------------------------------------------------------
Op1(Asinh, asinh, (isSame<T,Out>() && isFloating<T>()))

cudaError_t srtAsinh(
    const void* a, const srtTensorDescriptor* paDesc,
    void* out, const srtTensorDescriptor* poDesc,
    cudaStream_t stream)
{
    Cast2TensorDescriptorsA(paDesc, poDesc)
    return select<Asinh>(a, aDesc, out, oDesc, stream);
}

//------------------------------------------------------------------------------
Op1(Atan, atan, (isSame<T,Out>() && isFloating<T>()))

cudaError_t srtAtan(
    const void* a, const srtTensorDescriptor* paDesc,
    void* out, const srtTensorDescriptor* poDesc,
    cudaStream_t stream)
{
    Cast2TensorDescriptorsA(paDesc, poDesc)
    return select<Atan>(a, aDesc, out, oDesc, stream);
}

//------------------------------------------------------------------------------
cudaError_t srtAtan2(
    const void* b, const srtTensorDescriptor* pbDesc,
    const void* a, const srtTensorDescriptor* paDesc,
    void* out, const srtTensorDescriptor* poDesc,
    cudaStream_t stream)
{
    // Cast2TensorDescriptorsAB(paDesc, pbDesc, poDesc)
    // // b comes first
    // return select<Atan2>(b, bDesc, a, aDesc, out, oDesc, stream);
    return cudaErrorNotSupported;
}

//------------------------------------------------------------------------------
Op1(Atanh, atanh, (isSame<T,Out>() && isFloating<T>()))

cudaError_t srtAtanh(
    const void* a, const srtTensorDescriptor* paDesc,
    void* out, const srtTensorDescriptor* poDesc,
    cudaStream_t stream)
{
    Cast2TensorDescriptorsA(paDesc, poDesc)
    return select<Atanh>(a, aDesc, out, oDesc, stream);
}

//------------------------------------------------------------------------------
Op1(Cos, cos, (isSame<T,Out>() && isFloating<T>()))

cudaError_t srtCos(
    const void* a, const srtTensorDescriptor* paDesc,
    void* out, const srtTensorDescriptor* poDesc,
    cudaStream_t stream)
{
    Cast2TensorDescriptorsA(paDesc, poDesc)
    return select<Cos>(a, aDesc, out, oDesc, stream);
}

//------------------------------------------------------------------------------
Op1(Cosh, cosh, (isSame<T,Out>() && isFloating<T>()))

cudaError_t srtCosh(
    const void* a, const srtTensorDescriptor* paDesc,
    void* out, const srtTensorDescriptor* poDesc,
    cudaStream_t stream)
{
    Cast2TensorDescriptorsA(paDesc, poDesc)
    return select<Cosh>(a, aDesc, out, oDesc, stream);
}

//------------------------------------------------------------------------------
Op2(Div, divide, (isSame<T,Out>() && isNumeric<T>()))

cudaError_t srtDiv(
    const void* a, const srtTensorDescriptor* paDesc,
    const void* b, const srtTensorDescriptor* pbDesc,
    void* out, const srtTensorDescriptor* poDesc,
    cudaStream_t stream
) {
    Cast2TensorDescriptorsAB(paDesc, pbDesc, poDesc)
    return select<Div>(a, aDesc, b, bDesc, out, oDesc, stream);
}

cudaError_t srtDivTE(
    const void* a, const srtTensorDescriptor* paDesc,
    const void* element,
    void* out, const srtTensorDescriptor* poDesc,
    cudaStream_t stream
) {
    Cast2TensorDescriptorsA(paDesc, poDesc)
    return select<Div>(a, aDesc, element, out, oDesc, stream);
}

cudaError_t srtDivET(
    const void* element,
    const void* a, const srtTensorDescriptor* paDesc,
    void* out, const srtTensorDescriptor* poDesc,
    cudaStream_t stream
) {
    Cast2TensorDescriptorsA(paDesc, poDesc)
    return select<Div>(element, a, aDesc, out, oDesc, stream);
}

//------------------------------------------------------------------------------
Op1(Erf, erf, (isSame<T,Out>() && isFloating<T>()))

cudaError_t srtErf(
    const void* a, const srtTensorDescriptor* paDesc,
    void* out, const srtTensorDescriptor* poDesc,
    cudaStream_t stream)
{
    Cast2TensorDescriptorsA(paDesc, poDesc)
    return select<Erf>(a, aDesc, out, oDesc, stream);
}

//------------------------------------------------------------------------------
Op1(Erfc, erfc, (isSame<T,Out>() && isFloating<T>()))

cudaError_t srtErfc(
    const void* a, const srtTensorDescriptor* paDesc,
    void* out, const srtTensorDescriptor* poDesc,
    cudaStream_t stream)
{
    Cast2TensorDescriptorsA(paDesc, poDesc)
    return select<Erfc>(a, aDesc, out, oDesc, stream);
}

//------------------------------------------------------------------------------
Op1(Exp, exp, (isSame<T,Out>() && isFloating<T>()))

cudaError_t srtExp(
    const void* a, const srtTensorDescriptor* paDesc,
    void* out, const srtTensorDescriptor* poDesc,
    cudaStream_t stream)
{
    Cast2TensorDescriptorsA(paDesc, poDesc)
    return select<Exp>(a, aDesc, out, oDesc, stream);
}

//------------------------------------------------------------------------------
Op1(Exp2, exp2, (isSame<T,Out>() && isFloating<T>()))

cudaError_t srtExp2(
    const void* a, const srtTensorDescriptor* paDesc,
    void* out, const srtTensorDescriptor* poDesc,
    cudaStream_t stream)
{
    Cast2TensorDescriptorsA(paDesc, poDesc)
    return select<Exp2>(a, aDesc, out, oDesc, stream);
}

//------------------------------------------------------------------------------
Op1(Exp10, exp10, (isSame<T,Out>() && isFloating<T>()))

cudaError_t srtExp10(
    const void* a, const srtTensorDescriptor* paDesc,
    void* out, const srtTensorDescriptor* poDesc,
    cudaStream_t stream)
{
    Cast2TensorDescriptorsA(paDesc, poDesc)
    return select<Exp10>(a, aDesc, out, oDesc, stream);
}

//------------------------------------------------------------------------------
Op1(ExpMinusOne, expm1, (isSame<T,Out>() && isFloating<T>()))

cudaError_t srtExpMinusOne(
    const void* a, const srtTensorDescriptor* paDesc,
    void* out, const srtTensorDescriptor* poDesc,
    cudaStream_t stream)
{
    Cast2TensorDescriptorsA(paDesc, poDesc)
    return select<ExpMinusOne>(a, aDesc, out, oDesc, stream);
}

//------------------------------------------------------------------------------
Op1(Gamma, tgamma, (isSame<T,Out>() && isFloating<T>()))

cudaError_t srtGamma(
    const void* a, const srtTensorDescriptor* paDesc,
    void* out, const srtTensorDescriptor* poDesc,
    cudaStream_t stream)
{
    Cast2TensorDescriptorsA(paDesc, poDesc)
    return select<Gamma>(a, aDesc, out, oDesc, stream);
}

//------------------------------------------------------------------------------
Op2(Hypot, hypot, (isSame<T,Out>() && isFloating<T>()))

cudaError_t srtHypot(
    const void* a, const srtTensorDescriptor* paDesc,
    const void* b, const srtTensorDescriptor* pbDesc,
    void* out, const srtTensorDescriptor* poDesc,
    cudaStream_t stream)
{
    Cast2TensorDescriptorsAB(paDesc, pbDesc, poDesc)
    return select<Hypot>(a, aDesc, b, bDesc, out, oDesc, stream);
}

//------------------------------------------------------------------------------
Op1(Log, log, (isSame<T,Out>() && isFloating<T>()))

cudaError_t srtLog(
    const void* a, const srtTensorDescriptor* paDesc,
    void* out, const srtTensorDescriptor* poDesc,
    cudaStream_t stream)
{
    Cast2TensorDescriptorsA(paDesc, poDesc)
    return select<Log>(a, aDesc, out, oDesc, stream);
}

//------------------------------------------------------------------------------
Op1(LogOnePlus, log1p, (isSame<T,Out>() && isFloating<T>()))

cudaError_t srtLogOnePlus(
    const void* a, const srtTensorDescriptor* paDesc,
    void* out, const srtTensorDescriptor* poDesc,
    cudaStream_t stream)
{
    Cast2TensorDescriptorsA(paDesc, poDesc)
    return select<LogOnePlus>(a, aDesc, out, oDesc, stream);
}

//------------------------------------------------------------------------------
Op1(Log2, log2, (isSame<T,Out>() && isFloating<T>()))

cudaError_t srtLog2(
    const void* a, const srtTensorDescriptor* paDesc,
    void* out, const srtTensorDescriptor* poDesc,
    cudaStream_t stream)
{
    Cast2TensorDescriptorsA(paDesc, poDesc)
    return select<Log2>(a, aDesc, out, oDesc, stream);
}

//------------------------------------------------------------------------------
Op1(Log10, log10, (isSame<T,Out>() && isFloating<T>()))

cudaError_t srtLog10(
    const void* a, const srtTensorDescriptor* paDesc,
    void* out, const srtTensorDescriptor* poDesc,
    cudaStream_t stream)
{
    Cast2TensorDescriptorsA(paDesc, poDesc)
    return select<Log10>(a, aDesc, out, oDesc, stream);
}

//------------------------------------------------------------------------------
Op1(LogGamma, lgamma, (isSame<T,Out>() && isFloating<T>()))

cudaError_t srtLogGamma(
    const void* a, const srtTensorDescriptor* paDesc,
    void* out, const srtTensorDescriptor* poDesc,
    cudaStream_t stream)
{
    Cast2TensorDescriptorsA(paDesc, poDesc)
    return select<LogGamma>(a, aDesc, out, oDesc, stream);
}

//------------------------------------------------------------------------------
Op2(Mul, multiply, (isSame<T,Out>() && isNumeric<T>()))

cudaError_t srtMul(
    const void* a, const srtTensorDescriptor* paDesc,
    const void* b, const srtTensorDescriptor* pbDesc,
    void* out, const srtTensorDescriptor* poDesc,
    cudaStream_t stream
) {
    Cast2TensorDescriptorsAB(paDesc, pbDesc, poDesc)
    return select<Mul>(a, aDesc, b, bDesc, out, oDesc, stream);
}

cudaError_t srtMulTE(
    const void* a, const srtTensorDescriptor* paDesc,
    const void* element,
    void* out, const srtTensorDescriptor* poDesc,
    cudaStream_t stream
) {
    Cast2TensorDescriptorsA(paDesc, poDesc)
    return select<Mul>(a, aDesc, element, out, oDesc, stream);
}

//------------------------------------------------------------------------------
OpTTU(MultiplyAdd, multiplyAdd, (isSame<T,Out>() && isSame<T,U>() && isNumeric<T>()))

cudaError_t srtMultiplyAdd(
    const void* a, const srtTensorDescriptor* paDesc,
    const void* b, const srtTensorDescriptor* pbDesc,
    const void* c, const srtTensorDescriptor* pcDesc,
    void* out, const srtTensorDescriptor* poDesc,
    cudaStream_t stream
) {
    Cast2TensorDescriptorsABC(paDesc, pbDesc, pcDesc, poDesc)
    return select<MultiplyAdd>(a, aDesc, b, bDesc, c, cDesc, out, oDesc, stream);
}

Op3(MultiplyAddE, multiplyAdd, (isSame<T,Out>() && isNumeric<T>()))

cudaError_t srtMultiplyAddTTE(
    const void* a, const srtTensorDescriptor* paDesc,
    const void* b, const srtTensorDescriptor* pbDesc,
    const void* element,
    void* out, const srtTensorDescriptor* poDesc,
    cudaStream_t stream
) {
    Cast2TensorDescriptorsAB(paDesc, pbDesc, poDesc)
    return select<MultiplyAddE>(a, aDesc, b, bDesc, element, out, oDesc, stream);
}

//------------------------------------------------------------------------------
Op1(Neg, neg, (isSame<T,Out>() && (isSignedNumeric<T>() || isComplex<T>())))

cudaError_t srtNeg(
    const void* a, const srtTensorDescriptor* paDesc,
    void* out, const srtTensorDescriptor* poDesc,
    cudaStream_t stream)
{
    Cast2TensorDescriptorsA(paDesc, poDesc)
    return select<Neg>(a, aDesc, out, oDesc, stream);
}

//------------------------------------------------------------------------------
Op2(Pow, pow, (isSame<T,Out>() && isFloating<T>()))

cudaError_t srtPow(
    const void* a, const srtTensorDescriptor* paDesc,
    const void* b, const srtTensorDescriptor* pbDesc,
    void* out, const srtTensorDescriptor* poDesc,
    cudaStream_t stream)
{
    Cast2TensorDescriptorsAB(paDesc, pbDesc, poDesc)
    return select<Pow>(a, aDesc, b, bDesc, out, oDesc, stream);
}

//------------------------------------------------------------------------------
cudaError_t srtPowN(
    const void* a, const srtTensorDescriptor* paDesc, long n,
    void* out, const srtTensorDescriptor* poDesc,
    cudaStream_t stream)
{
    // Cast2TensorDescriptorsA(paDesc, poDesc)
    // return select<PowN>(a, aDesc, int(n), out, oDesc, stream);
    return cudaErrorNotSupported;
}

//------------------------------------------------------------------------------
cudaError_t srtRoot(
    const void* a, const srtTensorDescriptor* paDesc, long n,
    void* out, const srtTensorDescriptor* poDesc,
    cudaStream_t stream)
{
    // Cast2TensorDescriptorsA(paDesc, poDesc)
    // return select<Root>(a, aDesc, int(n), out, oDesc, stream);
    return cudaErrorNotSupported;
}

//------------------------------------------------------------------------------
Op1(Sigmoid, sigmoid, (isSame<T,Out>() && isFloating<T>()))

cudaError_t srtSigmoid(
    const void* a, const srtTensorDescriptor* paDesc,
    void* out, const srtTensorDescriptor* poDesc,
    cudaStream_t stream)
{
    Cast2TensorDescriptorsA(paDesc, poDesc)
    return select<Sigmoid>(a, aDesc, out, oDesc, stream);
}

//------------------------------------------------------------------------------
Op1(Sign, sign, (isSame<T,Out>() && isSignedNumeric<T>()))

cudaError_t srtSign(
    const void* a, const srtTensorDescriptor* paDesc,
    void* out, const srtTensorDescriptor* poDesc,
    cudaStream_t stream)
{
    Cast2TensorDescriptorsA(paDesc, poDesc)
    return select<Sign>(a, aDesc, out, oDesc, stream);
}

//------------------------------------------------------------------------------
Op1(Sin, sin, (isSame<T,Out>() && isFloating<T>()))

cudaError_t srtSin(
    const void* a, const srtTensorDescriptor* paDesc,
    void* out, const srtTensorDescriptor* poDesc,
    cudaStream_t stream)
{
    Cast2TensorDescriptorsA(paDesc, poDesc)
    return select<Sin>(a, aDesc, out, oDesc, stream);
}

//------------------------------------------------------------------------------
Op1(Sinh, sinh, (isSame<T,Out>() && isFloating<T>()))

cudaError_t srtSinh(
    const void* a, const srtTensorDescriptor* paDesc,
    void* out, const srtTensorDescriptor* poDesc,
    cudaStream_t stream
) {
    Cast2TensorDescriptorsA(paDesc, poDesc)
    return select<Sinh>(a, aDesc, out, oDesc, stream);
}

//------------------------------------------------------------------------------
Op1(Sqrt, sqrt, (isSame<T,Out>() && isFloating<T>()))

cudaError_t srtSqrt(
    const void* a, const srtTensorDescriptor* paDesc,
    void* out, const srtTensorDescriptor* poDesc,
    cudaStream_t stream
) {
    Cast2TensorDescriptorsA(paDesc, poDesc)
    return select<Sqrt>(a, aDesc, out, oDesc, stream);
}

//------------------------------------------------------------------------------
Op1(Squared, squared, (isSame<T,Out>() && isNumeric<T>()))

cudaError_t srtSquared(
    const void* a, const srtTensorDescriptor* paDesc,
    void* out, const srtTensorDescriptor* poDesc,
    cudaStream_t stream)
{
    Cast2TensorDescriptorsA(paDesc, poDesc)
    return select<Squared>(a, aDesc, out, oDesc, stream);
}

//------------------------------------------------------------------------------
Op2(Sub, subtract, (isSame<T,Out>() && isNumeric<T>()))

cudaError_t srtSub(
    const void* a, const srtTensorDescriptor* paDesc,
    const void* b, const srtTensorDescriptor* pbDesc,
    void* out, const srtTensorDescriptor* poDesc,
    cudaStream_t stream
) {
    Cast2TensorDescriptorsAB(paDesc, pbDesc, poDesc)
    return select<Sub>(a, aDesc, b, bDesc, out, oDesc, stream);
}

cudaError_t srtSubTE(
    const void* a, const srtTensorDescriptor* paDesc,
    const void* element,
    void* out, const srtTensorDescriptor* poDesc,
    cudaStream_t stream
) {
    Cast2TensorDescriptorsA(paDesc, poDesc)
    return select<Sub>(a, aDesc, element, out, oDesc, stream);
}

cudaError_t srtSubET(
    const void* element,
    const void* a, const srtTensorDescriptor* paDesc,
    void* out, const srtTensorDescriptor* poDesc,
    cudaStream_t stream
) {
    Cast2TensorDescriptorsA(paDesc, poDesc)
    return select<Sub>(element, a, aDesc, out, oDesc, stream);
}

//------------------------------------------------------------------------------
Op1(Tan, tan, (isSame<T,Out>() && isFloating<T>()))

cudaError_t srtTan(
    const void* a, const srtTensorDescriptor* paDesc,
    void* out, const srtTensorDescriptor* poDesc,
    cudaStream_t stream
) {
    Cast2TensorDescriptorsA(paDesc, poDesc)
    return select<Tan>(a, aDesc, out, oDesc, stream);
}

//------------------------------------------------------------------------------
Op1(Tanh, tanh, (isSame<T,Out>() && isFloating<T>()))

cudaError_t srtTanh(
    const void* a, const srtTensorDescriptor* paDesc,
    void* out, const srtTensorDescriptor* poDesc,
    cudaStream_t stream
) {
    Cast2TensorDescriptorsA(paDesc, poDesc)
    return select<Tanh>(a, aDesc, out, oDesc, stream);
}