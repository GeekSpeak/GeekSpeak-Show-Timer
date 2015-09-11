import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  struct Constants {
    static let TimerId              = "timerViewControllerTimerId"
    static let TimerNotificationKey = "com.geekspeak.timerNotificationKey"
    static let TimerDataPath        = "TimerData.plist"
  }
  
  

  var timer = Timer()
  var splitViewControllerDelegate = TimerSplitViewControllerDelegate()
  var window: UIWindow?
  
  var splitViewController: UISplitViewController? {
    if let splitViewController = self.window?.rootViewController
      as? UISplitViewController {
      return splitViewController
    } else {
      return .None
    }
  }


  func application(application: UIApplication,
       didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?)
                                                                       -> Bool {
    registerUserDefaults()
    Appearance.apply()
    setupSplitViewController()
    return true
  }
  

  func application(application: UIApplication,
          willFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?)
                                                                       -> Bool {
    self.window?.makeKeyAndVisible()
    UIApplication.sharedApplication()
                 .setStatusBarStyle( UIStatusBarStyle.Default,
                           animated: false)
    return true
  }
  
  func applicationWillResignActive(application: UIApplication) {
  }

  func applicationDidEnterBackground(application: UIApplication) {
  }

  func applicationWillEnterForeground(application: UIApplication) {
    // reset the timer if it hasn't started, so that it uses the UserDefaults
    // to set which timing to use (demo or show)
    if timer.totalShowTimeElapsed == 0 {
      timer.reset()
    }
  }

  func applicationDidBecomeActive(application: UIApplication) {
  }

  func applicationWillTerminate(application: UIApplication) {
  }
  
  func application(application: UIApplication, shouldSaveApplicationState
                         coder: NSCoder) -> Bool {
    return true
  }

  func application(application: UIApplication, shouldRestoreApplicationState
                         coder: NSCoder) -> Bool {
    return true
  }

}


extension AppDelegate {

  func setupSplitViewController() {
    if let splitViewController = splitViewController {
      // setup nav bar buttons
//        let index = splitViewController.viewControllers.count - 1
//        let navigationController = splitViewController
//                              .viewControllers[index] as! UINavigationController
//        let navItem = navigationController.topViewController.navigationItem
//        navItem.leftBarButtonItem = splitViewController.displayModeButtonItem()
//        navItem.leftItemsSupplementBackButton = true
      println("Assigning splitViewControllerDelegate")
      splitViewController.delegate = splitViewControllerDelegate
    }
  }

  func pressButtonBarItem() {
    func setupSplitViewController() {
      if let splitViewController = splitViewController {
          let barButtonItem = splitViewController.displayModeButtonItem()
            UIApplication.sharedApplication().sendAction( barButtonItem.action,
                                                      to: barButtonItem.target,
                                                    from: nil,
                                                forEvent: nil)
          }
      }
  }
  
  // Setup the default defaults in app memory
  func registerUserDefaults() {
    let defaults: [String:AnyObject] = [
      Timer.Constants.UseDemoDurations: false
    ]
    
    NSUserDefaults.standardUserDefaults().registerDefaults(defaults)
  }
  
}


