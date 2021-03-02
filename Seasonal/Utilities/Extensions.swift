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
//    public func presentAlert(title: String,
//                            message: String,
//                            alertStyle: UIAlertController.Style,
//                            actionTitles: [String],
//                            actionStyles: [UIAlertAction.Style],
//                            actions: [((UIAlertAction) -> Void)]){
//
//        let alertController = UIAlertController(title: title, message: message, preferredStyle: alertStyle)
//        for(index, indexTitle) in actionTitles.enumerated(){
//            let action = UIAlertAction(title: indexTitle, style: actionStyles[index], handler: actions[index])
//            alertController.addAction(action)
//        }
//        self.present(alertController, animated: true)
//    }
}

// MARK: For first launch


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

// MARK: Animations

extension UIButton {

    func animateLikeButton(selected: Bool) {
        // this removed a bug where the button jumped if I pressed like then pressed unlike - boom jump to the left.
        self.translatesAutoresizingMaskIntoConstraints = true

        if selected == true {
            self.setImage(UIImage(named: "\(LIKED).png"), for: .normal)
            UIView.animate(withDuration: 0.2, animations: {() -> Void in
                self.transform = CGAffineTransform.identity.scaledBy(x: 0.8, y: 0.8)
            }, completion: { _ in
                UIView.animate(withDuration: 0.2, animations: {
                    self.transform = CGAffineTransform.identity.scaledBy(x: 1.12, y: 1.12)
                }, completion: { _ in
                    UIView.animate(withDuration: 0.2, animations: {
                        self.transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1)
                    })
                })
            })
        } else {
            self.setImage(UIImage(named: "\(LIKED).png"), for: .normal)
            self.layoutIfNeeded()
            UIView.animate(withDuration: 0.3, delay: 0.0, options: UIView.AnimationOptions.beginFromCurrentState, animations: {
                self.frame = CGRect(x: self.frame.origin.x , y: self.frame.origin.y , width: self.frame.width, height: self.frame.height)
            }, completion: { _ in
                UIView.animate(withDuration: 0.3, delay: 0.0, options: UIView.AnimationOptions.beginFromCurrentState, animations: {
                    self.frame = CGRect(x: self.frame.origin.x + 100, y: self.frame.origin.y , width: self.frame.width, height: self.frame.height)
                }, completion: { _ in

                    let image = UIImage(named: "\(UNLIKED).png")?.withRenderingMode(.alwaysTemplate)
                    self.setImage(image, for: .normal)
                    self.imageView?.tintColor = UIColor.LikeButton.likeTint

                    UIView.animate(withDuration: 0.3, delay: 0.0, options: UIView.AnimationOptions.beginFromCurrentState, animations: {
                        self.frame = CGRect(x: self.frame.origin.x - 100, y: self.frame.origin.y , width: self.frame.width, height: self.frame.height)

                    })
                })
            })
        }
    }
}
