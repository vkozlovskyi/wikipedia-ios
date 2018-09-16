//
// Created by Vladimir Kozlovskyi on 9/16/18.
// Copyright (c) 2018 Wikimedia Foundation. All rights reserved.
//

import Foundation
import MapKit

extension MKCoordinateRegion {

  func isDistanceSignificant(to visibleRegion: MKCoordinateRegion) -> Bool {
    let distance = CLLocation(latitude: visibleRegion.center.latitude, longitude: visibleRegion.center.longitude).distance(from: CLLocation(latitude: center.latitude, longitude: center.longitude))

    let searchRegionMinDimension = min(width, height)

    guard searchRegionMinDimension > 0 else {
      return distance > 1000
    }

    let isDistanceSignificant = distance/searchRegionMinDimension > 0.33
    guard !isDistanceSignificant else {
      return true
    }

    let visibleWidth = visibleRegion.width
    let visibleHeight = visibleRegion.height

    guard width > 0, visibleWidth > 0, visibleHeight > 0, height > 0 else {
      return false
    }

    let widthRatio = visibleWidth/width
    let heightRatio = visibleHeight/height
    let ratio = min(widthRatio, heightRatio)
    return ratio > 1.33 || ratio < 0.67
  }
}
