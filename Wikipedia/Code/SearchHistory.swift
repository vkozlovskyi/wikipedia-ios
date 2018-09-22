//
// Created by Vladimir Kozlovskyi on 9/16/18.
// Copyright (c) 2018 Wikimedia Foundation. All rights reserved.
//

import Foundation
import CoreData

extension PlaceFilterType {

  var searchHistoryGroup: String {
    let searchHistoryGroup = "PlaceSearch"
    return "\(searchHistoryGroup).\(stringValue)"
  }
}


extension NSManagedObjectContext {

  func saveToHistory(_ search: PlaceSearch) {
    guard search.origin == .user else {
      DDLogDebug("not saving system search to history")
      return
    }

    do {
      if let keyValue = keyValue(forPlaceSearch: search) {
        keyValue.date = Date()
      } else if let entity = NSEntityDescription.entity(forEntityName: "WMFKeyValue", in: self) {
        let keyValue =  WMFKeyValue(entity: entity, insertInto: self)
        keyValue.key = search.key
        keyValue.group = search.filter.searchHistoryGroup
        keyValue.date = Date()
        keyValue.value = search.dictionaryValue as NSCoding
      }
      try save()
    } catch let error {
      DDLogError("error saving to place search history: \(error.localizedDescription)")
    }
  }

  func clearSearchHistory(for filter: PlaceFilterType) {
    do {
      let request = WMFKeyValue.fetchRequest()
      request.predicate = NSPredicate(format: "group == %@", filter.searchHistoryGroup)
      request.sortDescriptors = [NSSortDescriptor(keyPath: \WMFKeyValue.date, ascending: false)]
      let results = try fetch(request)
      for result in results {
        delete(result)
      }
      try save()
    } catch let error {
      DDLogError("Error clearing recent place searches: \(error)")
    }
  }

  func delete(_ search: PlaceSearch) {
    guard let kv = keyValue(forPlaceSearch: search) else {
      return
    }
    delete(kv)
    do {
      try save()
    } catch let error {
      DDLogError("Error removing kv: \(error.localizedDescription)")
    }
  }

  func recentSearches(for filter: PlaceFilterType) -> [PlaceSearch] {
    let searchHistoryCountLimit = 15
    do {
      let request = WMFKeyValue.fetchRequest()
      request.predicate = NSPredicate(format: "group == %@", filter.searchHistoryGroup)
      request.sortDescriptors = [NSSortDescriptor(keyPath: \WMFKeyValue.date, ascending: false)]
      let results = try fetch(request)
      let count = results.count
      if count > searchHistoryCountLimit {
        for result in results[searchHistoryCountLimit..<count] {
          delete(result)
        }
      }
      let limit = min(count, searchHistoryCountLimit)
      return try results[0..<limit].map({ (kv) -> PlaceSearch in
        guard let ps = PlaceSearch(object: kv.value) else {
          throw PlaceSearchError.deserialization(object: kv.value)
        }
        return ps
      })
    } catch let error {
      DDLogError("Error fetching recent place searches: \(error)")
      return []
    }
  }

  private func keyValue(forPlaceSearch placeSearch: PlaceSearch) -> WMFKeyValue? {
    var keyValue: WMFKeyValue?
    do {
      let key = placeSearch.key
      let request = WMFKeyValue.fetchRequest()
      request.predicate = NSPredicate(format: "key == %@ && group == %@", key, placeSearch.filter.searchHistoryGroup)
      request.fetchLimit = 1
      let results = try fetch(request)
      keyValue = results.first
    } catch let error {
      DDLogError("Error fetching place search key value: \(error.localizedDescription)")
    }
    return keyValue
  }
}