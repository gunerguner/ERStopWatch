//
//  ERStopWatch.swift
//  StopWatchDemo
//
//  Created by Zhicheng Zhang on 2021/1/3.
//

import Foundation

enum ERStopWatchState {
    case  start,pause,stop
}

typealias ERStopWatchBlk = (ERStopWatchState,String,Double) -> Void

struct ERStopWatchSwift {
    
    static public func start(watchName:String, blk:ERStopWatchBlk?) {
        
        if (_stopWatchDictionary[watchName] != nil) {
            _stopWatchDictionary.removeValue(forKey: watchName)
        }
        
        _stopWatchDictionary[watchName] = ERStopWatchSwiftModel.init(startStampMach:mach_absolute_time(), offset:0 , state: .start)
        
        print("------------- \(watchName) : start")
        blk?(.start,watchName,0)
        
    }
    
    static public func stop(watchName:String, blk:ERStopWatchBlk?) {
        
        guard var singleWatch = _stopWatchDictionary[watchName] else { return }
        
        let (nanos,_) = _nano(singleWatch: singleWatch)
        
        singleWatch.state = .stop
        singleWatch.nanos = nanos
        
        print("------------- \(watchName) : stop , total time \(nanos)");
        blk?(.stop,watchName,nanos)
        
    }
    
    static public func cut(watchName:String, tag:String = "", blk:ERStopWatchBlk?) {
        
        guard let singleWatch = _stopWatchDictionary[watchName] else { return }
        
        let (nanos,_) = _nano(singleWatch: singleWatch)
        
        print("------------- \(watchName) : cut , time from start \(nanos)");
        blk?(singleWatch.state,watchName,nanos)
        
    }
    
    static public func pause(watchName:String, blk:ERStopWatchBlk?) {
        
        guard var singleWatch = _stopWatchDictionary[watchName],singleWatch.state == .start else { return }
        
        let (nanos, timeInt) = _nano(singleWatch: singleWatch)

        singleWatch.offset = timeInt
        singleWatch.state = .pause
        
        print("------------- \(watchName) : pause , time from start \(nanos)");
        blk?(.pause,watchName,nanos)
        
    }
    
    static public func resume(watchName:String, blk:ERStopWatchBlk?) {
        
        let start = mach_absolute_time()
        guard var singleWatch = _stopWatchDictionary[watchName],singleWatch.state == .pause else { return }
        
        singleWatch.startStampMach = start
        singleWatch.state = .start
        
        print("------------- \(watchName) : resume  ")

    }
    
    static private var _stopWatchDictionary = [String:ERStopWatchSwiftModel]()
    
    static private func _nano(singleWatch:ERStopWatchSwiftModel) -> (Double, UInt64) {
        
        var sTimebaseInfo = mach_timebase_info_data_t()
        mach_timebase_info(&sTimebaseInfo);
        
        let timeInt = singleWatch.offset + mach_absolute_time() - singleWatch.startStampMach
        let nanos = Double(timeInt) * 1e-9 * Double(sTimebaseInfo.numer / sTimebaseInfo.denom)
        
        return (nanos, timeInt)
    }
}

private struct ERStopWatchSwiftModel {
    var startStampMach:UInt64 = 0
    var nanos:Double = 0
    var offset:UInt64 = 0
    var state:ERStopWatchState
}
