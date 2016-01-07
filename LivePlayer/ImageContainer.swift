//
//  ImageContainer.swift
//  LivePlayer
//
//  Created by YenPepper on 2015/11/3.
//  Copyright © 2015年 YenPepper. All rights reserved.
//

import Foundation
import UIKit

class ImageContainer: RenderableContainerProtocol {
    // Instance property
    var rendStatus: ContainerStatus
    let image: UIImage
    let time: Double
    let renderDelegete: RenderProtocol
    var imageView: UIImageView!
    var renderEndTimer: NSTimer!
    
    // Initializer
    init(image: UIImage, time: Double, render: RenderProtocol){
        self.rendStatus = ContainerStatus.New
        self.image = image
        self.time = time
        self.renderDelegete = render
    }
    convenience init(image: UIImage, render: RenderProtocol){
        self.init(image: image, time: 3, render: render)
    }
    deinit{
//        self.renderDelegete.showNextContent()
    }
    func render(rootViewController: UIViewController){
        print("Render image")
        self.renderDelegete.containerStartRend()
        self.rendStatus = ContainerStatus.Rend
        self.imageView = UIImageView(frame: rootViewController.view.frame)
        self.imageView.image = self.image
        self.imageView.contentMode = UIViewContentMode.ScaleAspectFit
        self.imageView.alpha = 0.0
        rootViewController.view.addSubview(self.imageView)
        UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.imageView.alpha = 1.0
        }, completion: nil)
        if self.time > 0 {
            self.renderEndTimer = NSTimer.scheduledTimerWithTimeInterval(self.time, target: self, selector: Selector("timeout"), userInfo: nil, repeats: false)
        }
    }
    func rendout(){
        print("Rendout image")
        if self.renderEndTimer != nil {
            self.renderEndTimer.invalidate()
            self.renderEndTimer = nil
        }
        self.renderDelegete.containerStartRendout()
        self.rendStatus = ContainerStatus.Rendout
        UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.imageView.alpha = 0.0
            }, completion: {
                (value: Bool) in
                self.imageView.hidden = true
                self.imageView.removeFromSuperview()
                self.renderDelegete.containerRendoutFinish()
                self.rendStatus = ContainerStatus.End
        })
    }
    @objc func timeout(){
        self.rendout()
    }
}