import XCTest
@testable import ERStopWatch

final class ERStopWatchTests: XCTestCase {
    func testStartCutStopCallbacksProduceNonNegativeDuration() {
        let exp = XCTestExpectation(description: "receives stop callback")
        var states = [ERStopWatchState]()
        var stopSeconds: Double?

        ERStopWatchSwift.start(watchName: "unit-test") { state, _, _ in
            states.append(state)
        }

        ERStopWatchSwift.cut(watchName: "unit-test") { state, _, duration in
            states.append(state)
            XCTAssertGreaterThanOrEqual(duration, 0)
        }

        ERStopWatchSwift.stop(watchName: "unit-test") { state, _, duration in
            states.append(state)
            stopSeconds = duration
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(states.first, .start)
        XCTAssertEqual(states.last, .stop)
        XCTAssertNotNil(stopSeconds)
        XCTAssertGreaterThanOrEqual(stopSeconds ?? -1, 0)
    }

    func testPauseResumeStateFlow() {
        var states = [ERStopWatchState]()

        ERStopWatchSwift.start(watchName: "pause-resume") { state, _, _ in
            states.append(state)
        }

        ERStopWatchSwift.pause(watchName: "pause-resume") { state, _, _ in
            states.append(state)
        }

        ERStopWatchSwift.resume(watchName: "pause-resume") { state, _, _ in
            states.append(state)
        }

        ERStopWatchSwift.stop(watchName: "pause-resume") { state, _, _ in
            states.append(state)
        }

        XCTAssertEqual(states, [.start, .pause, .start, .stop])
    }
}
