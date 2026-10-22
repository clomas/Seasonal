//
//  PhoneSizedContainerViewController.swift
//  Seasonal
//
//  Created by Clint Thomas on 22/10/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import UIKit

final class PhoneSizedContainerViewController: UIViewController {

	private let child: UIViewController
	private let phoneSize: CGSize = CGSize(width: 393, height: 852)
	private let margin: CGFloat = 20
	private let cornerRadius: CGFloat = 40
	private let cornerSafeAreaInset: CGFloat = 20
	private let shadowRadius: CGFloat = 24
	private let shadowOpacity: Float = 0.2
	private let shadowView: UIView = UIView()

	override var childForStatusBarStyle: UIViewController? { child }
	override var childForStatusBarHidden: UIViewController? { child }

	init(child: UIViewController) {
		self.child = child
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .secondarySystemBackground

		shadowView.layer.shadowColor = UIColor.black.cgColor
		shadowView.layer.shadowOpacity = shadowOpacity
		shadowView.layer.shadowRadius = shadowRadius
		shadowView.layer.shadowOffset = .zero
		view.addSubview(shadowView)

		addChild(child)
		child.view.layer.cornerCurve = .continuous
		child.view.clipsToBounds = true
		shadowView.addSubview(child.view)
		child.didMove(toParent: self)
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		let available: CGRect = view.bounds.insetBy(dx: margin, dy: margin)
		let fillsScreen: Bool = available.width <= phoneSize.width

		let frame: CGRect = fillsScreen ? view.bounds : CGRect(
			x: available.midX - phoneSize.width / 2,
			y: available.midY - min(phoneSize.height, available.height) / 2,
			width: phoneSize.width,
			height: min(phoneSize.height, available.height)
		)

		shadowView.frame = frame
		shadowView.layer.shadowPath = UIBezierPath(roundedRect: shadowView.bounds, cornerRadius: fillsScreen ? 0 : cornerRadius).cgPath
		shadowView.layer.shadowOpacity = fillsScreen ? 0 : shadowOpacity
		child.view.frame = shadowView.bounds
		child.view.layer.cornerRadius = fillsScreen ? 0 : cornerRadius
		child.additionalSafeAreaInsets = fillsScreen ? .zero : UIEdgeInsets(
			top: cornerSafeAreaInset,
			left: 0,
			bottom: cornerSafeAreaInset,
			right: 0
		)
	}
}
