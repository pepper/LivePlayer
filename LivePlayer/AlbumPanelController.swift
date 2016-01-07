//
//  AlbumPanelController.swift
//  LivePlayer
//
//  Created by YenPepper on 2015/11/5.
//  Copyright © 2015年 YenPepper. All rights reserved.
//

import Foundation
import UIKit

class AlbumPanelController: UIViewController, NeedContentControl, ContentControlEventDelegate {
    @IBOutlet weak var buttonContainer: UIScrollView?
    
    var contentControl: ContentControl!
    var titleDict = [String: String]()
    var enableAlbumDict = [String: Bool]()
    var play = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setContentControl(contentControl: ContentControl){
        // Loading Music Button
        self.contentControl = contentControl
        self.contentControl.registerEventDelegate(self)
        
        let fileManager = NSFileManager.defaultManager()
        let documentsPath  = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let albumFolder = documentsPath + "/Album"
        let titleFile = albumFolder + "/title.txt"
        
        var contents = ""
        do {
            contents = try NSString(contentsOfFile: titleFile, encoding: NSUTF8StringEncoding) as String
        }
        catch{
            print("Read title file error")
        }
        let titles = contents.componentsSeparatedByString("\n")
        for title in titles {
            print(title)
            let pair = title.componentsSeparatedByString(":")
            print(pair[0])
            print(pair[1])
            self.titleDict[pair[0]] = pair[1]
            self.enableAlbumDict[pair[0]] = false
        }
        
        let stopButton = UIButton(type: UIButtonType.System) as UIButton
        stopButton.frame = CGRectMake(100, 100, 100, 50)
        stopButton.backgroundColor = UIColor.redColor()
        stopButton.setTitle("暫停相簿", forState: UIControlState.Normal)
        stopButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        stopButton.addTarget(self, action: "stopAlbum:", forControlEvents: UIControlEvents.TouchUpInside)
        self.buttonContainer!.addSubview(stopButton)
        
        let startButton = UIButton(type: UIButtonType.System) as UIButton
        startButton.frame = CGRectMake(220, 100, 100, 50)
        startButton.backgroundColor = UIColor.greenColor()
        startButton.setTitle("播放相簿", forState: UIControlState.Normal)
        startButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        startButton.addTarget(self, action: "starAlbum:", forControlEvents: UIControlEvents.TouchUpInside)
        self.buttonContainer!.addSubview(startButton)
        
        do {
            let files = try fileManager.contentsOfDirectoryAtPath(albumFolder)
            var index = 2
            for file in files {
                var isDir: ObjCBool = false;
                if fileManager.fileExistsAtPath(albumFolder + "/" + file, isDirectory: &isDir) {
                    if isDir {
                        // Create Button
                        let button = UIButton(type: UIButtonType.System) as UIButton
                        button.frame = CGRectMake(CGFloat(100 + 120 * index), 100, 100, 50)
                        button.backgroundColor = UIColor.grayColor()
                        button.setTitle(self.titleDict[file], forState: UIControlState.Normal)
                        button.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
                        button.addTarget(self, action: "enableAlbum:", forControlEvents: UIControlEvents.TouchUpInside)
                        self.buttonContainer!.addSubview(button)
                        index = index + 1
                    }
                }
            }
        }
        catch let error as NSError{
            print(error.localizedDescription)
        }
    }
    
    func enableAlbum(sender: UIButton!){
        let title = sender.titleLabel?.text
        let key = (self.titleDict as NSDictionary).allKeysForObject(title as String!)[0]
        if self.enableAlbumDict[key as! String] == true {
            self.enableAlbumDict[key as! String] = false
            sender.backgroundColor = UIColor.grayColor()
        }
        else{
             self.enableAlbumDict[key as! String] = true
            sender.backgroundColor = UIColor.greenColor()
        }
//        let documentsPath  = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
//        let musicFile = documentsPath + "/Music/" + (folder as! String)
//        self.contentControl.playAudio(NSURL(string: musicFile)!, playMode: AudioContainer.PlayMode.InOrder)
    }
    
    func stopAlbum(sender: UIButton!){
        self.play = false
        self.contentControl.backgroundMode()
    }
    
    func starAlbum(sender: UIButton!){
        self.play = true
        let fileManager = NSFileManager.defaultManager()
        let documentsPath  = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let albumFolder = documentsPath + "/Album"
        var fileList:[String] = []
        for enable in self.enableAlbumDict {
            if enable.1 {
                let folderPath = albumFolder + "/" + enable.0
                do{
                    let files = try fileManager.contentsOfDirectoryAtPath(folderPath)
                    for file in files {
                        if file.lowercaseString.rangeOfString("jpg") != nil || file.lowercaseString.rangeOfString("jpeg") != nil {
                            fileList.append(folderPath + "/" + file)
                            print(file)
                        }
                    }
                }
                catch{
                    print("Read album error")
                }
            }
        }
        
        print("random")
        var i = 0
        while i < 30 {
            let index = Int(arc4random_uniform(UInt32(fileList.count)))
            print(fileList[index])
            let data = NSData(contentsOfFile: fileList[index])
            print(data?.length)
            self.contentControl.pushImage(UIImage(data: data!)!, pushType: ContentControl.PushType.AtLast)
            i++
        }
    }
    
    func queueEmpty(){
        if self.play {
            self.starAlbum(UIButton())
        }
//        self.starAlbum()
    }
}