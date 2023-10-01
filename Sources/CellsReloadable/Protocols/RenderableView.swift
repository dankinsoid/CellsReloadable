import UIKit

public protocol RenderableView: UIView {
    
    associatedtype Props
    func render(with props: Props)
}
