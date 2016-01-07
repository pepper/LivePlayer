//
//  ViewController.swift
//  LivePlayer
//
//  Created by YenPepper on 2015/10/30.
//  Copyright © 2015年 YenPepper. All rights reserved.
//

import UIKit
import AVFoundation

protocol NeedContentControl{
    func setContentControl(contentControl: ContentControl)
}

class ViewController: UIViewController {
    
    @IBOutlet weak var buttonContainer: UIScrollView?
    
    var renderContentQueue = []
    
    
    var externalWindow: UIWindow!
    //    var externalImageView: UIImageView!
    var contentControl: ContentControl!
    var avPlayerItem: AVPlayerItem!
    var avPlayer: AVPlayer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: "handleScreenDidConnectNotification:", name: UIScreenDidConnectNotification, object: nil)
        center.addObserver(self, selector: "handleScreenDidDisconnectNotification:", name: UIScreenDidDisconnectNotification, object: nil)
        
        let screens = UIScreen.screens()
        NSLog("screens.count:%d", screens.count)
        if screens.count > 1 {
            self.initializeExternalScreen(screens[1] as UIScreen)
        }
        else{
            self.initializeExternalScreen(screens[0] as UIScreen)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initializeExternalScreen(externalScreen: UIScreen){
        self.externalWindow = UIWindow(frame: CGRect(x: externalScreen.bounds.width / 2, y: externalScreen.bounds.height / 2, width: externalScreen.bounds.width / 2, height: externalScreen.bounds.height / 2))
        self.externalWindow.backgroundColor = UIColor.blackColor()
        self.externalWindow.screen = externalScreen
        let viewController = UIViewController()
        self.externalWindow.rootViewController = viewController
        
        let pan = UIPanGestureRecognizer(target: self, action: Selector("handlePan:"))
        self.externalWindow.addGestureRecognizer(pan)
        let pinch = UIPinchGestureRecognizer(target: self, action: Selector("handlePinch:"))
        self.externalWindow.addGestureRecognizer(pinch)
        
        // Load background image
        let documentsPath  = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let backgroundFilePath = documentsPath.stringByAppendingString("/Background/1.png")
        let data = NSData(contentsOfFile: backgroundFilePath)
        
//        self.contentControl = ContentControl(container: self)
        self.contentControl = ContentControl(container: viewController, backgroundImage: UIImage(data: data!)!)
        
        for child in self.childViewControllers {
            let childControl = child as! NeedContentControl
            childControl.setContentControl(self.contentControl)
        }
        self.externalWindow.makeKeyAndVisible()
        
        self.contentControl.backgroundMode()
        
//        let imageUrlList = [
//            "https://farm7.staticflickr.com/6234/6218788343_4d4822c22d_b.jpg",
//            "https://farm8.staticflickr.com/7218/7092839051_e5bfc75e8f_b.jpg",
//            "https://farm9.staticflickr.com/8068/8227681399_76e6a57797_b.jpg",
//            "https://farm6.staticflickr.com/5563/13472097014_8d497b661c_b.jpg",
//            "https://farm3.staticflickr.com/2752/5825099471_600bfa8c51_b.jpg"
//        ]
//        self.externalWindow.makeKeyAndVisible()
//        var imageList:[UIImage] = []
//        for imageUrl in imageUrlList{
//            NSLog("Fetching image: %s", imageUrl)
//            let url = NSURL(string: imageUrl)
//            let data = NSData(contentsOfURL: url!)
//            imageList.append(UIImage(data: data!)!)
//        }
//        for image in imageList{
//            self.contentControl.pushImage(image, pushType: ContentControl.PushType.AtLast)
//        }
//
//        let documentsPath  = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
//        let videoFile = documentsPath.stringByAppendingString("/Video/1.mp4")
//        let videoURL = NSURL(string: videoFile)
//        self.contentControl.pushVideo(videoURL!, pushType: ContentControl.PushType.AtLast)
        
//        for image in imageList{
//            self.contentControl.pushImage(image, pushType: ContentControl.PushType.AtLast)
//        }
        
//        let musicFile = documentsPath.stringByAppendingString("/Music")
//        self.contentControl.playAudio(NSURL(string: musicFile)!, playMode: AudioContainer.PlayMode.InOrder)
    }
    
    
    
    func handleScreenDidConnectNotification(notification: NSNotification){
        if let screen = notification.object as? UIScreen{
            self.initializeExternalScreen(screen)
        }
    }
    
    func handleScreenDidDisconnectNotification(notification: NSNotification){
        if self.externalWindow != nil {
            self.externalWindow.hidden = true
            self.externalWindow = nil
        }
    }
    
    func handlePan(recognizer: UIPanGestureRecognizer){
        let translation = recognizer.translationInView(self.externalWindow)
        recognizer.view!.center = CGPointMake(recognizer.view!.center.x + translation.x, recognizer.view!.center.y + translation.y)
        recognizer.setTranslation(CGPointMake(0, 0), inView: self.externalWindow)
    }
    
    func handlePinch(recognizer: UIPinchGestureRecognizer){
        if (recognizer.state == UIGestureRecognizerState.Began || recognizer.state == UIGestureRecognizerState.Changed){
            recognizer.view?.transform = CGAffineTransformScale((recognizer.view?.transform)!, recognizer.scale, recognizer.scale)
            recognizer.scale = 1
        }
    }
//    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
//         NSLog("HAHAHA")
//        if keyPath! == "status" {
//            switch(self.avPlayerItem.status){
//            case AVPlayerItemStatus.ReadyToPlay:
//                NSLog("ReadyToPlay")
//                self.avPlayer.play()
//            case AVPlayerItemStatus.Failed:
//                NSLog("Failed")
//                print(self.avPlayerItem.error)
//            case AVPlayerItemStatus.Unknown:
//                NSLog("Unknown")
//            }
//        }
//    }
}

