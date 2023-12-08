import Foundation
import UIKit
import FSCalendar

enum SelectionType : Int {
    case none
    case single
    case leftBorder
    case middle
    case rightBorder
}

class DIYCalendarCell: FSCalendarCell {
    
    weak var selectionLayer: CAShapeLayer!
    
    var selectionType: SelectionType = .none {
        didSet {
            setNeedsLayout()
        }
    }
    
    required init!(coder aDecoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupObjects()
    }
    
    private func setupObjects() {
        
        let selectionLayer = CAShapeLayer()
        selectionLayer.fillColor = UIColor.blue.cgColor
        selectionLayer.actions = ["hidden": NSNull()]
        
        self.contentView.layer.insertSublayer(selectionLayer, below: self.titleLabel!.layer)
        self.selectionLayer = selectionLayer
        
        self.shapeLayer.isHidden = true
        self.eventIndicator.isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.backgroundView?.frame = self.bounds.insetBy(dx: 1, dy: 1)
        self.selectionLayer.frame = self.contentView.bounds
        
        self.eventIndicator.isHidden = true
        
        let diameter: CGFloat = min(self.selectionLayer.frame.height, self.selectionLayer.frame.width)
        let middleRect = CGRect(x: self.contentView.frame.width / 2 - diameter / 2,
                                y: self.contentView.frame.height / 2 - diameter / 2,
                                width: diameter, height: diameter)
        
        if selectionType == .middle {
            let path = UIBezierPath(rect: self.selectionLayer.bounds)
            
            self.selectionLayer.path = path.cgPath
            self.selectionLayer.fillColor = UIColor.blue.cgColor
            self.titleLabel.textColor = .black
            
            // Add rounded corners to the start and end of the row
            
            let cornerRadius: CGFloat = self.selectionLayer.frame.height/2
            
            if self.frame.minX == self.superview?.subviews.first?.frame.minX {
                let maskLayer = CAShapeLayer()
                maskLayer.frame = self.bounds
                maskLayer.path = UIBezierPath(roundedRect: maskLayer.bounds, byRoundingCorners: [.bottomLeft, .topLeft], cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
                self.layer.mask = maskLayer
            } else if self.frame.maxX == self.superview?.subviews.last?.frame.maxX {
                let maskLayer = CAShapeLayer()
                maskLayer.frame = self.bounds
                maskLayer.path = UIBezierPath(roundedRect: maskLayer.bounds, byRoundingCorners: [.bottomRight, .topRight], cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
                self.layer.mask = maskLayer
            } else {
                self.layer.mask = nil
            }
        }
        
        else if (selectionType == .rightBorder || selectionType == .leftBorder) {
            let path = UIBezierPath(roundedRect: self.selectionLayer.bounds, cornerRadius: self.selectionLayer.bounds.size.height/2)
            self.selectionLayer.path = path.cgPath
            self.selectionLayer.fillColor = UIColor.black.withAlphaComponent(0.8).cgColor
            self.titleLabel.textColor = .white
            
            // Remove rounded corners from the start and end of the row
            self.layer.mask = nil
        }
        
        else if selectionType == .single {
            self.selectionLayer.path = UIBezierPath(ovalIn: middleRect).cgPath
            self.selectionLayer.fillColor = UIColor.black.withAlphaComponent(0.8).cgColor
            self.titleLabel.textColor = .white
        }
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        if self.isPlaceholder {
            self.eventIndicator.isHidden = true
            self.titleLabel.textColor = UIColor.lightGray
            self.titleLabel.backgroundColor = .clear
        }
    }
    
}
