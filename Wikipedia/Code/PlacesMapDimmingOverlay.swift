import MapKit

public class PlacesMapDimmingOverlay: NSObject, MKOverlay {
    public var coordinate: CLLocationCoordinate2D
    public var boundingMapRect: MKMapRect

    let color: UIColor
    let alpha: CGFloat
    
    init(color: UIColor, alpha: CGFloat) {
        self.color = color
        self.alpha = alpha
        boundingMapRect = MKMapRectWorld
        coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        super.init()
    }
}


public class PlacesMapDimmingOverlayRenderer: MKOverlayRenderer {
    override public func canDraw(_ mapRect: MKMapRect, zoomScale: MKZoomScale) -> Bool {
        return true
    }
    
    
    override public func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        guard let dimmingOverlay = overlay as? PlacesMapDimmingOverlay else {
            return
        }
        context.saveGState()
        context.setFillColor(dimmingOverlay.color.cgColor)
        context.setAlpha(dimmingOverlay.alpha)
        context.setBlendMode(.multiply)
        context.fill(rect(for: mapRect))
        context.restoreGState()
    }
}
