//
//  VideoContainer.swift
//  LivePlayer
//
//  Created by YenPepper on 2015/11/3.
//  Copyright © 2015年 YenPepper. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class VideoContainer: NSObject, RenderableContainerProtocol {
    var rendStatus: ContainerStatus
    let url: NSURL
    let renderDelegete: RenderProtocol
    var containerView: UIView!
    var wkWebView: UIWebView!
    var avPlayerItem: AVPlayerItem!
    var avPlayer: AVPlayer!
    var avPlayerLayer: AVPlayerLayer!
    
    // Initializer
    init(url: NSURL, render: RenderProtocol){
        self.rendStatus = ContainerStatus.New
        self.url = url
        self.renderDelegete = render
    }
    
    deinit{
        NSLog("VIDEO deinit")
//        self.renderDelegete.showNextContent()
    }
    
    func render(rootViewController: UIViewController) {
        self.renderDelegete.containerStartRend()
        self.rendStatus = ContainerStatus.Rend
        self.renderDelegete.stopMusic()
        
        self.containerView = UIView(frame: rootViewController.view.frame)
        let avUrlAsset = AVURLAsset(URL: NSURL(fileURLWithPath: self.url.absoluteString))
        self.avPlayerItem = AVPlayerItem(asset: avUrlAsset)
        self.avPlayerItem.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.New, context: nil)
        self.avPlayer = AVPlayer(playerItem: self.avPlayerItem)
        self.avPlayerLayer = AVPlayerLayer(player: self.avPlayer)
        
        rootViewController.view.addSubview(containerView)
        self.avPlayerLayer.frame = containerView.frame
        rootViewController.view.layer.addSublayer(self.avPlayerLayer)
        
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fillMode = kCAFillModeForwards
        animation.removedOnCompletion = false
        animation.duration = 1.0
        animation.fromValue = 0.0
        animation.toValue = 1.0
        self.avPlayerLayer.addAnimation(animation, forKey: "animateOpacity")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "videoEnd:", name: AVPlayerItemDidPlayToEndTimeNotification, object: self.avPlayerItem)
    }
    @objc func rendout() {
        NSLog("VIDEO rendout")
        self.renderDelegete.containerStartRendout()
        self.rendStatus = ContainerStatus.Rendout
        
        self.avPlayer?.pause()
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fillMode = kCAFillModeForwards
        animation.removedOnCompletion = false
        animation.duration = 1.0
        animation.fromValue = 1.0
        animation.toValue = 0.0
        self.avPlayerLayer.addAnimation(animation, forKey: "animateOpacity")
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("rendoutFinish"), userInfo: nil, repeats: false)
    }
    @objc func rendoutFinish(){
        NSLog("VIDEO rendoutFinish")
        self.containerView.hidden = true
        self.avPlayerItem.removeObserver(self, forKeyPath: "status")
        NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: self.avPlayerItem)
        self.avPlayerLayer.removeFromSuperlayer()
        self.containerView.layer.sublayers?.removeAll()
        self.containerView.removeFromSuperview()
        self.renderDelegete.containerRendoutFinish()
        self.rendStatus = ContainerStatus.End
    }
    func videoEnd(notification: NSNotification){
        self.rendout()
    }
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath! == "status" {
            switch(self.avPlayerItem.status){
            case AVPlayerItemStatus.ReadyToPlay:
                NSLog("ReadyToPlay")
                self.avPlayer.play()
                
            case AVPlayerItemStatus.Failed:
                NSLog("Failed")
                print(self.avPlayerItem.error)
            case AVPlayerItemStatus.Unknown:
                NSLog("Unknown")
            }
        }
    }
}