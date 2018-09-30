//
//  PlacesSearchViewController.swift
//  Wikipedia
//
//  Created by Vladimir Kozlovskyi on 9/29/18.
//  Copyright © 2018 Wikimedia Foundation. All rights reserved.
//

import UIKit

protocol PlacesSearchViewControllerDelegate: AnyObject {
  func placesSearchViewControllerDidCancelSearch(_ vc: PlacesSearchViewController)
}

final class PlacesSearchViewController: UIViewController {

  @IBOutlet weak var listAndSearchOverlayFilterSelectorContainerView: UIView!
  @IBOutlet weak var listAndSearchOverlaySearchContainerView: UIView!
  @IBOutlet weak var listAndSearchOverlaySearchBar: UISearchBar!
  @IBOutlet weak var listAndSearchOverlaySearchSeparator: UIView!

  @IBOutlet weak var listAndSearchOverlayFilterSelectorContainerHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var listAndSearchOverlaySearchHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var listAndSearchOverlaySearchCancelButtonHideConstraint: NSLayoutConstraint!
  @IBOutlet weak var listAndSearchOverlaySearchCancelButtonShowConstraint: NSLayoutConstraint!
  @IBOutlet weak var listContainerView: UIView!
  @IBOutlet weak var searchSuggestionView: UITableView!

  weak var delegate: PlacesSearchViewControllerDelegate!

  @IBAction func cancelSearch(_ sender: Any) {
    delegate.placesSearchViewControllerDidCancelSearch(self)
  }

}

extension PlacesSearchViewController: Themeable {
  func apply(theme: Theme) {
    guard viewIfLoaded != nil else {
      return
    }
    view.backgroundColor = theme.colors.baseBackground

    listAndSearchOverlaySearchBar.backgroundColor = theme.colors.chromeBackground
    listAndSearchOverlaySearchBar.barTintColor = theme.colors.chromeBackground
    listAndSearchOverlaySearchBar.isTranslucent = false
    listAndSearchOverlaySearchBar.wmf_enumerateSubviewTextFields{ (textField) in
      textField.textColor = theme.colors.primaryText
      textField.keyboardAppearance = theme.keyboardAppearance
      textField.font = UIFont.systemFont(ofSize: 14)
    }
    listAndSearchOverlaySearchBar.setSearchFieldBackgroundImage(theme.searchBarBackgroundImage, for: .normal)
    listAndSearchOverlaySearchBar.searchTextPositionAdjustment = UIOffset(horizontal: 7, vertical: 0)

    listAndSearchOverlaySearchContainerView.backgroundColor = theme.colors.chromeBackground
    listAndSearchOverlayFilterSelectorContainerView.backgroundColor = theme.colors.chromeBackground

    listAndSearchOverlaySearchSeparator.backgroundColor = theme.colors.midBackground
  }
}
