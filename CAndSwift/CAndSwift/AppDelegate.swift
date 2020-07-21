//
//  AppDelegate.swift
//  CAndSwift
//
//  Created by Kven on 7/18/20.
//  Copyright © 2020 Kven. All rights reserved.
//

import Cocoa
import ffmpeg

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var artView: NSImageView!
    
    override init() {
    
        super.init()
        freopen("/Volumes/MyData/Music/CAndSwift.log", "a+", stderr)
    }
    
//    private let player = Player()
//    private var scheduler: Scheduler!
//    private var slowScheduler: SlowScheduler!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
//        scheduler = Scheduler(player)
//        slowScheduler = SlowScheduler(player)
        
//        let url = URL(fileURLWithPath: "/Users/kven/Music/Aural-Test/0Rednex.ogg")
        let url = URL(fileURLWithPath: "/Users/kven/Music/Aural-Test/D1.dsf")
//        let url = URL(fileURLWithPath: "/Users/kven/Music/Aural-Test/03.mpc")
        
        Decoder.decodeAndPlay(url)
       
//        scheduler.playTrack(url)
//        slowScheduler.playTrack(url)
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
//
//            self.scheduler.seekToTime(url, 268, true)
//        })
        
//        print("Took \(time * 1000) msec")
        
//        var trackInfo: TrackInfo!
//
//        let time = measureTime {
//            trackInfo = Reader.readTrack(url)
//        }
//
//        print(JSONMapper.map(trackInfo))
//        artView.image = trackInfo.art
    }
}

func measureTime(_ task: () -> Void) -> Double {
    
    let startTime = CFAbsoluteTimeGetCurrent()
    task()
    return CFAbsoluteTimeGetCurrent() - startTime
}
