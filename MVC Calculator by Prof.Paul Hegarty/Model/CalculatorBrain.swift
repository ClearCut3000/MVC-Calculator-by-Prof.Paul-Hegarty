//
//  CalculatorBrain.swift
//  MVC Calculator by Prof.Paul Hegarty
//
//  Created by Николай Никитин on 24.11.2021.
//

import Foundation

func singChange(_ operand: Double) -> Double {
  return -operand
}




struct CalculatorBrain{
  private var accumulator: Double?
  private var descriptionAccumulator: String?

  var description: String? {
    get {
      if pendingBinaryOperation == nil {
        return descriptionAccumulator
      } else {
        return pendingBinaryOperation!.descriptionFunction(pendingBinaryOperation!.descriptionOperand, descriptionAccumulator ?? "")
      }
    }
  }

  var resultIsPending: Bool {
    get{
      return pendingBinaryOperation != nil
    }
  }

  private struct PendingBinaryOperation {
    let function: (Double, Double) -> Double
    let firstOperand: Double
    var descriptionFunction: (String, String) -> String
    var descriptionOperand: String

    func perform(with secondOperand: Double) -> Double{
      return function(firstOperand, secondOperand)
    }

    func performDescription(with secondOperand: String) -> String {
      return descriptionFunction(descriptionOperand, secondOperand)
    }
  }

  private var pendingBinaryOperation: PendingBinaryOperation?

  private enum Operation{
    case nullaryOperation(() -> Double,String)
    case constant(Double)
    case unaryOperation((Double) -> Double, ((String) -> String)?)
    case binaryOperation((Double, Double) -> Double, ((String, String) -> String)?)
    case equals
  }

  private var operations: Dictionary<String, Operation> = [
    "Ran": Operation.nullaryOperation({ Double(arc4random()) / Double(UInt32.max) }, "rand()"),
    "π": Operation.constant(Double.pi),
    "e": Operation.constant(M_E),
    "√": Operation.unaryOperation(sqrt, nil),
    "cos": Operation.unaryOperation(cos, nil),
    "sin": Operation.unaryOperation(sin, nil),
    "tan": Operation.unaryOperation(tan, nil),
    "х²": Operation.unaryOperation({$0 * $0}, {"(" + $0 + ")²"}),
    "ln": Operation.unaryOperation(log, nil),
    "±": Operation.unaryOperation({ -$0 }, nil),
    "+": Operation.binaryOperation(+, nil),
    "-": Operation.binaryOperation(-, nil),
    "×": Operation.binaryOperation(*, nil),
    "÷": Operation.binaryOperation(/, nil),
    "=": Operation.equals,
    ]

  var result: Double? {
    get {
      return accumulator
    }
  }

  mutating func setOperand (_ operand: Double) {
    accumulator = operand
    if let value = accumulator {
      descriptionAccumulator = formatter.string(from: NSNumber(value: value)) ?? ""
    }
  }

  private mutating func performPendingBinaryOperation(){
    if pendingBinaryOperation != nil && accumulator != nil {
      accumulator = pendingBinaryOperation?.perform(with: accumulator!)
      descriptionAccumulator = pendingBinaryOperation!.performDescription(with: descriptionAccumulator!)
      pendingBinaryOperation = nil
    }
  }

  mutating func clear(){
    accumulator = nil
    pendingBinaryOperation = nil
    descriptionAccumulator = " "
  }

  mutating func performOperation (_ symbol: String){

    if let operation = operations[symbol]{

      switch operation {

      case .nullaryOperation(let function, let descriptionValue):
        accumulator = function()
        descriptionAccumulator = descriptionValue
      case .constant(let value):
        accumulator = value
        descriptionAccumulator = symbol
        
      case .unaryOperation(let function, var descriptionFunction):
        if accumulator != nil {
          accumulator = function(accumulator!)
          if descriptionFunction != nil {
            descriptionFunction = {symbol + "(" + $0 + ")"}
          }
          descriptionAccumulator = descriptionFunction!(descriptionAccumulator!)
        }

      case .binaryOperation(let function, var descriptionFunction):
        performPendingBinaryOperation()
        if accumulator != nil {
          if descriptionFunction != nil {
            descriptionFunction = {$0 + " " + symbol + " " + $1}
          }
          pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!, descriptionFunction: descriptionFunction!, descriptionOperand: descriptionAccumulator!)
          accumulator = nil
          descriptionAccumulator = nil
        }
      case .equals:
        performPendingBinaryOperation()
      }
    }
  }

}

