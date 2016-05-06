//
//  TwoOptionsQuestionView.swift
//
//  Created by Arjan on 25/04/16.
//

import UIKit

protocol TwoOptionsQuestionViewDelegate {
    //func optionsOfMultipleOptionsQuestionView(multipleOptionsQuestionView: TwoOptionsQuestionView) -> [String]
    
    /**
     Called when an option is chosen. Gives delegate the opportunity to handle the result
     */
    func choseOptionWithTitle(title: String?, ofTwoOptionsQuestionView view: TwoOptionsQuestionView)
    func colorForSelectedOptionWithTitle(title: String?, ofTwoOptionsQuestionView view: TwoOptionsQuestionView) -> UIColor?
    func colorForUnSelectedOptionWithTitle(title: String?, ofTwoOptionsQuestionView view: TwoOptionsQuestionView) -> UIColor?
    
    /**
     This method is called when there is a detail disclosure button added (see `init` method), and a TouchUpInside event has been triggered. Use it to e.g. show a popup with information about the question.
     */
    func touchedDetailDisclosureButtonOfTwoOptionsQuestionView(twoOptionsQuestionView: TwoOptionsQuestionView)
}

/**
 `TwoOptionsQuestionView` is a UIView that can hold an informative text or question,
 and two options (`UIButton`s)
 
 - note: Use `required convenience init(leftOptionTitle: String, rightOptionTitle: String, delegate: TwoOptionsQuestionViewDelegate)`
 
 - Requires: Both options should have a title. set `leftOptionTitle` and `rightOptionTitle`
 */
class TwoOptionsQuestionView: UIView {
    private let questionLabel: UILabel = UILabel()
    private let horizontalDivider: UIView = UIView()
    private let verticalDivider: UIView = UIView()
    private(set) var leftOption: UIButton = UIButton(type: .System)
    private(set) var rightOption: UIButton = UIButton(type: .System)
    private let detailDisclosureButton: UIButton = UIButton(type: UIButtonType.DetailDisclosure)
    private var showDetailDisclosureButton: Bool = false
    var delegate: TwoOptionsQuestionViewDelegate?
    
    var title: String? { get { return questionLabel.text } set { questionLabel.text = newValue } }
    private var leftOptionTitle: String? { get { return leftOption.currentTitle } set { leftOption.setTitle(newValue, forState: .Normal) } }
    private var rightOptionTitle: String? { get { return rightOption.currentTitle } set { rightOption.setTitle(newValue, forState: .Normal) } }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /**
     - parameter inputFieldPlaceholder: placeholder text if no answer is given yet
     */
    required convenience init(leftOptionTitle: String,
                              rightOptionTitle: String,
                              showDetailDisclosureButton: Bool,
                              delegate: TwoOptionsQuestionViewDelegate) {
        self.init(frame: CGRect())
        self.delegate = delegate
        
        self.leftOptionTitle = leftOptionTitle
        self.rightOptionTitle = rightOptionTitle
        
        if leftOptionTitle == rightOptionTitle {
            logthis("equal left and right option titles will cause unexpected behaviour.")
        }
        
        self.showDetailDisclosureButton = showDetailDisclosureButton
        
        setOptionInfo(rightOption) // TODO: is double..
        setOptionInfo(leftOption) // TODO: is double..
        
        setup()
    }
    
    private func setup() {
        setLabelInfo()
        addSubview(questionLabel)
        
        setHorizontalDividerInfo()
        addSubview(horizontalDivider)
        
        leftOptionTitle = "Ja"
        setOptionInfo(leftOption)
        addSubview(leftOption)
        
        rightOptionTitle = "Nee"
        setOptionInfo(rightOption)
        addSubview(rightOption)
        
        setVerticalDividerInfo()
        addSubview(verticalDivider)
        
        if showDetailDisclosureButton {
            setDetailDisclosureButtonInfo()
            addSubview(detailDisclosureButton)
        }
    }
    
    func selectOptionWithTitle(title: String?) {
        if title == leftOptionTitle {
            leftOption.selected = true
            counterPartOfOption(leftOption)!.selected = false
        } else if title == rightOptionTitle {
            rightOption.selected = true
            counterPartOfOption(rightOption)!.selected = false
        } else {
            logthis("title not present")
        }
    }
    
    private func counterPartOfOption(option: UIButton) -> UIButton? {
        if option == leftOption {
            return rightOption
        } else if option == rightOption {
            return leftOption
        } else {
            logthis("shouldnt happen")
            return nil
        }
    }
    
    func optionChosen(sender: UIButton) {
        delegate?.choseOptionWithTitle(sender.currentTitle, ofTwoOptionsQuestionView: self)
        selectOptionWithTitle(sender.currentTitle)
    }
    
    private func setOptionInfo(option: UIButton) {
        option.translatesAutoresizingMaskIntoConstraints = false
        option.titleLabel?.adjustsFontSizeToFitWidth = true
        option.titleLabel?.minimumScaleFactor = 0.5
        option.titleLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody).fontWithSize(24)
        
        option.setTitleColor(delegate?.colorForSelectedOptionWithTitle(option.currentTitle, ofTwoOptionsQuestionView: self) ?? UIColor(white: 0.3, alpha: 1), forState: .Selected)
        option.setTitleColor(delegate?.colorForUnSelectedOptionWithTitle(option.currentTitle, ofTwoOptionsQuestionView: self) ?? UIColor(white: 0.3, alpha: 1), forState: .Normal)
        
        option.tintColor = UIColor.clearColor()
        
        if !option.allTargets().contains(self) {
            option.addTarget(self, action: "optionChosen:", forControlEvents: .TouchUpInside)
        }
    }
    
    private func setLabelInfo() {
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        questionLabel.numberOfLines = 0
        questionLabel.textAlignment = .Center
    }
    
    private func setHorizontalDividerInfo() {
        horizontalDivider.translatesAutoresizingMaskIntoConstraints = false
        //divider.backgroundColor = UIColor.brownColor()
    }
    
    private func setVerticalDividerInfo() {
        verticalDivider.backgroundColor = UIColor(white: 0.9, alpha: 1)
        verticalDivider.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setDetailDisclosureButtonInfo() {
        if !detailDisclosureButton.allTargets().contains(self) {
            detailDisclosureButton.addTarget(self, action: "touchedDetailDisclosureButton:", forControlEvents: .TouchUpInside)
        }
        detailDisclosureButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func touchedDetailDisclosureButton(sender: UIButton) {
        delegate?.touchedDetailDisclosureButtonOfTwoOptionsQuestionView(self)
    }
    
    
    var didSetConstraints = false
    override func updateConstraints() {
        if !didSetConstraints {
            
            // someLabel constraints
            self.addConstraint(NSLayoutConstraint(item: questionLabel, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: 0))
            self.addConstraint(NSLayoutConstraint(item: questionLabel, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: 0))
            self.addConstraint(NSLayoutConstraint(item: questionLabel, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0))
            
            if showDetailDisclosureButton
            {
                self.addConstraint(NSLayoutConstraint(item: questionLabel, attribute: .Bottom, relatedBy: .Equal, toItem: detailDisclosureButton, attribute: .Top, multiplier: 1, constant: 0))
                
                // questionInfoButton constraints
                self.addConstraint(NSLayoutConstraint(item: detailDisclosureButton, attribute: .Top, relatedBy: .Equal, toItem: questionLabel, attribute: .Bottom, multiplier: 1, constant: 0))
                self.addConstraint(NSLayoutConstraint(item: detailDisclosureButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 0, constant: 48))
                self.addConstraint(NSLayoutConstraint(item: detailDisclosureButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 0, constant: 48))
                //self.addConstraint(NSLayoutConstraint(item: questionInfoButton, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: -16))
                self.addConstraint(NSLayoutConstraint(item: detailDisclosureButton, attribute: .CenterX, relatedBy: .Equal, toItem: questionLabel, attribute: .CenterX, multiplier: 1, constant: 0))
                
                // divider constraints
                self.addConstraint(NSLayoutConstraint(item: horizontalDivider, attribute: .Top, relatedBy: .Equal, toItem: detailDisclosureButton, attribute: .Bottom, multiplier: 1, constant: 0))
            }
            else
            {
                self.addConstraint(NSLayoutConstraint(item: questionLabel, attribute: .Bottom, relatedBy: .Equal, toItem: horizontalDivider, attribute: .Top, multiplier: 1, constant: 0))
                self.addConstraint(NSLayoutConstraint(item: horizontalDivider, attribute: .Top, relatedBy: .Equal, toItem: questionLabel, attribute: .Bottom, multiplier: 1, constant: 0))
                
            }
                
            self.addConstraint(NSLayoutConstraint(item: horizontalDivider, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: 0))
            self.addConstraint(NSLayoutConstraint(item: horizontalDivider, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: 0))
            self.addConstraint(NSLayoutConstraint(item: horizontalDivider, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 0, constant: 8))
            self.addConstraint(NSLayoutConstraint(item: horizontalDivider, attribute: .Bottom, relatedBy: .Equal, toItem: leftOption, attribute: .Top, multiplier: 1, constant: 0))
            
            // left option constraints
            self.addConstraint(NSLayoutConstraint(item: leftOption, attribute: .Top, relatedBy: .Equal, toItem: horizontalDivider, attribute: .Bottom, multiplier: 1, constant: 0))
            self.addConstraint(NSLayoutConstraint(item: leftOption, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: 0))
            self.addConstraint(NSLayoutConstraint(item: leftOption, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 0.5, constant: -1))
            self.addConstraint(NSLayoutConstraint(item: leftOption, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 0, constant: 100))
            self.addConstraint(NSLayoutConstraint(item: leftOption, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0))
            
            // right option constraints
            self.addConstraint(NSLayoutConstraint(item: rightOption, attribute: .Top, relatedBy: .Equal, toItem: horizontalDivider, attribute: .Bottom, multiplier: 1, constant: 0))
            self.addConstraint(NSLayoutConstraint(item: rightOption, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: 0))
            self.addConstraint(NSLayoutConstraint(item: rightOption, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 0.5, constant: -1))
            self.addConstraint(NSLayoutConstraint(item: rightOption, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 0, constant: 100))
            self.addConstraint(NSLayoutConstraint(item: rightOption, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0))
            
            // vertical divider constraints
            self.addConstraint(NSLayoutConstraint(item: verticalDivider, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
            self.addConstraint(NSLayoutConstraint(item: verticalDivider, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 0, constant: 1))
            self.addConstraint(NSLayoutConstraint(item: verticalDivider, attribute: .Top, relatedBy: .Equal, toItem: horizontalDivider, attribute: .Bottom, multiplier: 1, constant: 8))
            self.addConstraint(NSLayoutConstraint(item: verticalDivider, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: -8))
            
        }
        super.updateConstraints()
    }
    
    override var description: String {
        return "two options question view"
    }
}








/**
 Adhere to this protocol to be able to fill the multiple choice question view data, and to handle the choices
 
 - Author: Arjan van der Laan
 */
protocol MultipleOptionsQuestionViewDelegate {
    /**
     Should return the number of rows of the picker view belonging to a `MultipleOptionsQuestionView`.
     */
    func numberOfRowsInPickerViewOfMultipleOptionsQuestionView(multipleOptionsQuestionView: MultipleOptionsQuestionView) -> Int
    
    /**
     Should return the title (content) of a given row of the picker view belonging to a `MultipleOptionsQuestionView`.
     - parameter titleForRow: should be title for zero based row
     */
    func pickerViewOfMultipleOptionsQuestionView(multipleOptionsQuestionView: MultipleOptionsQuestionView, titleForRow row: Int) -> String?
    
    /**
     This method is called when the user clicks "Done" (or similar). The picker view is dismissed, and the delegate gets the
     opportunity to handle the result, i.e. the selected row.
     - parameter selectedRow: row is zero based
     */
    func doneWithPickerViewOfMultipleOptionsQuestionView(multipleOptionsQuestionView: MultipleOptionsQuestionView, selectedRow row: Int?)
    
    /**
     Should return the color for a given row in the picker view belonging to a `MultipleOptionsQuestionView`.
     - parameter colorForSelectedRow: row is zero based
     */
    func pickerViewOfMultipleOptionsQuestionView(multipleOptionsQuestionView: MultipleOptionsQuestionView, colorForSelectedRow row: Int?) -> UIColor?
    
    /**
     This method is called when there is a detail disclosure button added (see `init` method), and a TouchUpInside event has been triggered. Use it to e.g. show a popup with information about the question.
     */
    func touchedDetailDisclosureButtonOfMultipleOptionsQuestionView(multipleOptionsQuestionView: MultipleOptionsQuestionView)
}


/**
 `MultipleOptionsQuestionView` is a UIView that can hold an informative text or question,
 and a UIPickerView that appears in place of the keyboard.
 
 - author: Arjan van der Laan
 - note: has no intrinsic content size. Always set it up with constraints
 
 - Requires:
 - a `UITextFieldWithoutEditing` as the answer input field
 - a `UIPickerViewWithButtons` as the picker view with **only 1 component**!
 - a `MultipleOptionsQuestionViewDelegate` as `delegate`
 */
class MultipleOptionsQuestionView: UIView, UIPickerViewDelegate, UIPickerViewDataSource {
    private let questionLabel: UILabel = UILabel()
    private let horizontalDivider: UIView = UIView() // Just an empty block. Could have also been done with margins
    private let inputField: UITextFieldWithoutEditing = UITextFieldWithoutEditing()
    private var inputFieldPlaceholderText: String! { didSet { inputField.placeholder = inputFieldPlaceholderText } }
    var delegate: MultipleOptionsQuestionViewDelegate?
    private var pickerView: UIPickerViewWithButtons = UIPickerViewWithButtons()
    private let detailDisclosureButton: UIButton = UIButton(type: UIButtonType.DetailDisclosure)
    private var showDetailDisclosureButton: Bool = false
    
    var title: String? { get { return questionLabel.text } set { questionLabel.text = newValue } }
    private var answerPrefix: String?
    private var value: String? { get { return inputField.text }
        set {
            if let color = delegate?.pickerViewOfMultipleOptionsQuestionView(self, colorForSelectedRow: pickerView.selectedRowInComponent(0)) {
                inputField.textColor = color
            }
            if let answer = newValue { inputField.text = "\(answerPrefix ?? "")\(answer)" } else { inputField.text = nil }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        logthis("designated initializer is: \"required convenience init(selectedRow: Int?, inputFieldPlaceholder: String, answerPrefix: String?)\". Modify class for UIStoyboard compatibility.")
    }
    
    private func setup() {
        setLabelInfo()
        addSubview(questionLabel)
        
        setHorizontalDividerInfo()
        addSubview(horizontalDivider)
        
        setInputFieldInfo()
        addSubview(inputField)
        
        if showDetailDisclosureButton {
            setDetailDisclosureButtonInfo()
            addSubview(detailDisclosureButton)
        }
    }
    
    /**
     - parameter inputFieldPlaceholder: placeholder text if no answer is given yet
     */
    required convenience init(inputFieldPlaceholder: String,
                              answerPrefix: String?,
                              showDetailDisclosureButton: Bool,
                              delegate: MultipleOptionsQuestionViewDelegate) {
        self.init(frame: CGRect())
        self.delegate = delegate
        self.answerPrefix = answerPrefix
        self.inputFieldPlaceholderText = inputFieldPlaceholder
        self.showDetailDisclosureButton = showDetailDisclosureButton
        setup()
    }
    
    /**
     Call this function to select a row programmatically. Calling it too early may result in
     the row not being set.
     */
    func selectPickerViewRow(row: Int) {
        pickerView.selectRow(row, inComponent: 0, animated: false)
        pickerView(pickerView, didSelectRow: row, inComponent: 0)
    }
    
    private func setLabelInfo() {
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        questionLabel.numberOfLines = 0
        questionLabel.textAlignment = .Center
    }
    
    private func setHorizontalDividerInfo() {
        horizontalDivider.translatesAutoresizingMaskIntoConstraints = false
        //divider.backgroundColor = UIColor.brownColor()
    }
    
    private func setInputFieldInfo() {
        inputField.translatesAutoresizingMaskIntoConstraints = false
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        inputField.inputView = pickerView
        inputField.inputAccessoryView = pickerView.toolBar
        
        pickerView.doneButton.target = self
        pickerView.doneButton.action = #selector(UIPickerViewWithButtons.donePicker)
        pickerView.cancelButton.target = self
        pickerView.cancelButton.action = #selector(UIPickerViewWithButtons.cancelPicker)
        
        inputField.placeholder = "Maak een keuze..."
        inputField.textAlignment = .Center
        inputField.tintColor = UIColor.clearColor()
    }
    
    private func setDetailDisclosureButtonInfo() {
        if !detailDisclosureButton.allTargets().contains(self) {
            detailDisclosureButton.addTarget(self, action: "touchedDetailDisclosureButton:", forControlEvents: .TouchUpInside)
        }
        detailDisclosureButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func touchedDetailDisclosureButton(sender: UIButton) {
        delegate?.touchedDetailDisclosureButtonOfMultipleOptionsQuestionView(self)
    }
    
    private var didSetConstraints = false
    override func updateConstraints() {
        if !didSetConstraints {
            
            // someLabel constraints
            self.addConstraint(NSLayoutConstraint(item: questionLabel, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: 0))
            self.addConstraint(NSLayoutConstraint(item: questionLabel, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: 0))
            self.addConstraint(NSLayoutConstraint(item: questionLabel, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0))
            //self.addConstraint(NSLayoutConstraint(item: questionLabel, attribute: .Bottom, relatedBy: .Equal, toItem: horizontalDivider, attribute: .Top, multiplier: 1, constant: 0))
            
            if showDetailDisclosureButton
            {
                self.addConstraint(NSLayoutConstraint(item: questionLabel, attribute: .Bottom, relatedBy: .Equal, toItem: detailDisclosureButton, attribute: .Top, multiplier: 1, constant: 0))
                
                // questionInfoButton constraints
                self.addConstraint(NSLayoutConstraint(item: detailDisclosureButton, attribute: .Top, relatedBy: .Equal, toItem: questionLabel, attribute: .Bottom, multiplier: 1, constant: 0))
                self.addConstraint(NSLayoutConstraint(item: detailDisclosureButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 0, constant: 48))
                self.addConstraint(NSLayoutConstraint(item: detailDisclosureButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 0, constant: 48))
                //self.addConstraint(NSLayoutConstraint(item: questionInfoButton, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: -16))
                self.addConstraint(NSLayoutConstraint(item: detailDisclosureButton, attribute: .CenterX, relatedBy: .Equal, toItem: questionLabel, attribute: .CenterX, multiplier: 1, constant: 0))
                
                // divider constraints
                self.addConstraint(NSLayoutConstraint(item: horizontalDivider, attribute: .Top, relatedBy: .Equal, toItem: detailDisclosureButton, attribute: .Bottom, multiplier: 1, constant: 0))
            }
            else
            {
                self.addConstraint(NSLayoutConstraint(item: questionLabel, attribute: .Bottom, relatedBy: .Equal, toItem: horizontalDivider, attribute: .Top, multiplier: 1, constant: 0))
                self.addConstraint(NSLayoutConstraint(item: horizontalDivider, attribute: .Top, relatedBy: .Equal, toItem: questionLabel, attribute: .Bottom, multiplier: 1, constant: 0))
                
            }
            
            // horizontal divider constraints
            //self.addConstraint(NSLayoutConstraint(item: horizontalDivider, attribute: .Top, relatedBy: .Equal, toItem: questionLabel, attribute: .Bottom, multiplier: 1, constant: 0))
            self.addConstraint(NSLayoutConstraint(item: horizontalDivider, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: 0))
            self.addConstraint(NSLayoutConstraint(item: horizontalDivider, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: 0))
            self.addConstraint(NSLayoutConstraint(item: horizontalDivider, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 0, constant: 8))
            self.addConstraint(NSLayoutConstraint(item: horizontalDivider, attribute: .Bottom, relatedBy: .Equal, toItem: inputField, attribute: .Top, multiplier: 1, constant: 0))
            
            // input field option constraints
            self.addConstraint(NSLayoutConstraint(item: inputField, attribute: .Top, relatedBy: .Equal, toItem: horizontalDivider, attribute: .Bottom, multiplier: 1, constant: 0))
            self.addConstraint(NSLayoutConstraint(item: inputField, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: 0))
            self.addConstraint(NSLayoutConstraint(item: inputField, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1, constant: 0))
            self.addConstraint(NSLayoutConstraint(item: inputField, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 0, constant: 50))
            self.addConstraint(NSLayoutConstraint(item: inputField, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0))
            
        }
        super.updateConstraints()
    }
    
    override var description: String {
        return "multiple choice question view"
    }
    
    // MARK: Toolbar methods
    func donePicker() {
        self.value = delegate?.pickerViewOfMultipleOptionsQuestionView(self, titleForRow: pickerView.selectedRowInComponent(0))
        delegate?.doneWithPickerViewOfMultipleOptionsQuestionView(self, selectedRow: pickerView.selectedRowInComponent(0))
        inputField.resignFirstResponder()
    }
    
    func cancelPicker() {
        inputField.resignFirstResponder()
    }
    
    // MARK: UIPickerView datasource methods
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return delegate?.numberOfRowsInPickerViewOfMultipleOptionsQuestionView(self) ?? 0
    }
    
    // MARK: UIPickerView delegate methods
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return delegate?.pickerViewOfMultipleOptionsQuestionView(self, titleForRow: row)
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.value = delegate?.pickerViewOfMultipleOptionsQuestionView(self, titleForRow: row)
        //delegate?.pickerViewOfMultipleOptionsQuestionView(self, didSelectRow: row)
    }
}














