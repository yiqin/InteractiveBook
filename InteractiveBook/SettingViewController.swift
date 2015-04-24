//
//  SettingViewController.swift
//  InteractiveBook
//
//  Created by yiqin on 4/10/15.
//  Copyright (c) 2015 Yi Qin. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController, UICollisionBehaviorDelegate {

    var backButton:UIButton
    var segmentedControl: UISegmentedControl
    
    var parentalGate: UIView
    
    var cancelButtonOnParentalGate:UIButton
    
    
    var animator: UIDynamicAnimator!
    var gravity: UIGravityBehavior!
    var collision: UICollisionBehavior!
    
    
    var answerIndex:Int = 0
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        
        backButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        segmentedControl = UISegmentedControl (items: ["Automatically play","Tap to play"])
        
        cancelButtonOnParentalGate = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        
        parentalGate = UIView()
        parentalGate.backgroundColor = UIColor.whiteColor()
        parentalGate.alpha = 1.0
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        view.backgroundColor = UIColor.whiteColor()
        
        backButton.frame = CGRectMake(10, 10, 80, 30)
        backButton.autoresizingMask = UIViewAutoresizing.FlexibleRightMargin | UIViewAutoresizing.FlexibleBottomMargin
        backButton.setTitle("Back", forState: UIControlState.Normal)
        // backButton.backgroundColor = UIColor.blackColor()
        // backButton.setTitleColor(UIColor(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 240.0/255.0), forState: UIControlState.Normal)
        backButton.layer.cornerRadius = CGFloat(5.0)
        backButton.addTarget(self, action: "backButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(backButton)
        
        
        parentalGate.frame = CGRectMake(0,0,CGRectGetWidth(view.frame),CGRectGetHeight(view.frame))
        view.addSubview(parentalGate)
        
        
        cancelButtonOnParentalGate.frame = CGRectMake(10, 10, 80, 30)
        cancelButtonOnParentalGate.autoresizingMask = UIViewAutoresizing.FlexibleRightMargin | UIViewAutoresizing.FlexibleBottomMargin
        cancelButtonOnParentalGate.setTitle("Cancel", forState: UIControlState.Normal)
        cancelButtonOnParentalGate.backgroundColor = UIColor(red: 64.0/255.0, green: 64.0/255.0, blue: 64.0/255.0, alpha: 1.0)
        cancelButtonOnParentalGate.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        cancelButtonOnParentalGate.layer.cornerRadius = CGFloat(5.0)
        cancelButtonOnParentalGate.addTarget(self, action: "backButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        parentalGate.addSubview(cancelButtonOnParentalGate)
        
        
        
        
    }
    
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        segmentedControl.frame = CGRectMake(60, 250,400, 44)
        

        
        segmentedControl.addTarget(self, action: "segmentedControlAction:", forControlEvents: .ValueChanged)
        self.view.addSubview(segmentedControl)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if SettingDataManager.sharedInstance.getAutoPlay() {
            segmentedControl.selectedSegmentIndex = 0
        }
        else {
            segmentedControl.selectedSegmentIndex = 1
        }
        
        openParentalGate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    
    func openParentalGate() {
        
        let informationLabel = UILabel(frame: CGRectMake(0, 100, CGRectGetWidth(view.frame), 100))
        informationLabel.text = "Are you an adult?"
        informationLabel.font = UIFont.boldSystemFontOfSize(30.0)
        informationLabel.textAlignment = NSTextAlignment.Center
        parentalGate.addSubview(informationLabel)
        
        generateQuestion()
        
        
        let informationLabel2 = UILabel(frame: CGRectMake(0, 200, CGRectGetWidth(view.frame), 100))
        let schoolName = getQuestionString()
        informationLabel2.text = "Which is \(schoolName)? Please select the right one."
        informationLabel2.font = UIFont.boldSystemFontOfSize(30.0)
        informationLabel2.textAlignment = NSTextAlignment.Center
        parentalGate.addSubview(informationLabel2)
        
        var squares:[UIView] = []
        for index in 0...5 {
            let diceRoll = Int(arc4random_uniform(7))*10
            
            let square = UIView(frame: CGRect(x: 125+diceRoll, y: 100+diceRoll, width: 100, height: 100))
            let hackprincetonImage = UIImage(named: "\(index).png")
            let hackprincetonImageView = UIImageView(image: hackprincetonImage)
            hackprincetonImageView.frame = CGRectMake(0, 0, 100, 100)
            hackprincetonImageView.contentMode = UIViewContentMode.ScaleAspectFill
            square.addSubview(hackprincetonImageView)
            // square.backgroundColor = UIColor.grayColor()
            parentalGate.addSubview(square)
            
            square.tag = index
            square.userInteractionEnabled = true
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "buttonTapped:")
            square.addGestureRecognizer(tapGestureRecognizer)
            
            squares += [square]
        }
        
        let barrier = UIView(frame: CGRect(x: 0, y: 630, width: 130, height: 20))
        barrier.backgroundColor = UIColor.clearColor()
        parentalGate.addSubview(barrier)
        
        
        animator = UIDynamicAnimator(referenceView: view)
        gravity = UIGravityBehavior(items: squares)
        animator.addBehavior(gravity)
        
        
        // collision = UICollisionBehavior(items: [square, barrier])
        collision = UICollisionBehavior(items: squares)
        collision.collisionDelegate = self
        // add a boundary that has the same frame as the barrier
        collision.addBoundaryWithIdentifier("barrier", forPath: UIBezierPath(rect: barrier.frame))
        
        collision.translatesReferenceBoundsIntoBoundary = true
        animator.addBehavior(collision)
        
        
        
        
    }
    
    
    
    func backButtonAction(sender:UIButton!) {
        dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
    }
    
    func segmentedControlAction(sender:UISegmentedControl) {
        
        switch segmentedControl.selectedSegmentIndex {
            case 0:
                SettingDataManager.sharedInstance.enableAutoPlay()
                break
            case 1:
                SettingDataManager.sharedInstance.disableAutoPlay()
                break
            default:
                break
        }
    }
    
    func generateQuestion(){
        answerIndex = Int(arc4random_uniform(6))
    }
    
    func getQuestionString()->String {
        switch answerIndex {
            case 0:
                return "Princeton University"
            case 1:
                return "University of Chicago"
            case 2:
                return "University of Illinois at Urbana–Champaign"
            case 3:
                return "University of Michigan"
            case 4:
                return "Massachusetts Institute of Technology"
            case 5:
                return "Harvard University"
            default:
                return "University of Chicago"
        }
    }
    
    
    func buttonTapped(sender: UITapGestureRecognizer) {
        if sender.view?.tag == answerIndex {
            parentalGate.removeFromSuperview()
        }else {
            let alertController = UIAlertController(title: "Wrong answer", message: "Sorry. You can't change the setting.", preferredStyle: .Alert)
            
            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                    
                })
            }
            alertController.addAction(OKAction)
            
            self.presentViewController(alertController, animated: true) {
                
            }
        }
    }
}
