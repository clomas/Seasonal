//
//  MainCoordinator.swift
//  Seasonal
//
//  Created by Clint Thomas on 19/8/20.
//  Copyright © 2020 Clint Thomas. All rights reserved.
//



import Foundation
import Network
import UIKit

class MainCoordinator {
//class MainCoordinator: NSObject, UINavigationControllerDelegate, Coordinator, NetworkCheckObserver, LocationDelegate {

//    var navigationController: CustomNavigationController
//    var childCoordinators = [Coordinator]()
//    var networkCheck = NetworkService.sharedInstance()
//    var locationManager: LocationManager! = LocationManager.instance
//    var transition = CATransition()
//
//    // data for ViewControllers
//    var statusViewModel: AppStateViewModel!
//    var viewModel: ProduceCellViewModel!
//
//    // current view
//    var currentViewSelected: ViewDisplayed = .months
//
//    // Initial ViewControllers
//    weak var welcomeVC = WelcomeVC.instantiate()
//    weak var initialVC = InitialVC.instantiate()
//
//    var firstRun = UserDefaults.isFirstLaunch()
//
//    init(navigationController: CustomNavigationController) {
//        self.navigationController = navigationController
//    }
//
//    func start() {
//        navigationController.delegate = self
//        locationManager.locationDelegate = self
//        revealTopTransition()
//
//        let networkStatus = networkCheck.currentStatus.self
//        if networkStatus == .satisfied {
//            initViewModel()
//        }
//        decideFirstViewController(networkStatus: networkStatus)
//    }
//
//    // MARK: ViewModel
//    func initViewModel() {
//        let monthAndSeason = DateHandler.instance.findMonthAndSeason()
//        statusViewModel = AppStateViewModel.init(month: monthAndSeason.0,
//                                                                 season: monthAndSeason.1,
//                                                                 monthOrFavView: ViewDisplayed.months, filter: ViewDisplayed.ProduceFilter.cancelled,
//                                                                 state: .noState)
//    }
//
//    // first time launched = show welcomeVC
//    func decideFirstViewController(networkStatus: NWPath.Status) {
//        if firstRun == true {
//            welcomeVC?.coordinator = self
//            welcomeVC?.internetStatusDidChange(status: networkStatus)
//            navigationController.pushViewController(welcomeVC ?? UIViewController(), animated: false)
//        } else {
//            initialVC?.internetStatusDidChange(status: networkStatus)
//            navigationController.pushViewController(initialVC ?? UIViewController(), animated: false)
//        }
//
//        if networkStatus == .unsatisfied {
//            networkCheck.addObserver(observer: self)
//        } else {
//            locationManager.start()
//        }
//    }
//
//    // MARK: Location
//    // When location is determined - get data!
//    func locationReadyGetData(location: State) {
//        
//        })
//    }
//
//    // MARK: ViewControllers
//    func presentMonthVC() {
//        self.navigationController.navigationBar.isHidden = false
//        let vc = MonthViewController.instantiate()
//        vc.coordinator = self
//
//        // for navgating back to MonthViewControlaler
//        vc.navigationCallback = { [self] (previousViewDisplayed) in
//
//            switch statusViewModel?.status.current.onPage {
//            case .monthPicker:
//                loadMonthPickerViewController()
//            case .seasons:
//                loadSeasonsViewController()
//            default: break
//            }
//            statusViewModel?.status.current.onPage = previousViewDisplayed
//        }
//        vc.viewModel = viewModel
//        vc.stateViewModel = statusViewModel
//        navigationController.view.layer.add(transition, forKey: kCATransition)
//        navigationController.pushViewController(vc, animated: true)
//    }
//
//    // Call back for month selected here
//    func loadMonthPickerViewController() {
//        let vc = MonthPickerViewController.instantiate()
//
//        vc.monthSelectViewTapped = { [weak self] month in
//            //self?.currentMonthAndSeason.0 = month
//            self?.statusViewModel?.status.month = month
//            self?.presentMonthVC()
//        }
//
//        vc.modalPresentationStyle = .formSheet
//        navigationController.pushViewController(vc, animated: true)
//    }
//
//    func loadSeasonsViewController() {
//        let vc = SeasonsViewController.instantiate()
//        vc.coordinator = self
//        vc.stateViewModel = statusViewModel
//        vc.viewModel = viewModel
//        navigationController.pushViewController(vc, animated: true)
//    }
//
//    // Navigation // DidShow From where
//    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
//        guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from) else {
//            return
//        }
//        updateMonthViewController(vc: viewController)
//
//        // handle navigation
//        if navigationController.viewControllers.contains(fromViewController) {
//            return
//        }
//        updateMonthViewController(vc: viewController)
//    }
//
//    // handle back button
//    func updateMonthViewController(vc: UIViewController) {
//        if let monthVC = vc as? MonthViewController {
//            statusViewModel?.status.onPage = .months
//            monthVC.viewDidReappear()
//        }
//    }
//
//    // MARK: Network Changed
//    // If network changes, shouldn't run if OK initially
//    func internetStatusDidChange(status: NWPath.Status) {
//        if status == .satisfied {
//            if statusViewModel == nil {
//                initViewModel()
//            }
//            if firstRun == true && welcomeVC != nil {
//                welcomeVC?.internetStatusDidChange(status: status)
//                locationManager.start()
//            }
//        }
//    }
//
//    func revealTopTransition() {
//        transition = CATransition()
//        transition.duration = 0.5
//        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
//        transition.type = CATransitionType.reveal
//        transition.subtype = CATransitionSubtype.fromTop
//    }
}

