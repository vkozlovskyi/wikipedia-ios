//
// Created by Vladimir Kozlovskyi on 9/16/18.
// Copyright (c) 2018 Wikimedia Foundation. All rights reserved.
//

import Foundation

enum PopoverLocation {
  case top
  case bottom
  case left
  case right
}

extension CGRect {
  var center: CGPoint {
    return CGPoint(x: midX, y: midY)
  }
}

func computeLayout(for popoverSize: CGSize,
                   viewSize: CGSize,
                   forAnnotationView annotationViewFrame: CGRect,
                   extendedNavBarHeight: CGFloat,
                   overlayFrame: CGRect?) -> CGRect {

  var preferredLocations = [PopoverLocation]()

  let annotationSize = annotationViewFrame.size
  let spacing: CGFloat = 5
  let annotationCenter = annotationViewFrame.center

  if let listAndSearchOverlayContainerViewFrame = overlayFrame {
    if UIApplication.shared.wmf_isRTL {
      if annotationCenter.x >= listAndSearchOverlayContainerViewFrame.minX {
        preferredLocations = [.bottom, .left, .right, .top]
      } else {
        preferredLocations = [.left, .bottom, .top, .right]
      }
    } else {
      if annotationCenter.x <= listAndSearchOverlayContainerViewFrame.maxX {
        preferredLocations = [.bottom, .right, .left, .top]
      } else {
        preferredLocations = [.right, .bottom, .top, .left]
      }
    }
  }

  let viewBounds = CGRect(origin: .zero, size: viewSize)
  let viewCenter = viewBounds.center
  let navBarHeight = extendedNavBarHeight

  let popoverDistanceFromAnnotationCenterY = 0.5 * annotationSize.height + spacing
  let totalHeight = popoverDistanceFromAnnotationCenterY + popoverSize.height + spacing
  let top = totalHeight - annotationCenter.y
  let bottom = annotationCenter.y + totalHeight - viewSize.height

  let popoverDistanceFromAnnotationCenterX = 0.5 * annotationSize.width + spacing
  let totalWidth = popoverDistanceFromAnnotationCenterX + popoverSize.width + spacing
  let left = totalWidth - annotationCenter.x
  let right = annotationCenter.x + totalWidth - viewSize.width

  var x = annotationCenter.x > viewCenter.x ? viewSize.width - popoverSize.width - spacing : spacing
  var y = annotationCenter.y > viewCenter.y ? viewSize.height - popoverSize.height - spacing : spacing + navBarHeight

  let canFitTopOrBottom = viewSize.width - annotationCenter.x > 0.5*popoverSize.width && annotationCenter.x > 0.5*popoverSize.width
  let fitsTop = top < -navBarHeight && canFitTopOrBottom
  let fitsBottom = bottom < 0 && canFitTopOrBottom

  let canFitLeftOrRight = viewSize.height - annotationCenter.y > 0.5*popoverSize.height && annotationCenter.y - navBarHeight > 0.5*popoverSize.height
  let fitsLeft = left < 0 && canFitLeftOrRight
  let fitsRight = right < 0 && canFitLeftOrRight

  var didFitPreferredLocation = false
  for preferredLocation in preferredLocations {
    didFitPreferredLocation = true
    if preferredLocation == .top && fitsTop {
      x = annotationCenter.x - 0.5 * popoverSize.width
      y = annotationCenter.y - popoverDistanceFromAnnotationCenterY - popoverSize.height
    } else if preferredLocation == .bottom && fitsBottom {
      x = annotationCenter.x - 0.5 * popoverSize.width
      y = annotationCenter.y + popoverDistanceFromAnnotationCenterY
    } else if preferredLocation == .left && fitsLeft {
      x = annotationCenter.x - popoverDistanceFromAnnotationCenterX - popoverSize.width
      y = annotationCenter.y - 0.5 * popoverSize.height
    } else if preferredLocation == .right && fitsRight {
      x = annotationCenter.x + popoverDistanceFromAnnotationCenterX
      y = annotationCenter.y - 0.5 * popoverSize.height
    } else if preferredLocation == .top && top < -navBarHeight {
      y = annotationCenter.y - popoverDistanceFromAnnotationCenterY - popoverSize.height
    } else if preferredLocation == .bottom && bottom < 0 {
      y = annotationCenter.y + popoverDistanceFromAnnotationCenterY
    } else if preferredLocation == .left && left < 0 {
      x = annotationCenter.x - popoverDistanceFromAnnotationCenterX - popoverSize.width
    } else if preferredLocation == .right && right < 0 {
      x = annotationCenter.x + popoverDistanceFromAnnotationCenterX
    } else {
      didFitPreferredLocation = false
    }

    if didFitPreferredLocation {
      break
    }
  }

  if (!didFitPreferredLocation) {
    if (fitsTop || fitsBottom) {
      x = annotationCenter.x - 0.5 * popoverSize.width
      y = annotationCenter.y + (top < bottom ? 0 - popoverDistanceFromAnnotationCenterY - popoverSize.height : popoverDistanceFromAnnotationCenterY)
    } else if (fitsLeft || fitsRight) {
      x = annotationCenter.x + (left < right ? 0 - popoverDistanceFromAnnotationCenterX - popoverSize.width : popoverDistanceFromAnnotationCenterX)
      y = annotationCenter.y - 0.5 * popoverSize.height
    } else if (top < -navBarHeight) {
      y = annotationCenter.y - popoverDistanceFromAnnotationCenterY - popoverSize.height
    } else if (bottom < 0) {
      y = annotationCenter.y + popoverDistanceFromAnnotationCenterY
    } else if (left < 0) {
      x = annotationCenter.x - popoverDistanceFromAnnotationCenterX - popoverSize.width
    } else if (right < 0) {
      x = annotationCenter.x + popoverDistanceFromAnnotationCenterX
    }
  }

  return CGRect(origin: CGPoint(x: x, y: y), size: popoverSize)
}
