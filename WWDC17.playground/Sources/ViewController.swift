import Foundation
import UIKit

public class ViewController: UIViewController {
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.frame = CGRect(x: 0, y: 0, width: 430, height: self.view.bounds.size.height)
        self.view.backgroundColor = UIColor.white
        addBackground()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        addView()
    }
    
    private func addBackground() {
        let blur = UIBlurEffect(style: .extraLight)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.alpha = 0.9
        blurView.frame = self.view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(blurView)
        let background = UIImageView(image: UIImage(named: "WWDC17 - bg.png"))
        background.frame = self.view.frame
        background.contentMode = .scaleAspectFill
        self.view.addSubview(background)
        self.view.sendSubview(toBack: background)
        self.view.insertSubview(blurView, aboveSubview: background)
    }
    
    private func addView() {
        let wwdcView = View()
        wwdcView.layer.frame = CGRect(x: 0, y: 0, width: 430, height: 280)
        self.view.addSubview(wwdcView)
        wwdcView.translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstraint = NSLayoutConstraint(item: wwdcView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: wwdcView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0)
        let widthConstraint = NSLayoutConstraint(item: wwdcView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 430)
        let heightConstraint = NSLayoutConstraint(item: wwdcView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 280)
        self.view.addConstraints([horizontalConstraint, bottomConstraint, widthConstraint, heightConstraint])
    }
}
