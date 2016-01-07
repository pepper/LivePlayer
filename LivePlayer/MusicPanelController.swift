//
//  MusicPanelController.swift
//  LivePlayer
//
//  Created by YenPepper on 2015/11/5.
//  Copyright © 2015年 YenPepper. All rights reserved.
//

import UIKit
import AVFoundation

class MusicPanelController: UIViewController, NeedContentControl {
    @IBOutlet weak var buttonContainer: UIScrollView?
    
    var contentControl: ContentControl!
    var titleDict = [String: String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setContentControl(contentControl: ContentControl){
        // Loading Music Button
        self.contentControl = contentControl
        let fileManager = NSFileManager.defaultManager()
        let documentsPath  = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let musicFolder = documentsPath + "/Music"
        let titleFile = musicFolder + "/title.txt"
        
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
        }
        
        let stopButton = UIButton(type: UIButtonType.System) as UIButton
        stopButton.frame = CGRectMake(100, 100, 100, 50)
        stopButton.backgroundColor = UIColor.redColor()
        stopButton.setTitle("暫停音樂", forState: UIControlState.Normal)
        stopButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        stopButton.addTarget(self, action: "stopMusic:", forControlEvents: UIControlEvents.TouchUpInside)
        self.buttonContainer!.addSubview(stopButton)
        
        let startButton = UIButton(type: UIButtonType.System) as UIButton
        startButton.frame = CGRectMake(220, 100, 100, 50)
        startButton.backgroundColor = UIColor.greenColor()
        startButton.setTitle("播放音樂", forState: UIControlState.Normal)
        startButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        startButton.addTarget(self, action: "startMusic:", forControlEvents: UIControlEvents.TouchUpInside)
        self.buttonContainer!.addSubview(startButton)
        
        do {
            let files = try fileManager.contentsOfDirectoryAtPath(musicFolder)
            var index = 2
            for file in files {
                var isDir: ObjCBool = false;
                if fileManager.fileExistsAtPath(musicFolder + "/" + file, isDirectory: &isDir) {
                    if isDir {
                        // Create Button
                        let button = UIButton(type: UIButtonType.System) as UIButton
                        button.frame = CGRectMake(CGFloat(100 + 120 * index), 100, 100, 50)
                        button.backgroundColor = UIColor(red: CGFloat(57.0/255.0), green: CGFloat(173.0/255.0), blue: CGFloat(250.0/255.0), alpha: 1)
                        button.setTitle(self.titleDict[file], forState: UIControlState.Normal)
                        button.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
                        button.addTarget(self, action: "changeMusicSet:", forControlEvents: UIControlEvents.TouchUpInside)
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
    
    func changeMusicSet(sender: UIButton!){
        let title = sender.titleLabel?.text
        let folder = (self.titleDict as NSDictionary).allKeysForObject(title as String!)[0]
        let documentsPath  = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let musicFile = documentsPath + "/Music/" + (folder as! String)
        self.contentControl.playAudio(NSURL(string: musicFile)!, playMode: AudioContainer.PlayMode.InOrder)
    }
    
    func stopMusic(sender: UIButton!){
        self.contentControl.stopMusic()
    }
    
    func startMusic(sender: UIButton!){
        self.contentControl.resumeMusic()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}