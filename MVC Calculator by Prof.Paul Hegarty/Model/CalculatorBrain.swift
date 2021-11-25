//
//  CalculatorBrain.swift
//  MVC Calculator by Prof.Paul Hegarty
//
//  Created by Николай Никитин on 24.11.2021.
//

import Foundation
class CalculatorBrain{

  private enum Op: CustomStringConvertible {
    case Operand(Double)
    case UnaryOperation(String, (Double) -> Double)
    case BinaryOperation (String, (Double, Double) -> Double)

    var description: String {
      get {
        switch self {
        case .Operand(let operand):
          return "\(operand)"
        case .UnaryOperation(let symbol, _ ):
          return symbol
        case .BinaryOperation(let symbol, _ ):
          return symbol
        }
      }
    }
  }

  /// Stack of operations about operands together
  private var opStack = [Op]()

  /// A class instance variable that contains known operations
  private var knownOps = [String : Op]()


  /// Сlass initializer
  init( ){
    /// allows you to use the operation symbol once
    func learnOp (op: Op) {
      knownOps[op.description] = op
    }
    learnOp(op: Op.BinaryOperation("×", * ))
    knownOps["+"] = Op.BinaryOperation("+", + )
    knownOps["-"] = Op.BinaryOperation("-") {$1 - $0}
    knownOps["÷"] = Op.BinaryOperation("÷") {$1 / $0}
    knownOps["√"] = Op.UnaryOperation("√", sqrt )
  }

  /// Puts an operand on the stack
  /// - Parameter operand: takes operand: Double and returns Double
  func pushOperand( operand: Double) -> Double?{
    opStack.append(Op.Operand(operand))
    return evaluate()
  }

  /// Uses the operation symbol as the key by which it searches for the current operation in knownOps. And if it finds it, it puts the operation on the stack
  /// - Parameter symbol: operation symbol
  func performOperation(symbol: String) -> Double?{
    if let operation = knownOps[symbol]{
      opStack.append(operation)
    }
    return evaluate()
  }


  /// Uses the remaining stack when using recursively. The stack that we shorten with each recursive call, as it were, "consumes" part of it
  /// - Returns: Tuple from the result of the intermediate and remaining stack
  private func evaluate (ops: [Op]) -> (result: Double?, remainingOps: [Op]){
    if !ops.isEmpty {
      var remainingOps = ops
      let op = remainingOps.removeLast()
      switch op {
      case .Operand(let operand):
        return (operand, remainingOps)
      case .UnaryOperation(_ , let operation):
        // Recursion
        let operandEvaluation = evaluate(ops: remainingOps)
        if let operand = operandEvaluation.result {
          return (operation(operand), operandEvaluation.remainingOps)
        }
      case .BinaryOperation(_ , let operation):
        let op1Evaluation = evaluate(ops: remainingOps)
        // Recursion
        if let operand1 = op1Evaluation.result {
          let op2Evaluation = evaluate(ops: op1Evaluation.remainingOps)
          // Recursion
          if let operand2 = op2Evaluation.result {
            return (operation(operand1, operand2), op2Evaluation.remainingOps)
          }
        }
      }
    }
    return (nil, ops)
  }

  ///  Calls the recursive version of evaluate from the non-recursive version of evaluate and gets a tuple with values.
  /// - Returns: Optionat Double
  func evaluate() -> Double? {
    let (result, remainder) = evaluate(ops: opStack)
    print("\(opStack) = \(result) with \(remainder) left over")
    return result
  }
}
