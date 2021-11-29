//
//  CalculatorBrain.swift
//  MVC Calculator by Prof.Paul Hegarty
//
//  Created by Николай Никитин on 24.11.2021.
//

import Foundation

struct CalculatorBrain{

  //MARK: - Properties of brain

  ///Basic enumeration for sorting operators, operands and variables
  private enum OpStack {
    case operand(Double)
    case operation(String)
    case variable(String)
  }

  var prevPrecendence = Int.max

  /// Stack of user input data
  private var internalProgram = [OpStack]()

  /// Stack of basic operations
  private enum Operation{
    case nullaryOperation(() -> Double,String)
    case constant(Double)
    case unaryOperation((Double) -> Double, ((String) -> String)?, ((Double) -> String?)?)
    case binaryOperation((Double, Double) -> Double, ((String, String) -> String)?, ((Double, Double) -> String?)?, Int)
    case equals
  }

  /// Computable property of basic operations
  private var operations: Dictionary<String, Operation> = [
    "Ran": Operation.nullaryOperation({ Double(arc4random()) / Double(UInt32.max) }, "rand()"),
    "π": Operation.constant(Double.pi),
    "e": Operation.constant(M_E),
    "√": Operation.unaryOperation(sqrt, nil, { $0 < 0 ? "√ negative number" : nil}),
    "cos": Operation.unaryOperation(cos, nil, nil),
    "sin": Operation.unaryOperation(sin, nil, nil),
    "tan": Operation.unaryOperation(tan, nil, nil),
    "х²": Operation.unaryOperation({$0 * $0}, {"(" + $0 + ")²"}, nil),
    "ln": Operation.unaryOperation(log, nil, { $0 <= 0 ? "ln negative number" : nil}),
    "±": Operation.unaryOperation({ -$0 }, nil, nil),
    "+": Operation.binaryOperation(+, nil, nil, 0),
    "-": Operation.binaryOperation(-, nil, nil, 0),
    "×": Operation.binaryOperation(*, nil, nil, 1),
    "÷": Operation.binaryOperation(/, nil, {$1 == 0.0 ? " division by zero" : nil}, 1),
    "=": Operation.equals,
  ]

  /// Structure for deferred input/output of values in the history field
  private struct PendingBinaryOperation {
    let function: (Double, Double) -> Double
    let firstOperand: Double
    var descriptionFunction: (String, String) -> String
    var descriptionOperand: String
    var validator: ((Double,Double) -> String?)?
    var prevPrecendence: Int
    var precendence: Int

    /// Returns operands in the history field
    func perform(with secondOperand: Double) -> Double{
      return function(firstOperand, secondOperand)
    }

    /// Returns a description of the operation
    func performDescription(with secondOperand: String) -> String {
      var descriptionOperandNew = descriptionOperand
      if prevPrecendence < precendence {
        descriptionOperandNew = "(" + descriptionOperandNew + ")"
      }
      return descriptionFunction(descriptionOperandNew, secondOperand)
    }

    func validate (with secondOperand: Double) -> String? {
      guard let validator = validator else { return nil }
      return validator (firstOperand, secondOperand)
    }
  }


  //MARK: - Methods of brain

  mutating func undo(){
    if !internalProgram.isEmpty {
      internalProgram = Array(internalProgram.dropLast())
    }
  }

  ///Sets any of operands from calculator keyboard
  mutating func setOperand(_ operand: Double){
    internalProgram.append(OpStack.operand(operand))
  }

  /// Sets variable
  mutating func setOperand(variable named: String){
    internalProgram.append(OpStack.variable(named))
  }

  /// Makes operations with operands and variables
  mutating func performOperation(_ symbol: String){
    internalProgram.append(OpStack.operation(symbol))
  }
  /// Clears all stack for history
  mutating func clear(){
    internalProgram.removeAll()
  }


  // MARK: - Main brain function evaluate
  mutating func evaluate (using variables: Dictionary<String, Double>? = nil) -> (result: Double?, isPending: Bool, description: String, error: String?){

    //MARK: - Local variables of evaluate func
    var cache: (accumulator: Double?, descriptionAccumulator: String?)
    var pendingBinaryOperation: PendingBinaryOperation?
    var description: String? {
      get {
        if pendingBinaryOperation == nil {
          return cache.descriptionAccumulator
        } else {
          return pendingBinaryOperation!.descriptionFunction(pendingBinaryOperation!.descriptionOperand, cache.descriptionAccumulator ?? "")
        }
      }
    }
    var resultIsPending: Bool {
      get{
        return pendingBinaryOperation != nil
      }
    }
    var result: Double? {
      get {
        return cache.accumulator
      }
    }
    var error: String?

    // MARK: - Nested functions of global evaluate function
    func setOperand (_ operand: Double) {
      cache.accumulator = operand
      if let value = cache.accumulator {
        cache.descriptionAccumulator = formatter.string(from: NSNumber(value: value)) ?? ""
      }
    }

    func setOperand(variable named: String) {
      cache.accumulator = variables?[named] ?? 0
      cache.descriptionAccumulator = named
    }

    func performOperation (_ symbol: String){

      if let operation = operations[symbol]{

        switch operation {

        case .nullaryOperation(let function, let descriptionValue):
          cache = (function(), descriptionValue)
        case .constant(let value):
          cache = (value, symbol)

        case .unaryOperation(let function, var descriptionFunction, let validator):
          if cache.accumulator != nil {
            error = validator?(cache.accumulator!)
            cache.accumulator = function(cache.accumulator!)
            if descriptionFunction == nil {
              descriptionFunction = {symbol + "(" + $0 + ")"}
            }
            cache.descriptionAccumulator = descriptionFunction!(cache.descriptionAccumulator!)
          }

        case .binaryOperation(let function, var descriptionFunction, let validator, let precendence):
          performPendingBinaryOperation()
          if cache.accumulator != nil {
            if descriptionFunction == nil {
              descriptionFunction = {$0 + " " + symbol + " " + $1}
            }
            pendingBinaryOperation = PendingBinaryOperation(function: function,
                                                            firstOperand: cache.accumulator!,
                                                            descriptionFunction: descriptionFunction!,
                                                            descriptionOperand: cache.descriptionAccumulator!,
                                                            validator: validator,
                                                            prevPrecendence: prevPrecendence,
                                                            precendence: precendence)
            cache = (nil, nil)
          }
        case .equals:
          performPendingBinaryOperation()
        }
      }
    }

    func performPendingBinaryOperation(){
      if pendingBinaryOperation != nil && cache.accumulator != nil {
        error = pendingBinaryOperation!.validate(with: cache.accumulator!)
        cache.accumulator = pendingBinaryOperation!.perform(with: cache.accumulator!)
        cache.descriptionAccumulator = pendingBinaryOperation!.performDescription(with: cache.descriptionAccumulator!)
        prevPrecendence = pendingBinaryOperation!.precendence
        pendingBinaryOperation = nil
      }

    }

    // MARK: - Body of func evaluate
    guard !internalProgram.isEmpty else { return (nil, false, " ", nil)}
    for op in internalProgram {
      switch op{
      case .operand(let operand):
        setOperand(operand)
      case .variable(let symbol):
        setOperand(variable: symbol)
      case .operation(let operation):
        performOperation(operation)
      }
    }
    return (result, resultIsPending, description ?? " ", error)

  }

  // -
//  @available(iOS, deprecated, message: "No longer needed")
//  var description: String {
//    get {
//      return evaluate().description
//    }
//  }
//  @available(iOS, deprecated, message: "No longer needed")
//  var result: Double? {
//    get {
//      return evaluate().result
//    }
//  }
//
//  @available(iOS, deprecated, message: "No longer needed")
//  var resultIsPending: Bool {
//    get {
//      return evaluate().isPending
//    }
//
//  }

}

