import UIKit

class ArticleURLListViewController: ArticleCollectionViewController, EditControllerUpdater {
    let articleURLs: [URL]
    private let contentGroup: WMFContentGroup?

    required init(articleURLs: [URL], dataStore: MWKDataStore, contentGroup: WMFContentGroup? = nil, theme: Theme) {
        self.articleURLs = articleURLs
        self.contentGroup = contentGroup
        super.init()
        self.theme = theme
        self.dataStore = dataStore
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not supported")
    }
    
    override func articleURL(at indexPath: IndexPath) -> URL? {
        guard indexPath.item < articleURLs.count else {
            return nil
        }
        return articleURLs[indexPath.item]
    }
    
    override func article(at indexPath: IndexPath) -> WMFArticle? {
        guard let articleURL = articleURL(at: indexPath) else {
            return nil
        }
        return dataStore.fetchOrCreateArticle(with: articleURL)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.reloadData()
        registerForArticleUpdates()
    }

    deinit {
        unregisterForArticleUpdates()
    }
    
    override var eventLoggingCategory: EventLoggingCategory {
        return .feed
    }
    
    override var eventLoggingLabel: EventLoggingLabel? {
        return contentGroup?.eventLoggingLabel
    }
}

// MARK: - UICollectionViewDataSource
extension ArticleURLListViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return articleURLs.count
    }
}
