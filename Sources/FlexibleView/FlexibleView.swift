import UIKit

public enum FlexibleDimension {
    case absolute(CGFloat)
    case flexible(CGFloat)
    case estimated(CGFloat)

    var isEstimated: Bool {
        if case .estimated = self {
            return true
        }
        return false
    }

    internal func dimension(in containerDimension: CGFloat, intrinsicDimension: CGFloat) -> CGFloat {
        switch self {
        case let .absolute(x):
            return x
        case let .flexible(x):
            return x * containerDimension
        case let .estimated(x):
            return max(x, intrinsicDimension)
        }
    }
}

public enum FlexibleSpacing {
    case fixed(CGFloat)
    case flexible(CGFloat)
    func spacing(in containerDimension: CGFloat) -> CGFloat {
        switch self {
        case let .fixed(x):
            return x
        case let .flexible(x):
            return containerDimension * x
        }
    }
}

public struct FlexibleLayoutSize {
    public var width: FlexibleDimension
    public var height: FlexibleDimension
    public init(width: FlexibleDimension, height: FlexibleDimension) {
        self.width = width
        self.height = height
    }
}

extension FlexibleLayoutSize {
    public init(width: CGFloat, height: CGFloat) {
        self.width = .absolute(width)
        self.height = .absolute(height)
    }
}

public protocol FlexibleItem {
    var layoutSize: FlexibleLayoutSize { get }
}

public extension FlexibleItem where Self: UIView {
    func contentSize(in containerSize: CGSize) -> CGSize {
        let contentSize = intrinsicContentSize
        let width = layoutSize.width.dimension(in: containerSize.width, intrinsicDimension: contentSize.width)
        let height = layoutSize.height.dimension(in: containerSize.height, intrinsicDimension: contentSize.height)
        return CGSize(width: width, height: height)
    }
}

open class FlexibleView: UIView {
    public typealias Item = UIView & FlexibleItem
    public enum HorizontalAlignment {
        case left
        case right
        case center
    }
    public enum VerticalAlignment {
        case top
        case bottom
        case center
    }
    private var contentSize: CGSize = .zero
    open override var intrinsicContentSize: CGSize {
        CGSize(width: super.intrinsicContentSize.width,
               height: contentSize.height)
    }
    open var items = [Item]() {
        didSet {
            applyItemChanges(from: oldValue, to: items)
            setNeedsLayout()
        }
    }
    open var horizontalSpacing: FlexibleSpacing = .fixed(8) {
        didSet {
            setNeedsLayout()
        }
    }
    open var verticalSpacing: FlexibleSpacing = .fixed(8) {
        didSet {
            setNeedsLayout()
        }
    }

    open var rowAlignment: VerticalAlignment = .center {
        didSet {
            setNeedsLayout()
        }
    }

    open var horizentalAlignment: HorizontalAlignment = .left {
        didSet {
            setNeedsLayout()
        }
    }

    open var contentInsets: UIEdgeInsets = .zero {
        didSet {
            setNeedsLayout()
        }
    }

    open func addFlexibleItem(_ item: Item) {
        items.append(item)
    }

    open func insertFlexibleItem(_ item: Item, at index: Int) {
        items.insert(item, at: index)
    }

    open func removeFlexibleItem(_ item: Item) {
        items.removeAll { $0 === item }
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        let size = _layoutItems()
        if contentSize != size {
            contentSize = size
            invalidateIntrinsicContentSize()
        }
    }
}

extension FlexibleView {
    private func applyItemChanges(from old: [Item], to new: [Item]) {
        old.forEach { elt in
            if !new.contains(where: { $0 === elt }) {
                elt.removeFromSuperview()
            }
        }

        new.forEach { elt in
            if !old.contains(where: { $0 === elt }) {
                addSubview(elt)
            }
        }
    }

    @discardableResult
    private func _layoutItems() -> CGSize {
        let x = contentInsets.left
        var y = contentInsets.top
        let width = frame.width - contentInsets.left - contentInsets.right
        let height = frame.width - contentInsets.top - contentInsets.bottom
        let spacingH = horizontalSpacing.spacing(in: width)
        let spacingV = horizontalSpacing.spacing(in: height)
        func createLayoutContext() -> HorizontalLayoutContext {
            HorizontalLayoutContext(origin: CGPoint(x: x, y: y),
                                    availableSize: CGSize(width: width, height: height),
                                    spacing: spacingH,
                                    horizontalAlignment: horizentalAlignment,
                                    rowAlignment: rowAlignment)
        }
        var layout = createLayoutContext()
        for elt in items {
            if layout.attemptToLayoutItem(elt) {
                continue
            } else {
                layout.apply()
                y += layout.height + spacingV
                layout = createLayoutContext()
                layout.attemptToLayoutItem(elt)
            }
        }
        layout.apply()
        return CGSize(width: width, height: y + layout.height + contentInsets.bottom)
    }
}

struct HorizontalLayoutContext {
    var origin: CGPoint
    var availableSize: CGSize
    var spacing: CGFloat
    var horizontalAlignment: FlexibleView.HorizontalAlignment
    var rowAlignment: FlexibleView.VerticalAlignment
    private(set) var height: CGFloat = 0
    private var usedWidth: CGFloat = 0
    private var alignedItems = [(FlexibleView.Item, CGSize)]()

    init(origin: CGPoint,
         availableSize: CGSize,
         spacing: CGFloat,
         horizontalAlignment: FlexibleView.HorizontalAlignment,
         rowAlignment: FlexibleView.VerticalAlignment) {
        self.origin = origin
        self.availableSize = availableSize
        self.spacing = spacing
        self.horizontalAlignment = horizontalAlignment
        self.rowAlignment = rowAlignment
    }

    @discardableResult
    mutating func attemptToLayoutItem(_ item: FlexibleView.Item) -> Bool {
        let itemSize = item.contentSize(in: availableSize)
        guard alignedItems.isEmpty || availableSize.width - usedWidth >= itemSize.width else {
            return false
        }
        alignedItems.append((item, itemSize))
        usedWidth += itemSize.width + spacing
        height = max(itemSize.height, height)
        return true
    }

    func apply() {
        let fy = yCalculator()
        var x = startX()
        for (item, size) in alignedItems {
            let y = fy(size)
            item.frame = CGRect(origin: CGPoint(x: x, y: y), size: size)
            x += size.width + spacing
        }
    }

    private func startX() -> CGFloat {
        switch horizontalAlignment {
        case .left:
            return origin.x
        case .right:
            return availableSize.width - usedWidth - spacing
        case .center:
            return (availableSize.width - usedWidth + spacing) / 2
        }
    }

    private func yCalculator() -> (CGSize) -> CGFloat {
        switch rowAlignment {
        case .top:
            return { _ in
                origin.y
            }
        case .bottom:
            return {
                origin.y + height - $0.height
            }
        case .center:
            return {
                origin.y + (height - $0.height) / 2
            }
        }
    }
}

