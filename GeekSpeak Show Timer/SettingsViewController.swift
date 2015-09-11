import UIKit

class SettingsViewController: UIViewController {

  // TODO: The Timer Property should be injected by the SplitViewController
  //       during the segue. Revisit and stop pulling from the app delegate
  var timer: Timer? {
    if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate  {
      return appDelegate.timer
    } else {
      return .None
    }
  }

  
  // Required properties
  @IBOutlet weak var contentView: UIView!
  @IBOutlet weak var backgroundImageView: UIImageView!
  @IBOutlet weak var leftNavButton: UIBarButtonItem!
  
  @IBOutlet weak var add1SecondButton: UIButton!
  @IBOutlet weak var add5SecondsButton: UIButton!
  @IBOutlet weak var add10SecondsButton: UIButton!
  @IBOutlet weak var remove1SecondButton: UIButton!
  @IBOutlet weak var resetButton: UIButton!
  
  @IBOutlet weak var segment1Label: UILabel!
  @IBOutlet weak var segment2Label: UILabel!
  @IBOutlet weak var segment3Label: UILabel!
  @IBOutlet weak var postShowLabel: UILabel!
  
  
  
  // MARK: Convience Properties
  var timerViewController: TimerViewController? {
    var timerViewController: TimerViewController? = .None
    if let splitViewController = splitViewController {
      if let navController: AnyObject? =
                                      splitViewController.viewControllers.last {
        if let navController = navController as? UINavigationController {
          if let tmpTimerViewController =
                       navController.topViewController as? TimerViewController {
            timerViewController = tmpTimerViewController
          }
        }
      }
    }
    return timerViewController
  }
  
  
  var useDemoDurations = false
  func updateUseDemoDurations() {
    useDemoDurations = NSUserDefaults
                                   .standardUserDefaults()
                                   .boolForKey(Timer.Constants.UseDemoDurations)
  }
  

  
  // MARK: ViewController
  override func viewDidLoad() {
    addContraintsForContentView()
  }
  
  override func viewWillAppear(animated: Bool) {
    generateBluredBackground()
    if let navigationController = navigationController {
      Appearance.appearanceForNavigationController(navigationController)
    }
    manageButtonBarButtons()
    updateElapsedTimeLabels()
    registerForTimerNotifications()
  }
  
  override func viewDidAppear(animated: Bool) {
  }
  
  override func viewWillDisappear(animated: Bool) {
    unregisterForTimerNotifications()
  }
  
  
  // MARK: Actions
  @IBAction func add1SecondButtonPressed(sender: UIButton) {
    timer?.duration += 1.0
    generateBluredBackground()
  }
  
  @IBAction func add5SecondsButtonPressed(sender: UIButton) {
    timer?.duration += 5.0
    generateBluredBackground()
  }
  
  @IBAction func add10SecondsButtonPressed(sender: UIButton) {
    timer?.duration += 10.0
    generateBluredBackground()
  }
  
  @IBAction func remove1SecondButtonPressed(sender: UIButton) {
    timer?.duration -= 1.0
    generateBluredBackground()
  }
  
  @IBAction func resetButtonPressed(sender: UIButton) {
    resetTimer()
    generateBluredBackground()
  }
  

  @IBAction func showTimerNavButtonPressed(sender: UIBarButtonItem) {
    if let splitViewController = splitViewController {
      // collapsed = true  is iPhone
      // collapsed = false is iPad & Plus
      if splitViewController.collapsed {
        self.performSegueWithIdentifier("showTimer", sender: self)
      } else {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.pressButtonBarItem()
      }
    }
  }
  
  
  // MARK: -
  // MARK: Timer management
  func resetTimer() {
    updateUseDemoDurations()
    if useDemoDurations {
      timer?.reset(usingDemoTiming: true)
    } else {
      timer?.reset(usingDemoTiming: false)
    }
  }
  
  
  
  func manageButtonBarButtons() {
    if let splitViewController = splitViewController  {
      // collapsed = true  is iPhone
      // collapsed = false is iPad & Plus
      if splitViewController.collapsed == true {
        leftNavButton.title = "Show Timer"
      } else {
        leftNavButton.title = "Hide"
      }
    }
  }
  
  
  // TODO: Do this on a background thread
  func generateBluredBackground() {
    // https://uncorkedstudios.com/blog/ios-7-background-effects-and-split-view-controllers
    
    if let underneathViewController = timerViewController {
      // set up the graphics context to render the screen snapshot.
      // Note the scale value... Values greater than 1 make a context smaller
      // than the detail view controller. Smaller context means faster rendering
      // of the final blurred background image
      let scaleValue = CGFloat(8)
      let underneathViewControllerSize = underneathViewController.view.frame.size
      let contextSize =
                    CGSizeMake(underneathViewControllerSize.width  / scaleValue,
                               underneathViewControllerSize.height / scaleValue)
      UIGraphicsBeginImageContextWithOptions(contextSize, true, 1)
      let drawingRect = CGRectMake(0, 0, contextSize.width, contextSize.height)

      // Now grab the snapshot of the detail view controllers content
      underneathViewController.view.drawViewHierarchyInRect( drawingRect,
                                         afterScreenUpdates: false)
      let snapshotImage = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()

      // Now get a sub-image of our snapshot. Just grab the portion of the
      // shapshot that would be covered by the master view controller when
      // it becomes visible.
      // Pulling out the sub-image means we can supply an appropriately sized
      // background image for the master controller, and makes application of
      // the blur effect run faster since we are only only blurring image data 
      // that will actually be visible.    
      let subRect = CGRectMake(0, 0, self.view.frame.size.width / scaleValue,
                                     self.view.frame.size.height / scaleValue)
      let subImage = CGImageCreateWithImageInRect(snapshotImage.CGImage, subRect)
    
      if let backgroundImage = UIImage(CGImage: subImage) {
        // CGImageRelease(subImage)
        
        // Now actually apply the blur to the snapshot and set the background
        // behind our master view controller
        backgroundImageView.image = backgroundImage.applyBlurWithRadius( 20,
                                                tintColor: UIColor.clearColor(),
                                    saturationDeltaFactor: 1.8,
                                                maskImage: nil)
      }
    } else {
      backgroundImageView.image = UIImage.imageWithColor(UIColor.blackColor())
    }
    
  } // generateBluredBackground
  
  
  func addContraintsForContentView() {
    
    let leftConstraint = NSLayoutConstraint(item: contentView,
                                       attribute: .Leading,
                                       relatedBy: .Equal,
                                          toItem: view,
                                       attribute: .Left,
                                      multiplier: 1.0,
                                        constant: 0.0)
    view.addConstraint(leftConstraint)
    
    let rightConstraint = NSLayoutConstraint(item: contentView,
                                        attribute: .Trailing,
                                        relatedBy: .Equal,
                                           toItem: view,
                                        attribute: .Right,
                                       multiplier: 1.0,
                                         constant: 0.0)
    view.addConstraint(rightConstraint)
    
  }
  
  // MARK: Manage SplitViewContoller preferedDisplayMode
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    super.prepareForSegue(segue, sender: sender)
    if let svc = splitViewController  {
      if svc.collapsed {
        println("    collapsed (settings view controller)")
//        return .Automatic
      } else {
        println("not collapsed (settings view controller)")
//        return .PrimaryOverlay
      }
    }
  }

}

