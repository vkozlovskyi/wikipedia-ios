import UIKit

@objc(WMFToolbar)
class Toolbar: SetupView {
    private let toolbar: UIToolbar = UIToolbar()
    private let stackView: UIStackView = UIStackView()
    
    override func setup() {
        super.setup()
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stackView)
        addSubview(toolbar)
        
        let svTop = topAnchor.constraint(equalTo: stackView.topAnchor)
        let svLeading = leadingAnchor.constraint(equalTo: leadingAnchor)
        let svTrailing = trailingAnchor.constraint(equalTo: trailingAnchor)
        
        let toolbarTop = stackView.bottomAnchor.constraint(equalTo: toolbar.topAnchor)
        let toolbarBottom = toolbar.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        let toolbarLeading = leadingAnchor.constraint(equalTo: toolbar.leadingAnchor)
        let toolbarTrailing = toolbar.trailingAnchor.constraint(equalTo: trailingAnchor)
        
        addConstraints([svTop, svLeading, svTrailing, toolbarTop, toolbarBottom, toolbarLeading, toolbarTrailing])
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
