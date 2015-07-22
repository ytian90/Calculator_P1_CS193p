//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Yu Tian on 7/10/15.
//  Copyright (c) 2015 Yu Tian. All rights reserved.
//

import Foundation

class CalculatorBrain
{
    // enum can have property
    private enum Op: Printable // a protocol
    {
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        case ConstantOperator(String, Double)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                case .ConstantOperator(let symbol, _):
                    return symbol
                }
            }
        }
    }
    
    private var opStack = [Op]()
    private var knownOps = [String:Op]()
    private var history = [String]()
    
    init() {
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        learnOp(Op.BinaryOperation("✕", *))
        learnOp(Op.BinaryOperation("÷") { $1 / $0 })
        learnOp(Op.BinaryOperation("+", +))
        learnOp(Op.BinaryOperation("−") { $1 - $0 })
//        learnOp(Op.UnaryOperation("√", sqrt))
        learnOp(Op.UnaryOperation("^2") {pow($0, 2)})
        learnOp(Op.UnaryOperation("^3") {pow($0, 3)})
        learnOp(Op.UnaryOperation("sin()", sin))
        learnOp(Op.UnaryOperation("cos()", cos))
        learnOp(Op.UnaryOperation("tan()") {sin($0)/cos($0)})
        learnOp(Op.UnaryOperation("+/−") {-$0})
        learnOp(Op.ConstantOperator("π", { M_PI }()))
    }
    
    typealias PropertyList = AnyObject
    
    var program: PropertyList { // guaranteed to be a PropertyList
        get {
            return opStack.map { $0.description }
        }
        set {
            if let opSymbols = newValue as? Array<String> {
                var newOpStack = [Op]()
                for opSymbol in opSymbols {
                    if let op = knownOps[opSymbol] {
                        newOpStack.append(op)
                    } else if let operand = NSNumberFormatter().numberFromString(opSymbol)?.doubleValue {
                        newOpStack.append(.Operand(operand))
                    }
                }
                opStack = newOpStack
            }
        }
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        
        if !ops.isEmpty {
            // Create a var to make ops mutable
            var remainingOps = ops
            let op = remainingOps.removeLast()
            
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .UnaryOperation(_, let operation): // _ don't care
                let operandEvaluation = evaluate(remainingOps) // recursion, operandEvaluation is tuple
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation): // do it twice
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            case .ConstantOperator(_, let value):
                return(value, remainingOps)
            }
            
        }
        
        return (nil, ops)
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack) // use a tuple to get the value 
        println("\(opStack) = \(result) with \(remainder) left over")
        return result
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
    
    func showStack() -> String? {
        return " ".join(opStack.map{"\($0)"})
    }
    
    func clearStack() {
        opStack.removeAll(keepCapacity: false)
    }
    
    
    
}