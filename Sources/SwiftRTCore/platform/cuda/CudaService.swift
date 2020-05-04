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
import CCuda

//==============================================================================
/// CudaService
/// The collection of compute resources available to the application
/// on the machine where the process is being run.
public class CudaService: Platform, Logger {
    // properties
    public var devices: [CudaDevice]
    public let logInfo: LogInfo
    public let name: String
    public var queueStack: [QueueId]

    //--------------------------------------------------------------------------
    @inlinable
    public init() {
        name = "Cuda"
        logInfo = LogInfo(logWriter: Context.log, logLevel: .error,
                          namePath: name, nestingLevel: 0)
        
        // add a device whose queue is synchronized with the application
        devices = [CudaDevice(parent: logInfo, id: 0)]
        queueStack = []

        // query cuda to get number of installed devices
        var deviceCount: CInt = 0
        do {
            try cudaCheck(status: cudaGetDeviceCount(&deviceCount))
        } catch {
            writeLog("cudaGetDeviceCount failed. " +
                "The Cuda driver may be in an unstable state",
                     level: .error)
            fatalError()
        }
        
        if deviceCount > 0 {
            writeLog("There are no '\(self.name)' devices installed",
                level: .warning)
        }
        
        // add device object for each id reported
        for i in 0..<Int(deviceCount) {
            devices.append(CudaDevice(parent: logInfo, id: i + 1))
        }
        
        // select device 1 queue 0 by default
        queueStack = [ensureValidId(1, 0)]
    }
}

//==============================================================================
// cudaCheck cudaError_t
@inlinable
public func cudaCheck(status: cudaError_t, file: String = #file,
                      function: String = #function, line: Int = #line) throws {
    if status != cudaSuccess {
        let location = "CUDA error in \(file) at \(function):\(line)"
        let message = String(utf8String: cudaGetErrorString(status))!
        cudaDeviceReset()
        throw ServiceError.functionFailure(location: location, message: message)
    }
}

//==============================================================================
// cudaCheck cudnnStatus_t
@inlinable
public func cudaCheck(status: cudnnStatus_t, file: String = #file,
                      function: String = #function, line: Int = #line) throws {
    if status != CUDNN_STATUS_SUCCESS {
        let location = "CUDNN error in \(file) at \(function):\(line)"
        let message = String(utf8String: cudnnGetErrorString(status))!
        print(message)
        cudaDeviceReset()
        throw ServiceError.functionFailure(location: location, message: message)
    }
}

//==============================================================================
// cudaCheck cublasStatus_t
@inlinable
public func cudaCheck(status: cublasStatus_t, file: String = #file,
                      function: String = #function, line: Int = #line) throws {
    if status != CUBLAS_STATUS_SUCCESS {
        let location = "CUBLAS error in \(file) at \(function):\(line)"
        let message = String(utf8String: cublasGetErrorString(status))!
            + "code=(\(status))"
        cudaDeviceReset()
        throw ServiceError.functionFailure(location: location, message: message)
    }
}

extension cublasStatus_t : Hashable {}

@inlinable
public func cublasGetErrorString(_ status: cublasStatus_t) -> String {
    let messages = [
        CUBLAS_STATUS_SUCCESS: "CUBLAS_STATUS_SUCCESS",
        CUBLAS_STATUS_NOT_INITIALIZED: "CUBLAS_STATUS_NOT_INITIALIZED",
        CUBLAS_STATUS_ALLOC_FAILED: "CUBLAS_STATUS_ALLOC_FAILED",
        CUBLAS_STATUS_INVALID_VALUE: "CUBLAS_STATUS_INVALID_VALUE",
        CUBLAS_STATUS_ARCH_MISMATCH: "CUBLAS_STATUS_ARCH_MISMATCH",
        CUBLAS_STATUS_MAPPING_ERROR: "CUBLAS_STATUS_MAPPING_ERROR",
        CUBLAS_STATUS_EXECUTION_FAILED: "CUBLAS_STATUS_EXECUTION_FAILED",
        CUBLAS_STATUS_INTERNAL_ERROR: "CUBLAS_STATUS_INTERNAL_ERROR",
        CUBLAS_STATUS_NOT_SUPPORTED: "CUBLAS_STATUS_NOT_SUPPORTED",
        CUBLAS_STATUS_LICENSE_ERROR: "CUBLAS_STATUS_LICENSE_ERROR",
    ]
    return messages[status] ?? "Unknown cublasStatus_t value: \(status)"
}

//==============================================================================
// cudaCheck curandStatus_t
@inlinable
public func cudaCheck(status: curandStatus_t, file: String = #file,
                      function: String = #function, line: Int = #line) throws {
    if status != CURAND_STATUS_SUCCESS {
        let location = "CURAND error in \(file) at \(function):\(line)"
        let message = String(utf8String: curandGetErrorString(status))!
            + "code=(\(status))"
        cudaDeviceReset()
        throw ServiceError.functionFailure(location: location, message: message)
    }
}

extension curandStatus_t : Hashable {}

@inlinable
public func curandGetErrorString(_ status: curandStatus_t) -> String {
    let messages = [
        CURAND_STATUS_SUCCESS: "CURAND_STATUS_SUCCESS",
        CURAND_STATUS_VERSION_MISMATCH: "CURAND_STATUS_VERSION_MISMATCH",
        CURAND_STATUS_NOT_INITIALIZED: "CURAND_STATUS_NOT_INITIALIZED",
        CURAND_STATUS_ALLOCATION_FAILED: "CURAND_STATUS_ALLOCATION_FAILED",
        CURAND_STATUS_TYPE_ERROR: "CURAND_STATUS_TYPE_ERROR",
        CURAND_STATUS_OUT_OF_RANGE: "CURAND_STATUS_OUT_OF_RANGE",
        CURAND_STATUS_LENGTH_NOT_MULTIPLE: "CURAND_STATUS_LENGTH_NOT_MULTIPLE",
        CURAND_STATUS_DOUBLE_PRECISION_REQUIRED: "CURAND_STATUS_DOUBLE_PRECISION_REQUIRED",
        CURAND_STATUS_LAUNCH_FAILURE: "CURAND_STATUS_LAUNCH_FAILURE",
        CURAND_STATUS_PREEXISTING_FAILURE: "CURAND_STATUS_PREEXISTING_FAILURE",
        CURAND_STATUS_INITIALIZATION_FAILED: "CURAND_STATUS_INITIALIZATION_FAILED",
        CURAND_STATUS_ARCH_MISMATCH: "CURAND_STATUS_ARCH_MISMATCH",
        CURAND_STATUS_INTERNAL_ERROR: "CURAND_STATUS_INTERNAL_ERROR",
    ]
    return messages[status] ?? "Unknown curandStatus_t value: \(status)"
}

//==============================================================================
/// ReductionContext
public protocol ReductionContext {
}

//------------------------------------------------------------------------------
// ReductionOp extension
extension cudnnReduceTensorOp_t : Hashable {}

extension ReductionOp {
    @inlinable
    public var cudnn: cudnnReduceTensorOp_t {
        get {
            let ops = [
                ReductionOp.add: CUDNN_REDUCE_TENSOR_ADD,
                ReductionOp.mul: CUDNN_REDUCE_TENSOR_MUL,
                ReductionOp.min: CUDNN_REDUCE_TENSOR_MIN,
                ReductionOp.max: CUDNN_REDUCE_TENSOR_MAX,
                ReductionOp.amax: CUDNN_REDUCE_TENSOR_AMAX,
                ReductionOp.mean: CUDNN_REDUCE_TENSOR_AVG,
                ReductionOp.asum: CUDNN_REDUCE_TENSOR_NORM1,
                ReductionOp.sqrtSumSquares: CUDNN_REDUCE_TENSOR_NORM2,
            ]
            return ops[self]!
        }
    }
}

//------------------------------------------------------------------------------
// ScalarType extension
extension cudnnDataType_t : Hashable {}

extension ScalarType {
    @inlinable
    public init(cudnn: cudnnDataType_t) {
        let types: [cudnnDataType_t : ScalarType] = [
            CUDNN_DATA_INT8: .real8U,
            CUDNN_DATA_INT32: .real32I,
            CUDNN_DATA_HALF: .real16F,
            CUDNN_DATA_FLOAT: .real32F,
            CUDNN_DATA_DOUBLE: .real64F,
        ]
        assert(types[cudnn] != nil, "Unknown cudnnDataType_t")
        self = types[cudnn]!
    }

    @inlinable
    public var cudnn: cudnnDataType_t {
        get {
            switch self {
            case .real8U: return CUDNN_DATA_INT8
            case .real32I: return CUDNN_DATA_INT32
            case .real16F: return CUDNN_DATA_HALF
            case .real32F: return CUDNN_DATA_FLOAT
            case .real64F: return CUDNN_DATA_DOUBLE
            default: fatalError("Invalid state")
            }
        }
    }

    @inlinable
    public var cuda: cudaDataType {
        get {
            let types: [ScalarType : cudaDataType] = [
                .real16F: CUDA_R_16F,
                .real32F: CUDA_R_32F,
                .real64F: CUDA_R_64F,
                .real8U:  CUDA_R_8U,
                .real32I: CUDA_R_32I,
            ]
            assert(types[self] != nil, "Unknown cudnnDataType_t")
            return types[self]!
        }
    }
}

//------------------------------------------------------------------------------
// NanPropagation
extension NanPropagation {
    @inlinable
    public var cudnn: cudnnNanPropagation_t {
        get {
            switch self {
            case .noPropagate: return CUDNN_NOT_PROPAGATE_NAN
            case .propagate: return CUDNN_PROPAGATE_NAN
            }
        }
    }
}

//------------------------------------------------------------------------------
// TransposeOp
extension TransposeOp {
    @inlinable
    public var cublas: cublasOperation_t {
        switch self {
        case .noTranspose: return CUBLAS_OP_N
        case .transpose: return CUBLAS_OP_T
        case .conjugateTranspose: return CUBLAS_OP_C
        }
    }
}

//==============================================================================
/// CudnnHandle
/// creates and manages the lifetime of a cudnn handle
public final class CudnnHandle: ObjectTracking {
    // properties
    public let trackingId: Int
    public let deviceId: Int
    public let handle: cudnnHandle_t

    //--------------------------------------------------------------------------
    /// init
    /// - Parameter deviceId:
    /// - Parameter using:
    @inlinable
    init(deviceId: Int, using stream: cudaStream_t) throws {
        self.deviceId = deviceId
        try cudaCheck(status: cudaSetDevice(Int32(deviceId)))

        var temp: cudnnHandle_t?
        try cudaCheck(status: cudnnCreate(&temp))
        handle = temp!
        try cudaCheck(status: cudnnSetStream(handle, stream))
        trackingId = ObjectTracker.global.nextId
        ObjectTracker.global.register(self)
    }

    //--------------------------------------------------------------------------
    // deinit
    @inlinable
    deinit {
        do {
            try cudaCheck(status: cudaSetDevice(Int32(deviceId)))
            try cudaCheck(status: cudnnDestroy(handle))
            ObjectTracker.global.remove(trackingId: trackingId)
        } catch {
            print("\(releaseString) CudnnHandle(\(trackingId)) "
                + "\(String(describing: error))")
        }
    }
}

//==============================================================================
/// CublasHandle
/// creates and manages the lifetime of a cublas handle
public final class CublasHandle: ObjectTracking {
    // properties
    public let trackingId: Int
    public let deviceId: Int
    public let handle: cublasHandle_t

    //--------------------------------------------------------------------------
    /// init
    /// - Parameter deviceId:
    /// - Parameter using:
    @inlinable
    public init(deviceId: Int, using stream: cudaStream_t) throws
    {
        self.deviceId = deviceId
        try cudaCheck(status: cudaSetDevice(Int32(deviceId)))

        var temp: cublasHandle_t?
        try cudaCheck(status: cublasCreate_v2(&temp))
        handle = temp!
        try cudaCheck(status: cublasSetStream_v2(handle, stream))
        trackingId = ObjectTracker.global.nextId
        ObjectTracker.global.register(self)
    }

    //--------------------------------------------------------------------------
    // deinit
    @inlinable
    deinit {
        do {
            try cudaCheck(status: cudaSetDevice(Int32(deviceId)))
            try cudaCheck(status: cublasDestroy_v2(handle))
            ObjectTracker.global.remove(trackingId: trackingId)
        } catch {
            print("\(releaseString) CublasHandle(\(trackingId)) "
                + "\(String(describing: error))")
        }
    }
}

//==============================================================================
// DropoutDescriptor
public final class DropoutDescriptor: ObjectTracking {
    // properties
    public let trackingId: Int
    public let desc: cudnnDropoutDescriptor_t
    public let states: DeviceMemory

    //--------------------------------------------------------------------------
    // initializers
    @inlinable
    public init(stream: CudaQueue, drop: Double, seed: UInt64,
                tensorDesc: TensorDescriptor) throws {
        // create the descriptor
        var temp: cudnnDropoutDescriptor_t?
        try cudaCheck(status: cudnnCreateDropoutDescriptor(&temp))
        desc = temp!

        // get states size
        var stateSizeInBytes = 0
        try cudaCheck(status: cudnnDropoutGetStatesSize(
            tensorDesc.desc, &stateSizeInBytes))

        // create states array
        states = try stream.allocate(byteCount: stateSizeInBytes, heapIndex: 0)

        // initialize
        try cudaCheck(status: cudnnSetDropoutDescriptor(
            desc,
            stream.cudnn.handle,
            Float(drop),
            states.buffer.baseAddress!,
            states.buffer.count,
            seed
        ))

        trackingId = ObjectTracker.global.nextId
        ObjectTracker.global.register(self)
    }

    //--------------------------------------------------------------------------
    // cleanup
    @inlinable
    deinit {
        try! cudaCheck(status: cudnnDestroyDropoutDescriptor(desc))
        ObjectTracker.global.remove(trackingId: trackingId)
    }
}

//==============================================================================
// FilterDescriptor
public final class FilterDescriptor : ObjectTracking {
    // properties
    public let trackingId: Int
    public let desc: cudnnFilterDescriptor_t

    // initializers
    @inlinable
    public init<T>(_ tensor: T) throws where
        T: TensorView, T.Element: ScalarElement
    {
        // create the descriptor
        var temp: cudnnFilterDescriptor_t?
        try cudaCheck(status: cudnnCreateFilterDescriptor(&temp))
        desc = temp!

        // initialize
        try cudaCheck(status: cudnnSetFilterNdDescriptor(
            desc,
            T.Element.type.cudnn,
            CUDNN_TENSOR_NHWC,
            Int32(tensor.count),
            tensor.bounds.asDeviceIndex))

        trackingId = ObjectTracker.global.nextId
        ObjectTracker.global.register(self)
    }

    @inlinable
    deinit {
        try! cudaCheck(status: cudnnDestroyFilterDescriptor(desc))
        ObjectTracker.global.remove(trackingId: trackingId)
    }
}

//==============================================================================
/// LRNDescriptor
/// creates and manages the lifetime of a cudnn cudnnLRNDescriptor_t
public final class LRNDescriptor: ObjectTracking {
    // properties
    public let trackingId: Int
    public let desc: cudnnLRNDescriptor_t

    //--------------------------------------------------------------------------
    // initializers
    @inlinable
    public init(N: Int, alpha: Double, beta: Double, K: Double) throws {
        guard N >= Int(CUDNN_LRN_MIN_N) && N <= Int(CUDNN_LRN_MAX_N) else {
            throw ServiceError.rangeError(
                "N = \(N) is invalid. Range \(CUDNN_LRN_MIN_N) " +
                        "to \(CUDNN_LRN_MAX_N)")
        }
        guard K >= CUDNN_LRN_MIN_K else {
            throw ServiceError.rangeError(
                "K = \(K) is invalid. Must be >= to \(CUDNN_LRN_MIN_K)")
        }
        guard beta >= CUDNN_LRN_MIN_BETA else {
            throw ServiceError.rangeError(
                "beta = \(beta) is invalid. Must be >= to \(CUDNN_LRN_MIN_BETA)")
        }

        // create the descriptor
        var temp: cudnnLRNDescriptor_t?
        try cudaCheck(status: cudnnCreateLRNDescriptor(&temp))
        desc = temp!

        // initialize
        try cudaCheck(status: cudnnSetLRNDescriptor(
            desc, CUnsignedInt(N), alpha, beta, K))

        trackingId = ObjectTracker.global.nextId
        ObjectTracker.global.register(self)
    }

    //--------------------------------------------------------------------------
    // cleanup
    @inlinable
    deinit {
        try! cudaCheck(status: cudnnDestroyLRNDescriptor(desc))
        ObjectTracker.global.remove(trackingId: trackingId)
    }
}

//==============================================================================
/// TensorDescriptor
/// creates and manages the lifetime of a cudnn tensor handle
public final class TensorDescriptor: ObjectTracking {
    // properties
    public let trackingId: Int
    public let desc: cudnnTensorDescriptor_t

    //--------------------------------------------------------------------------
    // initializers
    @inlinable
    public init<B>(shape: Shape<B>, scalarType: ScalarType) throws
        where B: ShapeBounds
    {
        // create the descriptor
        var temp: cudnnTensorDescriptor_t?
        try cudaCheck(status: cudnnCreateTensorDescriptor(&temp))
        self.desc = temp!

        // initialize
        try cudaCheck(status: cudnnSetTensorNdDescriptor(
            self.desc,
            scalarType.cudnn,
            Int32(shape.count),
            shape.bounds.asDeviceIndex,
            shape.strides.asDeviceIndex))

        trackingId = ObjectTracker.global.nextId
        ObjectTracker.global.register(self)
    }

    @inlinable
    public init(owning desc: cudnnTensorDescriptor_t) {
        self.desc = desc
        trackingId = ObjectTracker.global.nextId
        ObjectTracker.global.register(self)
    }

    //--------------------------------------------------------------------------
    // cleanup
    @inlinable
    deinit {
        try! cudaCheck(status: cudnnDestroyTensorDescriptor(desc))
        ObjectTracker.global.remove(trackingId: trackingId)
    }

    //--------------------------------------------------------------------------
    // getInfo
    @inlinable
    public func getInfo() throws -> (extent: [Int], strides: [Int], ScalarType) {
        let reqDims = Int(CUDNN_DIM_MAX)
        var dims = [Int32](repeating: 0, count: reqDims)
        var strides = [Int32](repeating: 0, count: reqDims)
        var type = cudnnDataType_t(0)
        var numDims: Int32 = 0

        try cudaCheck(status: cudnnGetTensorNdDescriptor(
            desc,
            Int32(reqDims),
            &type,
            &numDims,
            &dims,
            &strides
        ))

        return (dims[0..<Int(numDims)].map { Int($0) },
                strides[0..<Int(numDims)].map { Int($0) },
                ScalarType(cudnn: type))
    }
}

//==============================================================================
/// createTensorDescriptor
/// creates a cudnn tensor descriptor for the associated TensorView
extension TensorView where Element: ScalarElement {
    @inlinable
    public func createTensorDescriptor(
        asShape newShape: Shape<Bounds>? = nil) throws -> TensorDescriptor
    {
        assert(newShape == nil || newShape!.count == shape.count)
        return try TensorDescriptor(shape: newShape ?? shape,
                                    scalarType: Element.type)
    }
}

//==============================================================================
/// ReductionTensorDescriptor
/// creates and manages the lifetime of a cudnn cudnnLRNDescriptor_t
public final class ReductionTensorDescriptor : ObjectTracking {
    // properties
    public let trackingId: Int
    public let desc: cudnnReduceTensorDescriptor_t

    //--------------------------------------------------------------------------
    // initializers
    @inlinable
    public init(op: ReductionOp, nan: NanPropagation, scalarType: ScalarType) throws {
        // create the descriptor
        var temp: cudnnReduceTensorDescriptor_t?
        try cudaCheck(status: cudnnCreateReduceTensorDescriptor(&temp))
        desc = temp!

        let indicesAction = (op == .min || op == .max) ?
            CUDNN_REDUCE_TENSOR_FLATTENED_INDICES : CUDNN_REDUCE_TENSOR_NO_INDICES

        // initialize
        try cudaCheck(status: cudnnSetReduceTensorDescriptor(
            desc,
            op.cudnn,
            scalarType == .real64F ? CUDNN_DATA_DOUBLE : CUDNN_DATA_FLOAT,
            nan.cudnn,
            indicesAction,
            CUDNN_32BIT_INDICES
        ))

        trackingId = ObjectTracker.global.nextId
        ObjectTracker.global.register(self)
    }

    //--------------------------------------------------------------------------
    // cleanup
    @inlinable
    deinit {
        try! cudaCheck(status: cudnnDestroyReduceTensorDescriptor(desc))
        ObjectTracker.global.remove(trackingId: trackingId)
    }
}
