//
//  ViewController.swift
//  MVC Calculator by Prof.Paul Hegarty
//
//  Created by Николай Никитин on 24.11.2021.
//

import UIKit

class ViewController: UIViewController {

  @IBOutlet weak var display: UILabel!

  var userIsInTheMiddleOfTypingANumber: Bool = false
  var brain = CalculatorBrain()

  @IBAction func appendDigit(_ sender: UIButton) {
    let digit = sender.currentTitle!
    if userIsInTheMiddleOfTypingANumber{
    display.text = display.text! + digit
    } else {
      display.text = digit
      userIsInTheMiddleOfTypingANumber = true
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  }

  var operandStack: Array<Double> = Array<Double>()

  @IBAction func enter() {
    userIsInTheMiddleOfTypingANumber = false
    if let result = brain.pushOperand(operand: displayValue) {
      displayValue = result
    } else {
      displayValue = 0
    }
  }

  @IBAction func operate(_ sender: UIButton) {
    if userIsInTheMiddleOfTypingANumber {
      enter()
    }
    if let operation = sender.currentTitle {
      if let result = brain.performOperation(symbol: operation) {
        displayValue = result
      } else {
        displayValue = 0
      }
    }
  }

  func performOperation (operation: (Double, Double) -> Double){
    if operandStack.count >= 2 {
    displayValue = operation (operandStack.removeLast(), operandStack.removeLast())
    enter()
    }
  }

  func performOperation (operation: (Double) -> Double){
    if operandStack.count >= 1 {
    displayValue = operation (operandStack.removeLast())
    enter()
    }
  }

  var displayValue: Double {
    get {
      return NumberFormatter().number(from: display.text!)!.doubleValue
    }
    set {
      display.text = "\(newValue)"
      userIsInTheMiddleOfTypingANumber = false
    }
  }

}

