//
//  MusicPanelController.swift
//  LivePlayer
//
//  Created by YenPepper on 2015/11/5.
//  Copyright © 2015年 YenPepper. All rights reserved.
//

import UIKit
import AVFoundation

class VideoPanelController: UIViewController, NeedContentControl {
    @IBOutlet weak var buttonContainer: UIScrollView?
    
    var contentControl: ContentControl!
    var titleDict = [String: String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setContentControl(contentControl: ContentControl){
        self.contentControl = contentControl
        
        let fileManager = NSFileManager.defaultManager()
        let documentsPath  = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let videoFolder = documentsPath + "/Video"
        let titleFile = videoFolder + "/title.txt"
        
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
        
        do {
            let files = try fileManager.contentsOfDirectoryAtPath(videoFolder)
            var index = 0
            for file in files {
                if file.lowercaseString.rangeOfString("mp4") != nil {
                    // Create Button
                    let button = UIButton(type: UIButtonType.System) as UIButton
                    button.frame = CGRectMake(CGFloat(100 + 120 * index), 100, 100, 50)
                    button.backgroundColor = UIColor(red: CGFloat(57.0/255.0), green: CGFloat(173.0/255.0), blue: CGFloat(250.0/255.0), alpha: 1)
                    button.setTitle(self.titleDict[file], forState: UIControlState.Normal)
                    button.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
                    button.addTarget(self, action: "playVideo:", forControlEvents: UIControlEvents.TouchUpInside)
                    self.buttonContainer!.addSubview(button)
                    index = index + 1
                }
            }
        }
        catch let error as NSError{
            print(error.localizedDescription)
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func playVideo(sender: UIButton!){
        let title = sender.titleLabel?.text
        let folder = (self.titleDict as NSDictionary).allKeysForObject(title as String!)[0]
        let documentsPath  = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let videoFile = documentsPath + "/Video/" + (folder as! String)
        self.contentControl.pushVideo(NSURL(string: videoFile)!, pushType: ContentControl.PushType.ClearOther)
    }
}