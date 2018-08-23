import UIKit

@objc(WMFToolbar)
class Toolbar: SetupView {
    private let toolbar: UIToolbar = UIToolbar()
    private let homeIndicatorUnderlayView: UIView = UIView()
    
    override func setup() {
        super.setup()
        
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        homeIndicatorUnderlayView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(toolbar)
        addSubview(homeIndicatorUnderlayView)

        let toolbarTop = topAnchor.constraint(equalTo: toolbar.topAnchor)
        let toolbarBottom = toolbar.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        let toolbarLeading = leadingAnchor.constraint(equalTo: toolbar.leadingAnchor)
        let toolbarTrailing = toolbar.trailingAnchor.constraint(equalTo: trailingAnchor)
        
        let underlayTop = layoutMarginsGuide.bottomAnchor.constraint(equalTo: homeIndicatorUnderlayView.topAnchor)
        let underlayBottom = homeIndicatorUnderlayView.bottomAnchor.constraint(equalTo: bottomAnchor)
        let underlayLeading = leadingAnchor.constraint(equalTo: homeIndicatorUnderlayView.leadingAnchor)
        let underlayTrailing = homeIndicatorUnderlayView.trailingAnchor.constraint(equalTo: trailingAnchor)
        
        addConstraints([toolbarTop, toolbarBottom, toolbarLeading, toolbarTrailing, underlayTop, underlayBottom, underlayLeading, underlayTrailing])
    }
    
    @objc var items: [UIBarButtonItem]? {
        get {
            return self.toolbar.items
        }
        set {
            self.toolbar.items = newValue
        }
    }
    
}


extension Toolbar: Themeable {
    public func apply(theme: Theme) {
        toolbar.barTintColor = theme.colors.chromeBackground
        toolbar.isTranslucent = false
        homeIndicatorUnderlayView.backgroundColor = theme.colors.chromeBackground
    }
}
