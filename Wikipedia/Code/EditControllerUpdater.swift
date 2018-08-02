import UIKit

protocol ArticleURLProvider: class {
    func articleURL(at indexPath: IndexPath) -> URL?
}

protocol EditControllerUpdater: EditableCollection, ArticleURLProvider {

}

extension EditControllerUpdater {
    func registerForArticleUpdates() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.WMFArticleUpdated, object: nil, queue: nil) { [weak self] (notification) in
            guard let databaseKey = (notification.object as? WMFArticle)?.key, let indexPaths = self?.collectionView.indexPathsForVisibleItems else {
                    return
            }
            for indexPath in indexPaths {
                guard
                    let visibleKey = self?.articleURL(at: indexPath)?.wmf_articleDatabaseKey,
                    visibleKey == databaseKey
                    else {
                        continue
                }
                guard let cell = self?.collectionView.cellForItem(at: indexPath) else {
                    continue
                }
                self?.editController.configureSwipeableCell(cell, forItemAt: indexPath, layoutOnly: false)
            }
        }
    }

    func unregisterForArticleUpdates() {
        NotificationCenter.default.removeObserver(self)
    }
}
