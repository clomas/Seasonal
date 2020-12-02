//
//  AlertController.swift
//  Pods
//
//  Created by Clint Thomas on 13/11/20.
//

import UIKit

// MARK: Sentence Case Strings

extension String {
    // convert camel case to setence case
    func titleCase() -> String {
        return self
            .replacingOccurrences(of: "([A-Z])",
                                  with: " $1",
                                  options: .regularExpression,
                                  range: range(of: self))
            .replacingOccurrences(of: "View", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .capitalized // If input is in llamaCase
    }
}

// MARK: global UIAlerts
// credit - https://stackoverflow.com/questions/38144019/how-to-create-uialertcontroller-in-global-swift/42622755

extension UIViewController {

    // Global Alert
    // Define Your number of buttons, styles and completion
    public func presentAlert(title: String,
                            message: String,
                            alertStyle: UIAlertController.Style,
                            actionTitles: [String],
                            actionStyles: [UIAlertAction.Style],
                            actions: [((UIAlertAction) -> Void)]){

        let alertController = UIAlertController(title: title, message: message, preferredStyle: alertStyle)
        for(index, indexTitle) in actionTitles.enumerated(){
            let action = UIAlertAction(title: indexTitle, style: actionStyles[index], handler: actions[index])
            alertController.addAction(action)
        }
        self.present(alertController, animated: true)
    }
}

// MARK: For first launch

extension UserDefaults {
    // check for is first launch - only true on first invocation after app install, false on all further invocations
    // Note: Store this value in AppDelegate if you have multiple places where you are checking for this flag
    static func isFirstLaunch() -> Bool {
        let hasBeenLaunchedBeforeFlag = "hasBeenLaunchedBeforeFlag"
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: hasBeenLaunchedBeforeFlag)
        if (isFirstLaunch) {
            UserDefaults.standard.set(true, forKey: hasBeenLaunchedBeforeFlag)
            UserDefaults.standard.synchronize()
        }
        return isFirstLaunch
    }
}

extension CaseIterable where Self: Equatable {

    var index: Self.AllCases.Index? {
        return Self.allCases.firstIndex { self == $0 }
    }
}

// MARK: Tints

extension UIColor {

    struct MonthIcon {
        static var inSeasonTint: UIColor  { return UIColor(named: INSEASONTINT)! }
        static var nonSeasonTint: UIColor { return UIColor(named: NONSEASONTINT)! }
    }

    struct LikeButton {
        static var likeTint: UIColor { return UIColor(named: LIKEBUTTONTINT)! }
    }

    struct MenuBar {
        static var tint: UIColor { return UIColor(named: MENUBARTINT)! }
        static var selectedTint: UIColor { return UIColor(named: MENUBARSELECTEDTINT)! }
    }

    struct NavigationBar {
        static var tint: UIColor { return UIColor(named: NAVIGATIONBARTINT)! }
        static var searchBarTint: UIColor { return UIColor(named: SEARCHBARTINT)! }
    }

    struct tableViewCell {
        static var tint: UIColor { return UIColor(named: TABLEVIEWCELLCOLOR)! }
    }
}
