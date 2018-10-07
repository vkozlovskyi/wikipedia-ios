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
    func placesSearchViewController(_ vc: PlacesSearchViewController, didSelectSearch search: PlaceSearch)
    var currentSearchString: String { get }
    var currentSearchFilter: PlaceFilterType { get }
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
    @IBOutlet var emptySearchOverlayView: PlaceSearchEmptySearchOverlayView!

    var listViewController: ArticleLocationCollectionViewController!
    var searchSuggestionController: PlaceSearchSuggestionController!

    private weak var delegate: PlacesSearchViewControllerDelegate!
    private var dataStore: MWKDataStore!

    func configure(delegate: PlacesSearchViewControllerDelegate, dataStore: MWKDataStore) {
        self.delegate = delegate
        self.dataStore = dataStore
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        listViewController = ArticleLocationCollectionViewController(articleURLs: [], dataStore: dataStore)
        addChildViewController(listViewController)
        listViewController.view.frame = listContainerView.bounds
        listViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        listContainerView.addSubview(listViewController.view)
        listViewController.didMove(toParentViewController: self)
        listViewController.automaticallyAdjustsScrollViewInsets = true
        if #available(iOS 11.0, *) {
            listViewController.collectionView.contentInsetAdjustmentBehavior = .automatic
        }

        // Setup search suggestions
        searchSuggestionController = PlaceSearchSuggestionController()
        searchSuggestionController.tableView = searchSuggestionView
        searchSuggestionController.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardChanged), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardChanged), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    @IBAction func cancelSearch(_ sender: Any) {
        delegate.placesSearchViewControllerDidCancelSearch(self)
    }

    func updateSearchSuggestions(withCompletions completions: [PlaceSearch], isSearchDone: Bool) {
        guard delegate.currentSearchString != "" || completions.count > 0 else {

            // Search is empty, run a default search

            var defaultSuggestions = [PlaceSearch]()

            let yourLocationSuggestionTitle = WMFLocalizedString("places-search-your-current-location", value:"Your current location", comment:"A search suggestion for showing articles near your current location.")
            defaultSuggestions.append(PlaceSearch(filter: delegate.currentSearchFilter, type: .nearby, origin: .user, sortStyle: .links, string: nil, region: nil, localizedDescription: yourLocationSuggestionTitle, searchResult: nil))

            switch (delegate.currentSearchFilter) {
            case .top:
                defaultSuggestions.append(PlaceSearch(filter: .top, type: .location, origin: .system, sortStyle: .links, string: nil, region: nil, localizedDescription: WMFLocalizedString("places-search-top-articles", value:"All top articles", comment:"A search suggestion for top articles"), searchResult: nil))
            case .saved:
                defaultSuggestions.append(PlaceSearch(filter: .saved, type: .location, origin: .system, sortStyle: .links, string: nil, region: nil, localizedDescription: WMFLocalizedString("places-search-saved-articles", value:"All saved articles", comment:"A search suggestion for saved articles"), searchResult: nil))
            }

            let moc = dataStore.viewContext
            let recentSearches = moc.recentSearches(for: delegate.currentSearchFilter)

            searchSuggestionController.siteURL = Environment.siteURL
            searchSuggestionController.searches = [defaultSuggestions, recentSearches, [], []]

            if (recentSearches.count == 0) {
                setupEmptySearchOverlayView()
                emptySearchOverlayView.frame = searchSuggestionView.frame
                searchSuggestionView.superview?.addSubview(emptySearchOverlayView)
            } else {
                emptySearchOverlayView.removeFromSuperview()
            }

            return
        }

        emptySearchOverlayView.removeFromSuperview()

        guard delegate.currentSearchString != "" else {
            searchSuggestionController.searches = [[], [], [], completions]
            return
        }

        let currentSearchScopeName: String
        switch (delegate.currentSearchFilter) {
        case .top:
            currentSearchScopeName = WMFLocalizedString("places-search-top-articles-that-match-scope", value: "Nearby", comment: "Title used in search description when searching an area for Top articles")
        case .saved:
            currentSearchScopeName = PlaceSearchFilterListController.savedArticlesFilterLocalizedTitle
        }

        var currentSearchStringSuggestions = [PlaceSearch]()
        if isSearchDone {
            let currentSearchStringTitle = String.localizedStringWithFormat(WMFLocalizedString("places-search-articles-that-match", value:"%1$@ matching “%2$@”", comment:"A search suggestion for filtering the articles in the area by the search string. %1$@ is replaced by the a string depending on the current filter ('Nearby' for 'Top Articles' or 'Saved articles'). %2$@ is replaced with the search string"), currentSearchScopeName, delegate.currentSearchString)
            currentSearchStringSuggestions.append(PlaceSearch(filter: delegate.currentSearchFilter, type: .text, origin: .user, sortStyle: .links, string: delegate.currentSearchString, region: nil, localizedDescription: currentSearchStringTitle, searchResult: nil))
        }

        searchSuggestionController.searches = [[], [], currentSearchStringSuggestions, completions]
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

        emptySearchOverlayView.backgroundColor = theme.colors.midBackground
        emptySearchOverlayView.mainLabel.textColor = theme.colors.primaryText
        emptySearchOverlayView.detailLabel.textColor = theme.colors.secondaryText
    }

    func setupEmptySearchOverlayView() {
        emptySearchOverlayView.mainLabel.text = WMFLocalizedString("places-empty-search-title", value:"Search for Wikipedia articles with geographic locations", comment:"Title text shown on an overlay when there are no recent Places searches. Describes that you can search Wikipedia for articles with geographic locations.")
        emptySearchOverlayView.detailLabel.text = WMFLocalizedString("places-empty-search-description", value:"Explore cities, countries, continents, natural landmarks, historical events, buildings and more.", comment:"Detail text shown on an overlay when there are no recent Places searches. Describes the kind of articles you can search for.")
    }

    func hideEmptySearchOverlay() {
        emptySearchOverlayView.removeFromSuperview()
    }

    // MARK: - Keyboard

    @objc func keyboardChanged(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
            let frameValue = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue else {
                return
        }
        let keyboardScreenFrame = frameValue.cgRectValue
        var inset = searchSuggestionView.contentInset
        inset.bottom = keyboardScreenFrame.size.height
        searchSuggestionView.contentInset = inset

        let keyboardViewFrame = emptySearchOverlayView.convert(keyboardScreenFrame, from: (UIApplication.shared.delegate?.window)!)

        switch (notification.name) {
        case NSNotification.Name.UIKeyboardWillShow:
            let overlap = keyboardViewFrame.intersection(emptySearchOverlayView.frame)
            var newFrame = emptySearchOverlayView.frame
            newFrame.size.height -= overlap.height
            emptySearchOverlayView.frame = newFrame

        case NSNotification.Name.UIKeyboardWillHide:
            // reset the frame
            emptySearchOverlayView.frame = searchSuggestionView.frame

        default:
            DDLogWarn("unexpected notification \(notification.name)")
        }

        self.view.setNeedsLayout()
    }
}

// MARK: - PlaceSearchSuggestionControllerDelegate

extension PlacesSearchViewController: PlaceSearchSuggestionControllerDelegate {

    func placeSearchSuggestionController(_ controller: PlaceSearchSuggestionController, didSelectSearch search: PlaceSearch) {
        delegate.placesSearchViewController(self, didSelectSearch: search)
    }

    func placeSearchSuggestionControllerClearButtonPressed(_ controller: PlaceSearchSuggestionController) {
        dataStore.viewContext.clearSearchHistory(for: delegate.currentSearchFilter)
        updateSearchSuggestions(withCompletions: [], isSearchDone: false)
    }

    func placeSearchSuggestionController(_ controller: PlaceSearchSuggestionController, didDeleteSearch search: PlaceSearch) {
        let moc = dataStore.viewContext
        moc.delete(search)
        updateSearchSuggestions(withCompletions: [], isSearchDone: false)
    }
}
