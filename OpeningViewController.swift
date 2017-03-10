//
//  OpeningViewController.swift
//  CMBExersizeChadW
//
//  Created by Chad Wiedemann on 3/4/17.
//  Copyright © 2017 Chad Wiedemann LLC. All rights reserved.
//

import UIKit
import QuartzCore

class OpeningViewController: UIViewController {

    var currentEmployeeID = 0
    let dao = DAO.sharedInstance
    var openingView = true
    
    //view controller lifecyle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(self.loadImages), name: NSNotification.Name(rawValue: "finishedDownload"), object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        if dao.haveData{
            loadImages()
        }
    }
    
    //used to display UIAlert to instruct the user on how to use the app
    override func viewDidAppear(_ animated: Bool) {
        if self.openingView == true {
        let alert = UIAlertController.init(title: "Coffee Meets Bagel Team", message: "swipe left to view the team members.", preferredStyle: UIAlertControllerStyle.alert)
        let alertAction = UIAlertAction.init(title: "Okay", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(alertAction)
        self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //called to populate the UI after all the data is downloaded
    func loadImages(){
        let swipeLeft = UISwipeGestureRecognizer.init(target: self, action: #selector(OpeningViewController.swipeLeft))
        let swipeRight = UISwipeGestureRecognizer.init(target: self, action: #selector(OpeningViewController.swipeRight))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
        self.view.addGestureRecognizer(swipeRight)
        let personDictionary = self.dao.employeeObjectArray[self.currentEmployeeID]
        let firstName = personDictionary.value(forKey: "firstName") as! String
        let lastName = personDictionary.value(forKey: "lastName") as! String
        addNameView(name: "\(firstName) \(lastName)")
    }
    
    //adds the name view to the window
    func addNameView(name: String) {
        let nameLabel = UILabel.init()
        view.addSubview(nameLabel)
        nameLabel.text = name
        self.view.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstraint = NSLayoutConstraint(item: nameLabel, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
        let verticalConstraint = NSLayoutConstraint(item: nameLabel, attribute: NSLayoutAttribute.topMargin, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.topMargin, multiplier: 1, constant: 50)
        view.addConstraints([horizontalConstraint, verticalConstraint])
        addAvatarView(labelView: nameLabel)
    }
    
    //adds the avatar image to the window
    func addAvatarView(labelView: UIView){
        let imageViewForAvater = UIImageView.init(image: self.getImage())
        self.view.addSubview(imageViewForAvater)
        imageViewForAvater.translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstraint = NSLayoutConstraint(item: imageViewForAvater, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
        let verticalConstraint = NSLayoutConstraint(item: imageViewForAvater, attribute: NSLayoutAttribute.topMargin, relatedBy: NSLayoutRelation.equal, toItem:labelView , attribute: NSLayoutAttribute.bottomMargin, multiplier: 1, constant: 25)
        let widthConstraint = NSLayoutConstraint(item: imageViewForAvater, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 300)
        let heightConstraint = NSLayoutConstraint(item: imageViewForAvater, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 300)
        view.addConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
        addTitleLabel(avaterView: imageViewForAvater)
    }
    
    //adds the employees' title below their Avatar
    func addTitleLabel(avaterView: UIView) {
        let personDictionary = self.dao.employeeObjectArray[self.currentEmployeeID]
        let title = personDictionary.value(forKey: "title") as! String
        let titleLabel = UILabel.init()
        titleLabel.text = title
        self.view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstraint = NSLayoutConstraint(item: titleLabel, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
        let verticalConstraint = NSLayoutConstraint(item: titleLabel, attribute: NSLayoutAttribute.topMargin, relatedBy: NSLayoutRelation.equal, toItem: avaterView, attribute: NSLayoutAttribute.bottomMargin, multiplier: 1, constant: 25)
        view.addConstraints([horizontalConstraint, verticalConstraint])
        addBioText(titleLabel: titleLabel)
    }
    
    //adds the bio string that was downloaded from FullContact Person API to a UITextView
    func addBioText(titleLabel: UIView) {
        let personDictionary = self.dao.employeeObjectArray[self.currentEmployeeID]
        let bio = personDictionary.value(forKey: "bio") as! String
        let bioTextField = UITextView.init()
        bioTextField.isEditable = false
        bioTextField.text = bio
        self.view.addSubview(bioTextField)
        bioTextField.translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstraint = NSLayoutConstraint(item: bioTextField, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
        let verticalConstraint = NSLayoutConstraint(item: bioTextField, attribute: NSLayoutAttribute.topMargin, relatedBy: NSLayoutRelation.equal, toItem:titleLabel , attribute: NSLayoutAttribute.bottomMargin, multiplier: 1, constant: 25)
        let widthConstraint = NSLayoutConstraint(item: bioTextField, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 300)
        let heightConstraint = NSLayoutConstraint(item: bioTextField, attribute: NSLayoutAttribute.bottomMargin, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.bottomMargin, multiplier: 1, constant: 0)
        view.addConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
    }
    
    //called to transition to view controller after the user swipes left
    func swipeLeft()  {
        print("swiped left")
        if self.currentEmployeeID != 19 {
        let viewController = OpeningViewController.init()
            viewController.currentEmployeeID = self.currentEmployeeID + 1
            viewController.modalTransitionStyle = .flipHorizontal
            viewController.openingView = false
            self.present(viewController, animated: true, completion: {viewController.loadImages()})
        }
    }
    
    //called to transition to view controller after the user swipes right
    func swipeRight(){
        print("swiped right")
        if self.currentEmployeeID != 0 {
            let viewController = OpeningViewController.init()
            viewController.currentEmployeeID = self.currentEmployeeID - 1
            viewController.modalTransitionStyle = .crossDissolve
            viewController.openingView = false
            self.present(viewController, animated: true, completion: nil)
        }
    }
    
    //returns the employees' avatar image from the file directory
    func getImage()-> UIImage{
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let currentEmployeeFile = "/\(self.currentEmployeeID)"
        let filePath = documentsDirectory.appending(currentEmployeeFile)
        let url = URL.init(fileURLWithPath: filePath)
        let data = try? Data.init(contentsOf: url)
        return UIImage.init(data: data!)!
    }

}
