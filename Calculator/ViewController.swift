//
//  ViewController.swift
//  Calculator
//
//  Created by Yu Tian on 7/10/15.
//  Copyright (c) 2015 Yu Tian. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    
    var userIsInMiddleOfTypingANumber: Bool = false
    
    var brain = CalculatorBrain()

    @IBAction func appendDigit(sender: UIButton) {
        // let is as a var, but a constant
        let digit = sender.currentTitle!
        
        if userIsInMiddleOfTypingANumber
        {
            if (digit == ".") && (display.text!.rangeOfString(".") != nil) { return }
            display.text = display.text! + digit
        }
        else
        {
            if digit == "." {
                display.text = "0."
            } else {
                display.text = digit;
            }
            userIsInMiddleOfTypingANumber = true
        }
    }
    
    @IBAction func backSpace() {
        if userIsInMiddleOfTypingANumber {
            let text = display.text!
            if count(text) > 1 {
                display.text = dropLast(text)
            } else {
                display.text = ""
            }
        }
    }
    
    @IBAction func operate(sender: UIButton) {
        
        if userIsInMiddleOfTypingANumber
        {
            enter()
        }
        
        if let operation = sender.currentTitle
        {
            if operation == "+/-" {
                let text = display.text!
                if (text.rangeOfString("-") != nil) {
                    display.text = dropFirst(text)
                } else {
                    display.text = "-" + text
                }
            }
            if let result = brain.performOperation(operation)
            {
                displayValue = result
            }
            else {
                displayValue = 0
            }
        }
        history.text = history.text! + " = "
        
    }
    @IBAction func clear(sender: UIButton) {
        brain.clearStack()
        displayValue = 0
        history.text = ""
    }
    
    @IBAction func enter() {
        userIsInMiddleOfTypingANumber = false

        if let result = brain.pushOperand(displayValue!) {
            displayValue = result
            
        } else {
            displayValue = 0
        }
    }
    
    var displayValue: Double? {
        get {
            if let text = display.text {
                return NSNumberFormatter().numberFromString(text)?.doubleValue
            }
            return nil
        }
        set {
            if (newValue != nil) {
                display.text = "\(newValue)"
            } else {
                display.text = ""
            }
            
            history.text = brain.showStack()
            userIsInMiddleOfTypingANumber = false
        }
    }

}

