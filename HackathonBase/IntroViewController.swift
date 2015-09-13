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

class IntroViewController: UIViewController, FBSDKLoginButtonDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    lazy var loginButton: FBSDKLoginButton = {
        let button = FBSDKLoginButton()
        button.delegate = self
        return button
    }()

    lazy var imagePicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.delegate = self
        return picker
    }()
    
    @IBOutlet var storedPhotosButton: UIButton!
    
    @IBAction func displayStoredPhotos(sender: UIButton) {
        performSegueWithIdentifier("StoredPhotos", sender: self)
    }
    
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        
        ShareManager.sharedInstance.fetchCurrentFacebookUser() { error in
            self.pickImage()
        }
    }
    
    @IBAction func callPickImage(sender: UITapGestureRecognizer) {
        guard FBSDKAccessToken.currentAccessToken() != nil else {
            return
        }
        self.pickImage()
    }
    
    @IBAction func unwindToIntroScreen(segue: UIStoryboardSegue) {
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.setToolbarHidden(true, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func configureView() {
        view.addSubview(loginButton)
        constrain(loginButton, storedPhotosButton) { b, s in
            b.centerX == b.superview!.centerX
            b.bottom == s.top - 10
            b.width >= 200
            b.height >= 44
        }
    }
    
    private func pickImage() {
        let optionMenu = UIAlertController(title: nil, message: "Where would you like the image from?", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let photoLibraryOption = UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.Default, handler: { (alert: UIAlertAction!) -> Void in
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .PhotoLibrary
            self.imagePicker.modalPresentationStyle = .Popover
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        })
        let cameraOption = UIAlertAction(title: "Take a photo", style: UIAlertActionStyle.Default, handler: { (alert: UIAlertAction!) -> Void in
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .Camera
            self.imagePicker.modalPresentationStyle = .Popover
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
            
        })
        let cancelOption = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        })
        
        //Adding the actions to the action sheet. Camera will only show up as an option if the camera is available in the first place.
        optionMenu.addAction(photoLibraryOption)
        optionMenu.addAction(cancelOption)
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) == true {
            optionMenu.addAction(cameraOption)
        } else {
            print("Camera not available.")
        }
        self.presentViewController(optionMenu, animated: true, completion: nil)

    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.image = image
        dismissViewControllerAnimated(true) { () -> Void in
            self.performSegueWithIdentifier("BlurSegue", sender: self)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Login button delegate
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        guard error == nil else {
            print(error)
            return
        }
        ShareManager.sharedInstance.fetchCurrentFacebookUser() { error in
            self.pickImage()
        }
    }

    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
    }
    
    func loginButtonWillLogin(loginButton: FBSDKLoginButton!) -> Bool {
        return true
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "BlurSegue" {
            let vc = segue.destinationViewController as! BlurImageViewController
            vc.originalImage = self.image!
        }
    }
}

