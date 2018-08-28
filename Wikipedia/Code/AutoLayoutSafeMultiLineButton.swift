
// See multi-line button thread: https://stackoverflow.com/q/23845982/135557
@IBDesignable
class AutoLayoutSafeMultiLineButton: UIButton {
    func multiLineSafeSetup () {
        titleLabel?.numberOfLines = 0
        titleLabel?.lineBreakMode = .byWordWrapping
        titleLabel?.adjustsFontSizeToFitWidth = false
        setContentHuggingPriority(.defaultLow + 1, for: .vertical)
        setContentHuggingPriority(.defaultLow + 1, for: .horizontal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        multiLineSafeSetup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        multiLineSafeSetup()
    }
    
    override var intrinsicContentSize: CGSize {
        let superSize = super.intrinsicContentSize
        guard let titleLabel = titleLabel else {
            return superSize
        }
        var additionalWidth = contentEdgeInsets.left + contentEdgeInsets.right + titleEdgeInsets.left + titleEdgeInsets.right
        let additionalHeight = contentEdgeInsets.top + contentEdgeInsets.bottom + titleEdgeInsets.top + titleEdgeInsets.bottom
        var imageHeight: CGFloat = 0
        if let image = image(for: .normal) {
            additionalWidth += image.size.width + imageEdgeInsets.left + imageEdgeInsets.right
            imageHeight = image.size.height + imageEdgeInsets.top + imageEdgeInsets.bottom + contentEdgeInsets.top + contentEdgeInsets.bottom
        }
        let titleLabelAvailableWidth = superSize.width - additionalWidth
        titleLabel.preferredMaxLayoutWidth = titleLabelAvailableWidth
        let labelIntrinsicSize = titleLabel.intrinsicContentSize
        var totalSize = CGSize(width: labelIntrinsicSize.width + additionalWidth, height: labelIntrinsicSize.height + additionalHeight)
        totalSize.height = max(imageHeight, totalSize.height)
        return totalSize
    }

}
