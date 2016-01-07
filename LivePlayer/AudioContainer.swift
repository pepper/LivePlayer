//
//  AudioContainer.swift
//  LivePlayer
//
//  Created by YenPepper on 2015/11/4.
//  Copyright © 2015年 YenPepper. All rights reserved.
//

import Foundation
import AVFoundation

class AudioContainer: NSObject {
    enum PlayMode: Int {
        case Random, InOrder
    }
    
    let dir: NSURL!
    let mode: PlayMode!
    var avQueuePlayer: AVQueuePlayer!
    var avPlayerItems: [AVPlayerItem] = []
    
    init(dir: NSURL, playMode: PlayMode){
        self.dir = dir
        self.mode = playMode
    }
    func play() {
        let fileManager = NSFileManager.defaultManager()
        do {
            let filderString = self.dir.absoluteString
            let files = try fileManager.contentsOfDirectoryAtPath(filderString)
            for file in files {
                print(file)
                if file.lowercaseString.rangeOfString("m4a") != nil || file.lowercaseString.rangeOfString("mp3") != nil {
                    let avUrlAsset = AVURLAsset(URL: NSURL(fileURLWithPath: filderString + "/" + file))
                    let avPlayerItem = AVPlayerItem(asset: avUrlAsset)
                    avPlayerItem.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.New, context: nil)
                    self.avPlayerItems.append(avPlayerItem)
                    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("musicEnd:"), name: AVPlayerItemDidPlayToEndTimeNotification, object: avPlayerItem)
                }
            }
            self.avQueuePlayer = AVQueuePlayer(items: self.avPlayerItems)
            self.avQueuePlayer.actionAtItemEnd = AVPlayerActionAtItemEnd.None
        }
        catch let error as NSError{
            print(error.localizedDescription)
        }
    }
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath! == "status" {
            let avPlayerItem = object as! AVPlayerItem
            switch(avPlayerItem.status){
            case AVPlayerItemStatus.ReadyToPlay:
                NSLog("ReadyToPlay")
                self.avQueuePlayer.play()
            case AVPlayerItemStatus.Failed:
                NSLog("Failed")
                print(avPlayerItem.error)
            case AVPlayerItemStatus.Unknown:
                NSLog("Unknown")
            }
        }
    }
    func musicEnd(notification: NSNotification){
        let avPlayerItem = notification.object as! AVPlayerItem
        avPlayerItem.seekToTime(kCMTimeZero)
        self.avQueuePlayer.advanceToNextItem()
        self.avQueuePlayer.insertItem(avPlayerItem, afterItem: nil)
    }
    func resume(){
        self.avQueuePlayer.play()
    }
    func stop(){
        self.avQueuePlayer.pause()
    }
    deinit{
        self.avQueuePlayer.pause()
        self.avQueuePlayer.removeAllItems()
        for avPlayerItem in self.avPlayerItems {
            avPlayerItem.removeObserver(self, forKeyPath: "status")
            NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: avPlayerItem)
        }
    }
}