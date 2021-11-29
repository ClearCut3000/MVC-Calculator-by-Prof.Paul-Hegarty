//
//  ViewController.swift
//  MVC Calculator by Prof.Paul Hegarty
//
//  Created by Николай Никитин on 24.11.2021.
//

import UIKit

class CalculatorViewController: UIViewController {

  //MARK: - Outlets
  @IBOutlet weak var display: UILabel!
  @IBOutlet weak var history: UILabel!
  @IBOutlet weak var dot: UIButton!{
    didSet {
      dot.setTitle(decimalSeparator, for: UIControl.State.normal)
    }
  }
  @IBOutlet weak var displayM: UILabel!
  

  //MARK: - Properties
  private var brain = CalculatorBrain()
  private var variableValues = [String: Double]()
  var userIsInTheMiddleOfTyping: Bool = false
  var displayValue: Double? {
    get {
      if let text = display.text, let value = formatter.number(from: text) as? Double {
        return value
      }
      return nil
      }
    set {
      if let value = newValue {
        display.text = formatter.string(from: NSNumber(value: value))
      }
    }
  }

  let decimalSeparator = formatter.decimalSeparator ?? "."

  var displayResult: (result: Double?,
                      isPending: Bool,
                      description: String,
                      error: String?) = (nil, false," ", nil){
      didSet {
        switch displayResult {
        case (nil, _, " ", nil): displayValue = 0
        case (let result, _, _, nil): displayValue = result
        case (_, _, _, let error): display.text = error!
        }
          history.text = displayResult.description != " " ?
              displayResult.description + (displayResult.isPending ? " …" : " =") : " "
          displayM.text = formatter.string(from: NSNumber(value:variableValues["M"] ?? 0))
      }
  }

  //MARK: - ViewController Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
  }

  //MARK: - Methods


  //MARK: - Actions

  @IBAction func clearAll(_ sender: UIButton) {
    userIsInTheMiddleOfTyping = false
    brain.clear()
    variableValues = [:]
    displayResult = brain.evaluate()
  }

  @IBAction func backspace(_ sender: UIButton) {
    if userIsInTheMiddleOfTyping {
      guard !display.text!.isEmpty else { return }
      display.text = String(display.text!.dropLast())
      if display.text!.isEmpty {
        displayValue = 0
        userIsInTheMiddleOfTyping = false
        displayResult = brain.evaluate(using: variableValues)
      }
    } else {
      brain.undo()
      displayResult = brain.evaluate(using: variableValues)
    }
  }

  @IBAction func touchDigit(_ sender: UIButton) {
    let digit = sender.currentTitle!
    if userIsInTheMiddleOfTyping{
      let textCurrentlyInDisplay = display.text!
      if (digit != ".") || (textCurrentlyInDisplay.contains(".")){
      display.text = textCurrentlyInDisplay + digit
      }
    } else {
      display.text = digit
      userIsInTheMiddleOfTyping = true
    }
  }

  @IBAction func setM(_ sender: UIButton) {
    userIsInTheMiddleOfTyping = false
    let symbol = String((sender.currentTitle!).dropFirst())
    variableValues[symbol] = displayValue
    displayResult = brain.evaluate(using: variableValues)
  }

  @IBAction func pushM(_ sender: UIButton) {
    brain.setOperand(variable: sender.currentTitle!)
    displayResult = brain.evaluate(using: variableValues)
  }


  @IBAction func performOperation(_ sender: UIButton) {
    if userIsInTheMiddleOfTyping {
               if let value = displayValue{
                   brain.setOperand(value)
               }
               userIsInTheMiddleOfTyping = false
           }
           if  let mathematicalSymbol = sender.currentTitle {
               brain.performOperation(mathematicalSymbol)
           }
           displayResult = brain.evaluate(using: variableValues)
  }

}

