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


  //MARK: - Properties
  private var brain = CalculatorBrain()
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
      if let description = brain.description {
        history.text = description + (brain.resultIsPending ? " _" : " =")
      }
    }
  }

  let decimalSeparator = formatter.decimalSeparator ?? "."

  //MARK: - ViewController Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
  }

  //MARK: - Methods


  //MARK: - Actions

  @IBAction func clearAll(_ sender: UIButton) {
    brain.clear()
    displayValue = 0
    history.text = " "
  }

  @IBAction func backspace(_ sender: UIButton) {
    guard userIsInTheMiddleOfTyping && !display.text!.isEmpty else { return }
    display.text = String(display.text!.dropLast())
    if display.text!.isEmpty {
      displayValue = 0
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

  @IBAction func performOperation(_ sender: UIButton) {
    if userIsInTheMiddleOfTyping {
      if let value = displayValue{
        brain.setOperand(value)
      }
      userIsInTheMiddleOfTyping = false
    }
    if let mathematicalSymbol = sender.currentTitle {
      brain.performOperation(mathematicalSymbol)
    }
    if let result = brain.result {
      displayValue = result
    }

    if let description = brain.description {
      history.text = description + (brain.resultIsPending ? " ..." : " =")
    }
  }

}

