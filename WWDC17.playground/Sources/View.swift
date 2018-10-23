import Foundation
import UIKit
import AVFoundation

public class View: UIView {
    
    private var animator: UIDynamicAnimator?
    private var snapBehavior: UISnapBehavior?
    private var isHolding = false
    private var unplacedPeople = [NSDictionary]()
    private var currentIndex = 25
    private let basePosition = CGPoint(x: 215, y: 205)
    private var currentImage = UIImageView()
    private var imageViews = [UIImageView]()
    private var currentPerson = NSDictionary()
    private var background = UIImageView()
    private var wwdcLogo = UIImageView()
    private var timeLabel = UILabel()
    private var timer = Timer()
    private var timeCounter = CGFloat()
    private var started = false
    private var animationTimer = Timer()
    private let fireworkEmitter = CAEmitterLayer()
    private let fireworkCell = CAEmitterCell()
    private var fireworkTimer = Timer()
    private var removeFireworkTimer = Timer()
    private var stoppedFirework = false
    private var confettiEmitter = CAEmitterLayer()
    private var player: AVAudioPlayer?
    private var colorArray = [UIColor.blue, UIColor.brown, UIColor.cyan, UIColor.green, UIColor.magenta, UIColor.orange, UIColor.purple, UIColor.red, UIColor.yellow]
    
    public init() {
        animationTimer.invalidate()
        unplacedPeople = people
        background = UIImageView(image: UIImage(named: "WWDC17 - img - grayed.png"))
        super.init(frame: CGRect(x: 0, y: 0, width: 430, height: 280))
        self.isUserInteractionEnabled = true
        animator = UIDynamicAnimator(referenceView: self)
        backgroundColor = UIColor.clear
        background.frame = self.frame
        addSubview(background)
        addWhiteView()
        addTimeLabel()
        addImage()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addWhiteView() {
        let whiteView = UIView(frame: CGRect(x: 0, y: -20, width: self.frame.size.width, height: self.frame.size.height + 20))
        whiteView.backgroundColor = .white
        self.addSubview(whiteView)
        self.sendSubview(toBack: whiteView)
    }

    private func addTimeLabel() {
        timeLabel.text = "Drag people/person to the right position"
        timeLabel.numberOfLines = 2
        timeLabel.textAlignment = .center
        timeLabel.sizeToFit()
        addSubview(timeLabel)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstraint = NSLayoutConstraint(item: timeLabel, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: timeLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -10)
        let widthConstraint = NSLayoutConstraint(item: timeLabel, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 200)
        self.addConstraints([horizontalConstraint, bottomConstraint, widthConstraint])
    }
    
    private func addImage() {
        let random = arc4random_uniform(UInt32(currentIndex))
        currentIndex -= 1
        let person = unplacedPeople[Int(random)]
        currentPerson = person
        let imageView = UIImageView(image: person.value(forKey: "image") as! UIImage?)
        imageView.layer.position = CGPoint(x: 215, y: 325)
        addSubview(imageView)
        imageViews.append(imageView)
        unplacedPeople.remove(at: Int(random))
        currentImage = imageViews.last!
        self.isUserInteractionEnabled = true
        UIView.animate(withDuration: 0.75) {
            imageView.layer.position = self.basePosition
        }
    }
    
    //MARK: Touch Handling
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: self)
            if (currentImage.frame.contains(touchLocation)) {
                isHolding = true
                snapBehavior = UISnapBehavior(item: currentImage, snapTo: touchLocation)
                animator?.addBehavior(snapBehavior!)
                if started == false {
                    timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
                    started = true
                }
            }
        }
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: self)
            if let snapBehavior = snapBehavior {
                snapBehavior.snapPoint = touchLocation
            }
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let snapBehavior = snapBehavior {
            animator?.removeBehavior(snapBehavior)
        }
        snapBehavior = nil
        if let touch = touches.first {
            let touchLocation = touch.location(in: self)
            let imageLocation = currentPerson.value(forKey: "position") as! CGPoint
            if touchLocation.x > imageLocation.x - 10 && touchLocation.x < imageLocation.x + 10 && touchLocation.y > imageLocation.y - 10 && touchLocation.y < imageLocation.y + 10 {
                if isHolding {
                    self.isUserInteractionEnabled = false
                    let position = self.currentPerson.value(forKey: "position") as! CGPoint
                    self.launchFirework(at: position)
                    UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
                        self.currentImage.layer.position = imageLocation
                    }, completion: { (success) in
                        if self.unplacedPeople.isEmpty == false {
                            self.addImage()
                        } else {
                            self.isUserInteractionEnabled = false
                            self.timer.invalidate()
                            self.timeCounter = 0
                            self.startTheShow()
                        }
                    })
                }
            } else {
                if isHolding {
                    playSound("WrongPlacement", loop: false)
                }
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                    self.currentImage.layer.position = self.basePosition
                }, completion: nil)
            }
        }
        isHolding = false
    }
    
    @objc func updateTime() {
        timeCounter = timeCounter + 0.1
        timeLabel.text = "Time: " + String(format: "%.1f", timeCounter)
    }
    
    private func startTheShow() {
        self.wwdcLogo.image = UIImage(named: "Logo.png")
        self.wwdcLogo.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.wwdcLogo.layer.position = CGPoint(x: 215, y: 320)
        self.wwdcLogo.frame.size = CGSize(width: 144, height: 28)
        self.addSubview(self.wwdcLogo)
        self.wwdcLogo.alpha = 0
        UIView.animate(withDuration: 1, animations: {
            self.wwdcLogo.alpha = 1
            self.wwdcLogo.layer.position = self.basePosition
        }, completion: { (success) in
            self.background.image = UIImage(named: "WWDC17 - img - empty")
            self.playSound("Soundtrack", loop: true)
            self.fallConfetti()
            self.animatePeople()
        })
    }
    
    private func animatePeople() {
        animationTimer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(updatePeopleAnimation), userInfo: nil, repeats: true)
    }
    
    @objc func updatePeopleAnimation() {
        for image in imageViews {
            var pi = Double.pi/4
            let random = arc4random_uniform(2)
            if random == 0 {
                pi = Double.pi/4
            } else {
                pi = -Double.pi/4
            }
            UIView.animate(withDuration: 0.25, animations: {
                image.transform = image.transform.rotated(by: CGFloat(pi))
            })
        }
    }
    
    private func launchFirework(at position: CGPoint) {
        playSound("RightPlacement", loop: false)
        let random = arc4random_uniform(UInt32(colorArray.count))
        let randomColor = colorArray[Int(random)]
        fireworkEmitter.birthRate = 1
        fireworkCell.birthRate = 20000
        fireworkEmitter.emitterPosition = position
        fireworkEmitter.frame = self.bounds
        fireworkEmitter.renderMode = kCAEmitterLayerAdditive
        fireworkCell.lifetime = 0.5
        fireworkCell.color = randomColor.cgColor
        fireworkCell.velocity = 100
        fireworkCell.emissionLongitude = 2 * CGFloat.pi
        fireworkCell.emissionRange = 2 * CGFloat.pi
        fireworkCell.spin = 2
        fireworkCell.spinRange = 3
        fireworkCell.contents = UIImage(named: "SmallSquare")?.cgImage
        fireworkEmitter.emitterCells = [fireworkCell]
        self.layer.addSublayer(fireworkEmitter)
        fireworkTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(stopFirework), userInfo: nil, repeats: false)
    }
    
    @objc func stopFirework() {
        fireworkEmitter.birthRate = 0
        fireworkCell.birthRate = 0
        fireworkTimer.invalidate()
        removeFireworkTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(removeFirework), userInfo: nil, repeats: false)
    }
    
    @objc func removeFirework() {
        fireworkEmitter.removeFromSuperlayer()
        removeFireworkTimer.invalidate()
    }
    
    private func fallConfetti() {
        var colors = [CAEmitterCell]()
        let vc = ViewController()
        let height = vc.view.frame.size.height
        let y = -(height - 280)
        confettiEmitter.emitterPosition = CGPoint(x: self.bounds.size.width/2, y: y)
        confettiEmitter.emitterShape = kCAEmitterLayerLine
        confettiEmitter.emitterSize = CGSize(width: self.bounds.size.width, height: 1)
        for color in colorArray {
            colors.append(confettiCell(color: color))
        }
        confettiEmitter.emitterCells = colors
        self.layer.addSublayer(confettiEmitter)
    }
    
    private func confettiCell(color: UIColor) -> CAEmitterCell {
        let cell = CAEmitterCell()
        cell.birthRate = 4
        cell.lifetime = 8
        cell.color = color.cgColor
        cell.velocity = 200
        cell.velocityRange = 50
        cell.emissionLongitude = CGFloat.pi
        cell.emissionRange = CGFloat.pi/8
        cell.spin = 0
        cell.spinRange = 20
        cell.scale = 5
        cell.scaleRange = 1
        cell.scaleSpeed = -0.05
        cell.contents = UIImage(named: "SmallRectangle")?.cgImage
        return cell
    }
    
    private func playSound(_ name: String, loop: Bool) {
        let url = Bundle.main.url(forResource: name, withExtension: "wav")!
        do {
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            if loop {
                player.numberOfLoops = -1
            } else {
                player.numberOfLoops = 0
            }
            player.prepareToPlay()
            player.play()
        } catch let error as NSError {
            print(error.description)
        }
    }
}
