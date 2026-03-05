import Foundation

public enum ERStopWatchState {
    case start, pause, stop
}

public typealias ERStopWatchBlk = (ERStopWatchState, String, Double) -> Void

public struct ERStopWatchSwift {
    static public func start(watchName: String, blk: ERStopWatchBlk?) {
        withLock {
            watches[watchName] = Watch(startTick: tick(), offset: 0, state: .start)
            print("------------- \(watchName) : start")
            blk?(.start, watchName, 0)
        }
    }

    static public func stop(watchName: String, blk: ERStopWatchBlk?) {
        withLock {
            guard var watch = watches[watchName] else { return }
            let (seconds, _) = elapsed(for: watch)

            watch.state = .stop
            watch.seconds = seconds
            watches[watchName] = watch

            print("------------- \(watchName) : stop , total time \(seconds)")
            blk?(.stop, watchName, seconds)
        }
    }

    static public func cut(watchName: String, tag: String = "", blk: ERStopWatchBlk?) {
        withLock {
            guard let watch = watches[watchName] else { return }
            let (seconds, _) = elapsed(for: watch)

            print("------------- \(watchName) : cut \(tag.isEmpty ? "" : "[\(tag)]") , time from start \(seconds)")
            blk?(watch.state, watchName, seconds)
        }
    }

    static public func pause(watchName: String, blk: ERStopWatchBlk?) {
        withLock {
            guard var watch = watches[watchName], watch.state == .start else { return }
            let (seconds, ticks) = elapsed(for: watch)

            watch.offset = ticks
            watch.state = .pause
            watches[watchName] = watch

            print("------------- \(watchName) : pause , time from start \(seconds)")
            blk?(.pause, watchName, seconds)
        }
    }

    static public func resume(watchName: String, blk: ERStopWatchBlk?) {
        withLock {
            guard var watch = watches[watchName], watch.state == .pause else { return }

            watch.startTick = tick()
            watch.state = .start
            watches[watchName] = watch

            print("------------- \(watchName) : resume")
            blk?(.start, watchName, 0)
        }
    }

    static private var watches = [String: Watch]()
    static private let lock = NSLock()

    static private func withLock(_ work: () -> Void) {
        lock.lock()
        defer { lock.unlock() }
        work()
    }

    static private func tick() -> UInt64 {
        DispatchTime.now().uptimeNanoseconds
    }

    static private func elapsed(for watch: Watch) -> (Double, UInt64) {
        let ticks = watch.offset + tick() - watch.startTick
        return (Double(ticks) * 1e-9, ticks)
    }
}

private struct Watch {
    var startTick: UInt64 = 0
    var seconds: Double = 0
    var offset: UInt64 = 0
    var state: ERStopWatchState
}
