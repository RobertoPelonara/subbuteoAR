/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Application's delegate.
*/

import UIKit
import ARKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	var window: UIWindow?
    var gameManager: GameManager? {
        didSet{
            print("GAME MANAGER SET")
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        guard ARWorldTrackingConfiguration.isSupported else {
            fatalError("""
                ARKit is not available on this device. For apps that require ARKit
                for core functionality, use the `arkit` key in the key in the
                `UIRequiredDeviceCapabilities` section of the Info.plist to prevent
                the app from installing. (If the app can't be installed, this error
                can't be triggered in a production scenario.)
                In apps where AR is an additive feature, use `isSupported` to
                determine whether to show UI for launching AR experiences.
            """) // For details, see https://developer.apple.com/documentation/arkit
        }

        return true
    }
	
	func applicationWillResignActive(_ application: UIApplication) {
		if let viewController = self.window?.rootViewController as? ViewController {
			viewController.blurView.isHidden = false
		}
	}
	
	func applicationDidBecomeActive(_ application: UIApplication) {
		if let viewController = self.window?.rootViewController as? ViewController {
			viewController.blurView.isHidden = true
		}
	}
}
