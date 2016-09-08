
//  Created by Dominik on 22/08/2015.

//    The MIT License (MIT)
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE.

//    v1.2

import UIKit
import SystemConfiguration

/// Alert strings
private struct AlertString {
    static let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? ""
    
    static let title = "Review App"
    static let message = "If you enjoy playing \(appName) would you mind taking a moment to rate it? It won't take more than a minute. Thanks for your support!"
    static let leaveReview = "Leave Review"
    static let remindMeLater = "Remind Me Later"
    static let noThanks = "No, Thanks"
}

/// Settings
private let currentAppLaunchesKey = "CurrentAppLaunchesKey"
private var currentAppLaunches: Int {
    get { return UserDefaults.standard.integer(forKey: currentAppLaunchesKey) }
    set { UserDefaults.standard.set(newValue, forKey: currentAppLaunchesKey) }
}

private let doNotShowKey = "DoNotShowKey"
private var doNotShow: Bool {
    get { return UserDefaults.standard.bool(forKey: doNotShowKey) }
    set { UserDefaults.standard.set(newValue, forKey: doNotShowKey) }
}

/// Rate game alert protocol extension
protocol RateGameAlert { }
extension RateGameAlert where Self: UIViewController {
    
    func checkRateGameAlert(forAppID appID: String, appLaunchesUntilAlert: Int = 20) {
        
        /// Check if already reviewed/cancelled and internet connection
        guard !doNotShow else { return }
        
        /// Increase launch counter
        currentAppLaunches += 1
        
        /// Check if timesTillShowingAlert counter is reached
        guard currentAppLaunches >= appLaunchesUntilAlert else { return }
        
        /// Alert controller
        let alertController = UIAlertController(title: AlertString.title, message: AlertString.message, preferredStyle: .alert)
        
        /// Leave review
        let leaveReviewAction = UIAlertAction(title: AlertString.leaveReview, style: .default) { [unowned self] _ in
            doNotShow = true
            guard let url = URL(string: self.getAppStoreURL(forAppID: appID)) else { return }
            UIApplication.shared.openURL(url)
        }
        alertController.addAction(leaveReviewAction)
        
        /// Remind me later
        let remindMeLaterAction = UIAlertAction(title: AlertString.remindMeLater, style: .default) { _ in
            currentAppLaunches = currentAppLaunches / 2
        }
        alertController.addAction(remindMeLaterAction)
        
        /// No thanks
        let noThanksAction = UIAlertAction(title: AlertString.noThanks, style: .destructive) { _ in
            doNotShow = true
        }
        alertController.addAction(noThanksAction)
        
        /// Present alert
        view?.window?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
}

/// Get app store url for appID
private extension RateGameAlert {
    
    func getAppStoreURL(forAppID appID: String) -> String {
        #if os(iOS)
            return "itms-apps://itunes.apple.com/app/id" + appID
        #endif
        #if os(tvOS)
            return "com.apple.TVAppStore://itunes.apple.com/app/id" + appID
        #endif
    }
}
