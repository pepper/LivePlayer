//
//  ContentControl.swift
//  LivePlayer
//
//  Created by YenPepper on 2015/11/3.
//  Copyright © 2015年 YenPepper. All rights reserved.
//

import Foundation
import UIKit

protocol RenderableContainerProtocol{
//    var type: String{
//        get
//    }
    var rendStatus: ContainerStatus{
        get
    }
    func render(rootView: UIViewController)
    func rendout()
}

protocol RenderProtocol{
    func containerStartRend()
    func containerStartRendout()
    func containerRendoutFinish()
    func showNextContent()
    func stopMusic()
}

protocol ContentControlEventDelegate{
//    func containerStart(obj: RenderableContainerProtocol)
//    func containerEnd(obj: RenderableContainerProtocol)
//    func containerCancel(obj: RenderableContainerProtocol)
    func queueEmpty()
//    func queueCountChange(count: Int)
}

enum ContainerStatus: Int{
    case New, Rend, Rendout, End
}

class ContentControl: RenderProtocol {
    enum PushType: Int {
        case AtLast, AfterNow, Interrupt, ClearOther
    }
    
    
    let rootViewController:UIViewController
    var renderQueue: [RenderableContainerProtocol] = []
    var rendoutQueue: [RenderableContainerProtocol] = []
    var playingAudioContainer: AudioContainer!
    var backgroundImage: UIImage
    var inBackgroundMode = false
    var eventDelegate: [ContentControlEventDelegate] = []
    
    init(container: UIViewController, backgroundImage: UIImage){
        self.rootViewController = container
        self.backgroundImage = backgroundImage
    }
    
    func registerEventDelegate(eventDelegate: ContentControlEventDelegate){
        self.eventDelegate.append(eventDelegate)
    }
    
    func containerStartRend(){
        NSLog("containerStartRend")
    }
//    func containerRendFinish(){
//        NSLog("containerRendFinish")
//    }
    func containerStartRendout(){
        NSLog("containerStartRendout")
        self.rendoutQueue.insert(self.renderQueue.popLast()!, atIndex: 0)
    }
    func containerRendoutFinish(){
        NSLog("containerRenoutFinish")
        self.rendoutQueue.popLast()
        self.showNextContent()
    }
    func showNextContent(){
        NSLog("showNextContent")
        print(self.renderQueue.count)
        print(self.rendoutQueue.count)
        if(self.renderQueue.count > 0){
            self.renderQueue.last?.render(self.rootViewController)
        }
        else{
            // Push to background
            self.backgroundMode()
            self.eventDelegate.first?.queueEmpty()
        }
    }
    func pushContainer(container: RenderableContainerProtocol, pushType: PushType){
        switch(pushType){
        case PushType.AtLast:
            self.renderQueue.insert(container, atIndex: 0)
        case PushType.AfterNow:
            var index = 0
            if self.renderQueue.count > 0{
                index = self.renderQueue.count - 1
            }
            self.renderQueue.insert(container, atIndex: index)
        case PushType.Interrupt:
            if self.rendoutQueue.count == 0 {
                self.renderQueue.last?.rendout()
            }
            self.renderQueue.append(container)
        case PushType.ClearOther:
            if self.rendoutQueue.count == 0 {
                self.renderQueue.last?.rendout()
            }
            self.renderQueue = [container]
        }
        if self.rendoutQueue.count == 0 && self.renderQueue.count == 1 {
            self.showNextContent()
        }
    }
    
    func resumeMusic(){
        self.playingAudioContainer?.resume()
    }
    func stopMusic(){
        self.playingAudioContainer?.stop()
    }
    
    func pushImage(image: UIImage, pushType: PushType){
        self.exitBackgroundMode()
        let newImageContainer = ImageContainer(image: image, time: 8, render: self)
        self.pushContainer(newImageContainer, pushType: pushType)
    }
    func pushVideo(videoUrl: NSURL, pushType: PushType){
        self.exitBackgroundMode()
        let newVideoContainer = VideoContainer(url: videoUrl, render: self)
        self.pushContainer(newVideoContainer, pushType: pushType)
    }
    func playAudio(musicDir: NSURL, playMode: AudioContainer.PlayMode){
        self.playingAudioContainer = AudioContainer(dir: musicDir, playMode: playMode)
        self.playingAudioContainer.play()
    }
    
    func setBackgroundImage(image: UIImage){
        self.backgroundImage = image
    }
    func backgroundMode(){
        let newImageContainer = ImageContainer(image: self.backgroundImage, time: 0, render: self)
        self.pushContainer(newImageContainer, pushType: ContentControl.PushType.ClearOther)
        self.inBackgroundMode = true
    }
    func exitBackgroundMode(){
        if self.inBackgroundMode{
            self.renderQueue.last?.rendout()
            self.inBackgroundMode = false
        }
    }
}