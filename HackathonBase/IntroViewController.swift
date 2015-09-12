//
//  IntroViewController.swift
//  HackathonBase
//
//  Created by Sihao Lu on 9/10/15.
//  Copyright © 2015 Sihao Lu. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Cartography

class IntroViewController: UIViewController {
    
    lazy var loginButton: FBSDKLoginButton = {
        let button = FBSDKLoginButton()
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        let testCoverImage = UIImage(named: "test_cover")!
        let testHiddenImage = UIImage(named: "test_hidden")!
        EncryptionCore.sharedInstance.archiveBlurredImage(testCoverImage, withOriginalImage: testHiddenImage, metadata: metadataFromItems(["Bobo", "Vincent", "Yunwei"])) {
            path, error in
            print("Saving to \(path)")
            EncryptionCore.sharedInstance.unarchiveImageBundleWithPath(path!, completionBlock: { (blurredImagePath, originalImagePath, metadataPath, error) -> Void in
                do {
                    try NSFileManager.defaultManager().removeItemAtPath(blurredImagePath!)
                    try NSFileManager.defaultManager().removeItemAtPath(originalImagePath!)
                    try NSFileManager.defaultManager().removeItemAtPath(metadataPath!)
                } catch {
                    
                }
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func configureView() {
        view.addSubview(loginButton)
        constrain(loginButton) { b in
            b.centerX == b.superview!.centerX
            b.centerY == b.superview!.centerY + 150
            b.width >= 200
            b.height >= 44
        }
    }

}

