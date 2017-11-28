import Foundation


public enum ReadingListError: Error, Equatable {
    case listExistsWithTheSameName(name: String)
    case unableToCreateList
    case listWithProvidedNameNotFound(name: String)
    
    public var localizedDescription: String {
        switch self {
        case .listExistsWithTheSameName(let name):
            let format = WMFLocalizedString("reading-list-exists-with-same-name", value: "A reading list already exists with the name ‟%1$@”", comment: "Informs the user that a reading list exists with the same name.")
            return String.localizedStringWithFormat(format, name)
        case .listWithProvidedNameNotFound(let name):
            let format = WMFLocalizedString("reading-list-with-provided-name-not-found", value: "A reading list with the name ‟%1$@” was not found. Please make sure you have the correct name.", comment: "Informs the user that a reading list with the name they provided was not found.")
            return String.localizedStringWithFormat(format, name)
        case .unableToCreateList:
            return WMFLocalizedString("reading-list-unable-to-create", value: "An unexpected error occured while creating your reading list. Please try again later.", comment: "Informs the user that an error occurred while creating their reading list.")
        }
    }
    
    public static func ==(lhs: ReadingListError, rhs: ReadingListError) -> Bool {
        return lhs.localizedDescription == rhs.localizedDescription //shrug
    }
}


@objc(WMFReadingListsController)
public class ReadingListsController: NSObject {
    fileprivate weak var dataStore: MWKDataStore!
    fileprivate let apiController = ReadingListsAPIController()
    
    @objc init(dataStore: MWKDataStore) {
        self.dataStore = dataStore
        super.init()
    }
    
    // User-facing actions. Everything is performed on the main context
    
    public func createReadingList(named name: String, with articles: [WMFArticle] = []) throws -> ReadingList {
        assert(Thread.isMainThread)
        let moc = dataStore.viewContext
        let existingListRequest: NSFetchRequest<ReadingList> = ReadingList.fetchRequest()
        existingListRequest.predicate = NSPredicate(format: "name MATCHES[c] %@", name)
        existingListRequest.fetchLimit = 1
        let result = try moc.fetch(existingListRequest).first
        guard result == nil else {
            throw ReadingListError.listExistsWithTheSameName(name: name)
        }
        guard let list = moc.wmf_create(entityNamed: "ReadingList", withValue: name, forKey: "name") as? ReadingList else {
            throw ReadingListError.unableToCreateList
        }
        
        try add(articles: articles, to: list)
        
        if moc.hasChanges {
            try moc.save()
        }
        
        return list
    }
    
    public func delete(readingLists: [ReadingList]) throws {
        assert(Thread.isMainThread)

        let moc = dataStore.viewContext
        
        for readingList in readingLists {
            moc.delete(readingList)
        }
        
        if moc.hasChanges {
            try moc.save()
        }
        
    }
    
    public func add(articles: [WMFArticle], to readingList: ReadingList) throws {
        assert(Thread.isMainThread)

        let moc = dataStore.viewContext
        
        let keys = articles.flatMap { (article) -> String? in
            return article.key
        }
        
        let existingKeys = readingList.articleKeys
        
        var keysToAdd = Set(keys)
        keysToAdd.subtract(existingKeys)
        
        for key in keysToAdd {
            guard let entry = moc.wmf_create(entityNamed: "ReadingListEntry", withValue: key, forKey: "articleKey") as? ReadingListEntry else {
                return
            }
            let url = URL(string: key)
            entry.displayTitle = url?.wmf_title
            entry.list = readingList
        }
        
        if moc.hasChanges {
            try moc.save()
        }

    }
    
    public func remove(articles: [WMFArticle], fromReadingList readingList: ReadingList) throws {
        assert(Thread.isMainThread)
        
        let moc = dataStore.viewContext
        
        let keysToDelete = articles.flatMap { (article) -> String? in
            return article.key
        }
        
        let entriesToDeleteRequest: NSFetchRequest<ReadingListEntry> = ReadingListEntry.fetchRequest()
        entriesToDeleteRequest.predicate = NSPredicate(format: "list == %@ && articleKey IN %@", readingList, keysToDelete)
        
        let entriesToDelete = try moc.fetch(entriesToDeleteRequest)
        
        for entry in entriesToDelete {
            moc.delete(entry)
        }
        
        if moc.hasChanges {
            try moc.save()
        }
    }
    
    @objc public func fetchReadingLists(with names: [String]) throws -> [ReadingList] {
        let moc = dataStore.viewContext
        let readingListRequest: NSFetchRequest<ReadingList> = ReadingList.fetchRequest(
        )
        var predicates: [NSPredicate] = []
        
        for name in names {
            let predicate = NSPredicate(format: "name MATCHES[cd] %@", name)
            predicates.append(predicate)
        }
        
        readingListRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
        readingListRequest.fetchLimit = predicates.count
        
        return try moc.fetch(readingListRequest)
    }
    
}
