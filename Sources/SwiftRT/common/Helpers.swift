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
import Foundation

public typealias CStringPointer = UnsafePointer<CChar>

//==============================================================================
/// elapsedTime
/// used to measure and log a set of `body` iterations
@discardableResult
public func elapsedTime(logLabel: String? = nil, iterations: Int = 10,
                        warmUps: Int = 2, precision: Int = 6,
                        _ body: () -> Void) -> TimeInterval
{
    // warm ups are to factor out module or data load times
    if let label = logLabel, warmUps > 0 {
        var warmUpTimings = [TimeInterval]()
        for _ in 0..<warmUps {
            let start = Date()
            body()
            let elapsed = Date().timeIntervalSince(start)
            warmUpTimings.append(elapsed)
        }

        let warmUpAverage = warmUpTimings.reduce(0, +) /
            Double(warmUpTimings.count)
        
        logTimings("\(label) average start up", warmUpTimings,
                   warmUpAverage, precision)
    }
    
    // collect the timings and take the average
    var timings = [TimeInterval]()
    for _ in 0..<iterations {
        let start = Date()
        body()
        let elapsed = Date().timeIntervalSince(start)
        timings.append(elapsed)
    }
    let average = timings.reduce(0, +) / Double(timings.count)

    // log results if requested
    if let label = logLabel {
        logTimings("\(label) average iteration", timings, average, precision)
    }
    return average
}

func logTimings(_ label: String, _ timings: [TimeInterval],
                _ average: TimeInterval, _ precision: Int)
{
    let avgStr = String(timeInterval: average, precision: precision)
    Platform.log.write(level: .status, message:
        "\(label) time: \(avgStr)")
    for i in 0..<timings.count {
        let timeStr = String(format: "%.\(precision)f", timings[i])
        Platform.log.write(level: .status,
                           message: "Run: \(i) time: \(timeStr)")
    }
    Platform.log.write(level: .status, message: "")
}

//==============================================================================
// Memory sizes
extension Int {
    @inlinable
    var KB: Int { self * 1024 }
    @inlinable
    var MB: Int { self * 1024 * 1024 }
    @inlinable
    var GB: Int { self * 1024 * 1024 * 1024 }
    @inlinable
    var TB: Int { self * 1024 * 1024 * 1024 * 1024 }
}

//==============================================================================
// String(timeInterval:
extension String {
    @inlinable
    public init(timeInterval: TimeInterval, precision: Int = 2) {
        let remainder = timeInterval.truncatingRemainder(dividingBy: 1.0)
        let interval = Int(timeInterval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        let remStr = String(format: "%.\(precision)f", remainder).dropFirst(2)
        self = String(format: "%0.2d:%0.2d:%0.2d.\(remStr)",
                      hours, minutes, seconds)
    }
}

//==============================================================================
// AtomicCounter
public final class AtomicCounter {
    // properties
    @usableFromInline var counter: Int
    @usableFromInline let mutex = Mutex()
    
    @inlinable
    public var value: Int {
        get { mutex.sync { counter } }
        set { mutex.sync { counter = newValue } }
    }
    
    // initializers
    @inlinable
    public init(value: Int = 0) {
        counter = value
    }
    
    // functions
    @inlinable
    public func increment() -> Int {
        return mutex.sync {
            counter += 1
            return counter
        }
    }
}

//==============================================================================
/// Mutex
/// is this better named "critical section"
/// TODO: verify using a DispatchQueue is faster than a counting semaphore
/// TODO: rethink this and see if async(flags: .barrier makes sense using a
/// concurrent queue
public final class Mutex {
    // properties
    @usableFromInline
    let queue: DispatchQueue
    
    @inlinable
    public init() {
        queue = DispatchQueue(label: "Mutex")
    }
    
    // functions
    @inlinable
    func sync<R>(execute work: () throws -> R) rethrows -> R {
        try queue.sync(execute: work)
    }
}
