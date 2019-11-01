

import UIKit

class GradientView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    private func setupView() {
        autoresizingMask = [.flexibleWidth, .flexibleHeight]

        guard let gradientLayer = self.layer as? CAGradientLayer else {
            return;
        }
        gradientLayer.endPoint = CGPoint(x: 0.9, y: 0)
        gradientLayer.startPoint = CGPoint(x: 0.00, y: 0.9)

        gradientLayer.colors = [ UIColor.init(hexString: "#0589CE").cgColor, UIColor.init(hexString: "#8200ECFE").cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.bounds
    }

    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
}
