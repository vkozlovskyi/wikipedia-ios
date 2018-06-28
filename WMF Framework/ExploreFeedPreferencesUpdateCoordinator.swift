@objc public class ExploreFeedPreferencesUpdateCoordinator: NSObject {
    private let oldExploreFeedPreferences: Dictionary<String, Set<NSNumber>>
    private let newExploreFeedPreferences: Dictionary<String, Set<NSNumber>>
    private let feedContentController: WMFExploreFeedContentController

    @objc public init(feedContentController: WMFExploreFeedContentController, oldExploreFeedPreferences: Dictionary<String, Set<NSNumber>>, newExploreFeedPreferences: Dictionary<String, Set<NSNumber>>) {
        self.feedContentController = feedContentController
        self.oldExploreFeedPreferences = oldExploreFeedPreferences
        self.newExploreFeedPreferences = newExploreFeedPreferences
        super.init()
    }

    @objc public func coordinateUpdate(from viewController: UIViewController) {
        let feedContentController = SessionSingleton.sharedInstance().dataStore.feedContentController
        guard willTurnOffExploreFeedTab else {
            feedContentController.saveNewExploreFeedPreferences(newExploreFeedPreferences, updateFeed: true)
            return
        }
        if let presentedViewController = viewController.presentedViewController {
            presentedViewController.present(alertController, animated: true)
        } else {
            viewController.present(alertController, animated: true)
        }
    }

    private var willTurnOffExploreFeedTab: Bool {
        guard newExploreFeedPreferences.count == 1 else {
            return false
        }
        guard let firstValue = newExploreFeedPreferences.first?.value else {
            return true
        }
        return firstValue.count <= 1
    }

    // TODO: Update copy
    private lazy var alertController: UIAlertController = {
        let alertController = UIAlertController(title: "Turn off Explore feed?", message: "Turning off all the feed cards will result in turning off the Explore feed", preferredStyle: .alert)
        let cancel = UIAlertAction(title: CommonStrings.cancelActionTitle, style: .cancel, handler: { (_) in
            self.feedContentController.rejectNewExploreFeedPreferences(self.oldExploreFeedPreferences)
        })
        let turnOffExploreFeed = UIAlertAction(title: "Turn off Explore feed", style: .destructive, handler: { (_) in
            UserDefaults.wmf_userDefaults().defaultTabType = .settings
            self.feedContentController.saveNewExploreFeedPreferences(self.newExploreFeedPreferences, updateFeed: true)
        })
        alertController.addAction(cancel)
        alertController.addAction(turnOffExploreFeed)
        return alertController
    }()
}
