//
//  ViewController.swift
//  FSCalanderDemo
//
//  Created by Tannu Kaushik on 17/05/23.
//

import UIKit
import FSCalendar

class ViewController: UIViewController {
    @IBOutlet weak var calendar: FSCalendar!
    
    var dateFormatter: DateFormatter!
    private var firstDate: Date?
    private var lastDate: Date?
    private var datesRange: [Date]?
    fileprivate let gregorian = Calendar(identifier: .gregorian)
    
    fileprivate let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        formatter.locale = Locale(identifier: "en_IN")
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.viewDidLoad()
               setupNavigationBar()
               setupViews()
               setupConstraints()
        
    }
    private func setupNavigationBar() {
           navigationItem.backBarButtonItem = UIBarButtonItem(title: "",style: .plain,target: nil,action: nil)
       }
       
       private func setupViews() {
           view.backgroundColor = .white
           
           let calendar = FSCalendar()
           calendar.dataSource = self
           calendar.delegate = self
           
           calendar.translatesAutoresizingMaskIntoConstraints = false
           calendar.allowsSelection = true
           calendar.allowsMultipleSelection = true
           calendar.swipeToChooseGesture.isEnabled = false
           calendar.pagingEnabled = false

           calendar.today = nil

           calendar.scrollDirection = .vertical
           calendar.appearance.borderRadius = 0
           calendar.rowHeight = 40

           calendar.register(DIYCalendarCell.self, forCellReuseIdentifier: "cell")
                   
           let scopeGesture = UIPanGestureRecognizer(target: calendar, action: #selector(calendar.handleScopeGesture(_:)));
           calendar.addGestureRecognizer(scopeGesture)
           
           view.addSubview(calendar)
           self.calendar = calendar
       }
       
       private func setupConstraints() {
           NSLayoutConstraint.activate([
               self.calendar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor , constant: 25),
               self.calendar.leftAnchor.constraint(equalTo: view.leftAnchor , constant: 20),
               self.calendar.rightAnchor.constraint(equalTo: view.rightAnchor , constant: -25),
               self.calendar.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height)
           ])
       }
       
       
       // MARK: - Private functions
       
       func datesRange(from: Date, to: Date) -> [Date] {
           // in case of the "from" date is more than "to" date,
           // it should returns an empty array:
           
           if from > to {
               return [Date]()
           }
           
           var tempDate = from
           var array = [tempDate]
           
           while tempDate < to {
               tempDate = Calendar.current.date(byAdding: .day, value: 1, to: tempDate)!
               array.append(tempDate)
           }
           
           return array
       }
       
       private func configureVisibleCells() {
           calendar.visibleCells().forEach { (cell) in
               let date = calendar.date(for: cell)
               let position = calendar.monthPosition(for: cell)
               self.configure(cell: cell, for: date!, at: position)
           }
       }
       
       private func configure(cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
           
           let diyCell = (cell as! DIYCalendarCell)
           // Configure selection layer
           if position == .current {
               
               var selectionType = SelectionType.none
               
               if calendar.selectedDates.contains(date) {
                   let previousDate = self.gregorian.date(byAdding: .day, value: -1, to: date)!
                   let nextDate = self.gregorian.date(byAdding: .day, value: 1, to: date)!
                   if calendar.selectedDates.contains(date) {
                       if calendar.selectedDates.contains(previousDate) && calendar.selectedDates.contains(nextDate) {
                           selectionType = .middle
                       }
                       else if calendar.selectedDates.contains(previousDate) && calendar.selectedDates.contains(date) {
                           selectionType = .rightBorder
                       }
                       else if calendar.selectedDates.contains(nextDate) {
                           selectionType = .leftBorder
                       }
                       else {
                           selectionType = .single
                       }
                   }
               }
               else {
                   selectionType = .none
               }
               if selectionType == .none {
                   diyCell.selectionLayer.isHidden = true
                   return
               }
               diyCell.selectionLayer.isHidden = false
               diyCell.selectionType = selectionType
               
           } else {
               diyCell.selectionLayer.isHidden = true
           }
       }
}


extension ViewController:  FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "cell", for: date, at: position)
        return cell
    }
    
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
        self.configure(cell: cell, for: date, at: position)
    }
    
    func calendar(_ calendar: FSCalendar, titleFor date: Date) -> String? {
        return nil
    }
    
    //MARK:- FSCalendarDelegate
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendar.frame.size.height = bounds.height
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition)   -> Bool {
        return monthPosition == .current
    }
    
    func calendar(_ calendar: FSCalendar, shouldDeselect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        return monthPosition == .current
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if firstDate == nil {
            firstDate = date
            datesRange = [firstDate!]
            
            print("datesRange contains: \(datesRange!)")
            self.configureVisibleCells()
            return
        }
        
        // only first date is selected:
        if firstDate != nil && lastDate == nil {
            // handle the case of if the last date is less than the first date:
            if date <= firstDate! {
                calendar.deselect(firstDate!)
                firstDate = date
                datesRange = [firstDate!]
                
                print("datesRange contains: \(datesRange!)")
                self.configureVisibleCells()
                return
            }
            
            
            let range = datesRange(from: firstDate!, to: date)
            
            lastDate = range.last
            
            for d in range {
                calendar.select(d)
            }
            
            datesRange = range
            self.configureVisibleCells()
            
            return
        }
        
        // both are selected:
        if firstDate != nil && lastDate != nil {
            for d in calendar.selectedDates {
                calendar.deselect(d)
            }
            
            lastDate = nil
            firstDate = nil
            
            datesRange = []
            
            print("datesRange contains: \(datesRange!)")
        }
        
        self.configureVisibleCells()
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date) {
        // NOTE: the is a REDUANDENT CODE:
        if firstDate != nil && lastDate != nil {
            
            for d in calendar.selectedDates {
                calendar.deselect(d)
            }
            
            lastDate = nil
            firstDate = nil
            
            datesRange = []
            print("datesRange contains: \(datesRange!)")
        }
        
        if (firstDate != nil && lastDate == nil) {
            lastDate = firstDate
            
            var range = datesRange(from: firstDate!, to: firstDate!)
            if (range.count >= 1) {
                range.append(range[0])
            }
            
            lastDate = range.last
            
            for d in range {
                calendar.select(d)
            }
            
            datesRange = range
            print("datesRange contains: \(datesRange!)")
            
        }
        
        self.configureVisibleCells()
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        if self.gregorian.isDateInToday(date) {
            return [UIColor.yellow]
        }
        return [appearance.eventDefaultColor]
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return 0
    }

}
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
        selectionLayer.fillColor = #colorLiteral(red: 0.335983634, green: 0.6562511921, blue: 0.6330097318, alpha: 0.1472886446)
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
            self.selectionLayer.fillColor = #colorLiteral(red: 0.335983634, green: 0.6562511921, blue: 0.6330097318, alpha: 0.1472886446)
            self.titleLabel.textColor = .black
            
            // Add rounded corners to the start and end of the row
            
            let cornerRadius: CGFloat = 4
            
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
            let path = UIBezierPath(roundedRect: self.selectionLayer.bounds, cornerRadius: 4)
            self.selectionLayer.path = path.cgPath
            self.selectionLayer.fillColor = #colorLiteral(red: 0.335983634, green: 0.6562511921, blue: 0.6330097318, alpha: 1)
            self.titleLabel.textColor = .white
            
            // Remove rounded corners from the start and end of the row
            self.layer.mask = nil
        }
        
        else if selectionType == .single {
            self.selectionLayer.path = UIBezierPath(ovalIn: middleRect).cgPath
            self.selectionLayer.fillColor = #colorLiteral(red: 0.335983634, green: 0.6562511921, blue: 0.6330097318, alpha: 1)
            self.selectionLayer.cornerRadius = 4
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
