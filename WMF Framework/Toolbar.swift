import UIKit

@objc(WMFToolbar)
class Toolbar: SetupView {
    private let toolbar: UIToolbar = UIToolbar()
    
    override func setup() {
        super.setup()
        
        toolbar.translatesAutoresizingMaskIntoConstraints = false

        addSubview(toolbar)

        let toolbarTop = topAnchor.constraint(equalTo: toolbar.topAnchor)
        let toolbarBottom = toolbar.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        let toolbarLeading = leadingAnchor.constraint(equalTo: toolbar.leadingAnchor)
        let toolbarTrailing = toolbar.trailingAnchor.constraint(equalTo: trailingAnchor)
        addConstraints([toolbarTop, toolbarBottom, toolbarLeading, toolbarTrailing])
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
    }
}
