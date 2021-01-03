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

typealias ERStopWatchBlk = (ERStopWatchState,String,double_t) -> Void

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
        
        let stop = mach_absolute_time()
        guard var singleWatch = _stopWatchDictionary[watchName] else { return }
        
        singleWatch.stopStampMach = stop
        singleWatch.state = .stop
        
        var sTimebaseInfo = mach_timebase_info_data_t()
        mach_timebase_info(&sTimebaseInfo);
        
        let timeInt = singleWatch.offset + stop - singleWatch.startStampMach
        let nanos = Double(timeInt) * 1e-9 * Double(sTimebaseInfo.numer / sTimebaseInfo.denom)
        
        print("------------- \(watchName) : stop , total time \(nanos)");
        blk?(.stop,watchName,nanos)
        
    }
    
    static public func cut(watchName:String, tag:String = "", blk:ERStopWatchBlk?) {
        
        let stop = mach_absolute_time()
        guard let singleWatch = _stopWatchDictionary[watchName] else { return }
        
        var sTimebaseInfo = mach_timebase_info_data_t()
        mach_timebase_info(&sTimebaseInfo);
        
        let timeInt = singleWatch.offset + stop - singleWatch.startStampMach
        let nanos = Double(timeInt) * 1e-9 * Double(sTimebaseInfo.numer / sTimebaseInfo.denom)
        
        print("------------- \(watchName) : cut , time from start \(nanos)");
        blk?(singleWatch.state,watchName,nanos)
        
    }
    
    static public func pause(watchName:String, blk:ERStopWatchBlk?) {
        
        let stop = mach_absolute_time()
        guard var singleWatch = _stopWatchDictionary[watchName],singleWatch.state == .start else { return }
        
        var sTimebaseInfo = mach_timebase_info_data_t()
        mach_timebase_info(&sTimebaseInfo);
        
        let timeInt = singleWatch.offset + stop - singleWatch.startStampMach
        
        let nanos = Double(timeInt) * 1e-9 * Double(sTimebaseInfo.numer / sTimebaseInfo.denom)
        
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
}

private struct ERStopWatchSwiftModel {
    var startStampMach:UInt64 = 0
    var stopStampMach:UInt64 = 0
    var offset:UInt64 = 0
    var state:ERStopWatchState
}
