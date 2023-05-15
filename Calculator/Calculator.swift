//
//  Calculator.swift
//  Calculator
//
//  Created by Tangzhibin on 2023/4/12.
//

import Foundation

protocol PrintProtocol {
    func printValue(`let` data:Any)
}


func formateValue(value:Double) -> String {
    return String(format: "%g", value)
}


enum CalculatorSymbol:PrintProtocol {
    case Add(value:String)
    case Sub(value:String)
    case Mul(value:String)
    case Div(value:String)
    case Number(value:Double)
    case Point(value:String)
    
    case AllClean(value:String)
    case NegativeOrPositive(value:String)
    case Clean(value:String)
    case Percentage(value:String)
    case Equal(value:String)
    
    func numberValueForType(`let` type:CalculatorSymbol) -> Double {
        var typeValue:Double = 0
        switch type {
        case.Number(let value):
            typeValue = value
        default:
            typeValue = -1
        }
        return typeValue
    }
    
    
    func stringValueForType(`let` type:CalculatorSymbol) -> String {
        var typeValue:String = ""
        switch type {
        case.Add(value: let value):
            typeValue = value
        case .Sub(value: let value):
            typeValue = value
        case .Mul(value: let value):
            typeValue = value
        case .Div(value: let value):
            typeValue = value
        case .Number(value: let value):
            typeValue = formateValue(value: value)
        case .Point(value: let value):
            typeValue = value
        case .AllClean(value: let value):
            typeValue = value
        case .NegativeOrPositive(value: let value):
            typeValue = value
        case .Clean(value: let value):
            typeValue = value
        case .Percentage(value: let value):
            typeValue = value
        case .Equal(value: let value):
            typeValue = value
        }
        return typeValue
    }
    
    func printValue(`let` data: Any) {
        let real = data as! CalculatorSymbol
        
        switch real {
        
        case .Add(_),
         .Sub(_),
         .Mul(_),
         .Div(_),
         .Point(_),
         .AllClean(_),
         .NegativeOrPositive(_),
         .Clean(_),
         .Percentage(_),
         .Equal(_):
            _ = stringValueForType(let: real)
        default:
            _ =  numberValueForType(let: real)
        }
    }
}

class OperaterSymbol:PrintProtocol {
    
    enum OpersterType {
        case Number
        case Symbol
    }
    
    var type:OpersterType
    var value:Any
    
    init(type: OpersterType, value:Any) {
        self.type = type
        self.value = value
    }
    
    var numberValue:Double {
        get {
            return value as! Double
        }
    }
    var strinValue:String {
        get {
            return value as! String
        }
    }
    
    func printValue(`let` data: Any) {
        let real = data  as! OperaterSymbol
        switch real.type {
        case .Number:
            print("OperaterSymbol -- \(real.numberValue)")
        case .Symbol:
            print("OperaterSymbol -- \(real.strinValue)")
        }
    }
}


protocol CalculatorDelegate {
    func didInput(value:String)
    func didClean(value:String)
    func didCleanMath(value:String)
    func calculatorResult(value:String)
    func didChangeMathOperator(value:String)
}

class Calculator {
    //用户录入栈
    var stack:CalculatorStack<CalculatorSymbol> = {
         CalculatorStack()
    }()
    //计算栈
    var operaterStack:CalculatorStack<OperaterSymbol> = {
        CalculatorStack()
    }()
    
    //撤销栈
    var undoStack:CalculatorStack<CalculatorSymbol> = {
        CalculatorStack()
    }()
    
    var nextMustBeOperator:Bool = false
    
    var delegate:CalculatorDelegate?
    
    func pop(type:CalculatorSymbol) {
        var node = StackNode<CalculatorSymbol>.init()
        node.data = type
        
        
        switch type {
        case .Add(_),.Sub(_),.Div(_),.Mul(_):
            
            //把stack中的元素组成一个元素
            if stack.count > 0 {
                operaterStackPushNode(let: OperaterSymbol.OpersterType.Number, value: saveToNumberOperatorStack())
            }
            //添加 加减乘除符号
            if operaterStack.count > 0 {
                var lastNode = operaterStack.iterator()
                if case lastNode?.data?.type = OperaterSymbol.OpersterType.Symbol {
                    lastNode = operaterStack.popNode()
                    delegate?.didChangeMathOperator(value: type.stringValueForType(let: type))
                } else {
                    delegate?.didInput(value: String(stringLiteral: "\(type.stringValueForType(let:type))"))
                }
                operaterStackPushNode(let: OperaterSymbol.OpersterType.Symbol, value: type.stringValueForType(let: type))
                nextMustBeOperator = false
            } else {
                //do nothing
            }
        case .Number(_),.Point(_):
            if nextMustBeOperator {
                _ = operaterStack.popNode()
                nextMustBeOperator = false
                delegate?.didClean(value: "")
            }
            
            if case .Point(_) = type {
                if stack.count == 0 {
                    //没有任何操作数
                    return
                }
                delegate?.didInput(value: type.stringValueForType(let:type))
            } else {
                delegate?.didInput(value: formateValue(value: type.numberValueForType(let:type)))
            }
            stack.pushNode(var:&node)
            print("==")
        case .Clean(_):
            //撤销 operaterStack
            //如果stack中有内容，清空stack中的内容，如果stack中没有内容，operaterStack最后一个元素删除
            if stack.count > 0 {
                let _ = stack.popNode()
            } else if (operaterStack.count  > 0) {
                let _ = operaterStack.popNode()
            } else {
                //do nothing
            }
            delegate?.didInput(value: type.stringValueForType(let:type))
        case.AllClean(_):
            //清空stack 和 operaterStack
            stack.clean()
            operaterStack.clean()
            delegate?.didClean(value: "")
            delegate?.didCleanMath(value: "0")
            nextMustBeOperator = true
        case .Equal(_):
            if stack.count > 0 {
                operaterStackPushNode(let: OperaterSymbol.OpersterType.Number, value: saveToNumberOperatorStack())
            }
            //处理operaterStack 中内容--》逆波兰
            let f =  reversePolishNotation(stack: operaterStack)
            //开始计算
            let b = _PrivateCalculate(stack: f!)
            delegate?.calculatorResult(value: formateValue(value: b))
            
            //新值入栈
            operaterStack.clean()
            var newNode:StackNode<OperaterSymbol> = StackNode()
            newNode.data = OperaterSymbol(type: OperaterSymbol.OpersterType.Number, value: b)
            operaterStack.pushNode(var: &newNode)
            nextMustBeOperator = true
            break
        case .NegativeOrPositive(_):
            
            
            if stack.count == 0 {
                //没有任何操作数
                return
            }
            var number = saveToNumberOperatorStack()
            number = number * -1
            
            var node:StackNode = StackNode<CalculatorSymbol>()
            node.data = CalculatorSymbol.Number(value: number)
            stack.pushNode(var: &node)
            delegate?.didClean(value: "")
            delegate?.didInput(value: formateValue(value: number))
            nextMustBeOperator = true
            break
        case .Percentage(_):
           
            if stack.count == 0 {
                //没有任何操作数
                return
            }
            var number = saveToNumberOperatorStack()
            number = number * 0.01
            
            var node:StackNode = StackNode<CalculatorSymbol>()
            node.data = CalculatorSymbol.Number(value: number)
            stack.pushNode(var: &node)
            delegate?.didClean(value: "")
            delegate?.didInput(value: formateValue(value: number))
        }
    }
    
    func _PrivateCalculate(stack:CalculatorStack<OperaterSymbol>) -> Double {
        if (stack.isEmptyStack()) {
            
            return Double(0)
        }
        
        let cStack:CalculatorStack<OperaterSymbol> = CalculatorStack()
        
        var  nextNode:StackNode<OperaterSymbol>? = stack.header!
        while nextNode != nil {
            var node:StackNode<OperaterSymbol> = StackNode()
            if (nextNode!.data?.type == .Number) {
                //数字入栈
                node.data = nextNode?.data
                cStack.pushNode(var: &node)
            } else {
                //符号则取出栈顶两个数字
                let node1 = cStack.popNode()
                let node2 = cStack.popNode()
                
                var value:Double = 0
                //计算
                let opeater:String = nextNode!.data!.strinValue
                
                if opeater == "-" {
                    value = node2!.data!.numberValue - node1!.data!.numberValue
                } else if  opeater == "+" {
                    value = node2!.data!.numberValue + node1!.data!.numberValue
                } else if  opeater == "*" {
                    value = node2!.data!.numberValue * node1!.data!.numberValue
                } else if  opeater == "/" {
                    value = node2!.data!.numberValue / node1!.data!.numberValue
                } else {
                    print("sorrry for this error")
                }
                node.data = OperaterSymbol(type: OperaterSymbol.OpersterType.Number, value: value)
                cStack.pushNode(var: &node)
            }
            nextNode = nextNode!.nextData
        }
        let lastV = cStack.popNode()?.data?.numberValue
        return lastV ?? Double(0)
    }
    
    
    func operaterStackPushNode(`let` type:OperaterSymbol.OpersterType,value:Any) {
        let sym = OperaterSymbol(type: type, value: value)
        var node = StackNode<OperaterSymbol>()
        node.data = sym
        
        
        //获取最后一个符号，如果是 + - * / 用最新的替换
        let _ = operaterStack.pushNode(var: &node)
    }
    
    func saveToNumberOperatorStack() -> Double {
        assert(stack.count > 0 , "stack is empty")
        if stack.count == 0 {
            return Double(-1)
        }
        //change stack elements to  number
        var i:Double = 1
        var number:Double = 0
        
        var lastNode:StackNode<CalculatorSymbol>?
        var factor:Double = 10
        repeat {
            lastNode = stack.popNode()
            if lastNode == nil {
                break
            }
            let type:CalculatorSymbol = lastNode!.data!
            if case .Point(_) = type {
                number = number / i
                i = 1
            } else {
                let value = type.numberValueForType(let: type)
                number += (Double(i) * value)
                i = i * factor
            }
        } while ((lastNode?.preData) != nil)
        
        return number
    }
    
    
    func reversePolishNotation(stack:CalculatorStack<OperaterSymbol>)->CalculatorStack<OperaterSymbol>? {
        
        if (stack.isEmptyStack()) {
            print("nibolan failed: stack is empty")
        }
        
        
        
        print("中缀表达式：======开始")
        stack.printEleData()
        print("中缀表达式：======结束")
        let reverseStack = CalculatorStack<OperaterSymbol>()
        let symStack = CalculatorStack<OperaterSymbol>()
        var next = stack.header
        while (next != nil) {
            var node:StackNode<OperaterSymbol>? = StackNode<OperaterSymbol>()
            node?.data = next?.data
            switch next?.data?.type {
            case .Symbol:
                //优先级不高于栈顶符号，则栈顶符号输出，并将当前符号进栈
                
                let stringValue:String? = next?.data?.strinValue
                if stringValue == "+" || stringValue == "-" {
                    //最低等级符号，所有符号元素出栈
                    var lastSym:StackNode<OperaterSymbol>? = symStack.popNode()
                    while (lastSym != nil) {
                        //符号栈内容放入后缀栈
                        var reverseStackNode:StackNode<OperaterSymbol>? = StackNode<OperaterSymbol>()
                        reverseStackNode?.data = lastSym?.data
                        reverseStack.pushNode(var: &reverseStackNode!)
                        lastSym = symStack.popNode()
                    }
                    //符号栈清空
                    symStack.clean()
                    //当前元素入栈
                    symStack.pushNode(var: &node!)
                    
                } else if stringValue == "*" || stringValue == "/" {
                    //最高等级符号，直接入栈
                    symStack.pushNode(var: &node!)
                }
                break
            case .Number:
                reverseStack.pushNode(var: &node!)
            default:
                //do noting
                break
            }
            next = next?.nextData
        }
        
        
        //符号栈清空
        var lastSym:StackNode<OperaterSymbol>? = symStack.popNode()
        
        while (lastSym != nil) {
            //符号栈内容放入后缀栈
            var node:StackNode<OperaterSymbol>? = StackNode<OperaterSymbol>()
            node?.data = lastSym?.data
            reverseStack.pushNode(var: &node!)
            lastSym = symStack.popNode()
        }
        symStack.clean()
        
        print("后缀表达式：----------开始")
        reverseStack.printEleData()
        print("后缀表达式：----------结束")
        return reverseStack
    }
    
    func mathString() -> String {
        if  operaterStack.isEmptyStack() {
            return "0"
        }
        
        var math:String = ""
        let nextNode = operaterStack.header
        var tmp:String = ""
        while (nil != nextNode) {
            if nextNode!.data!.type == .Number {
                tmp = "\(nextNode!.data!.numberValue)"
            } else {
                tmp = nextNode!.data!.strinValue
            }
            math.append(tmp)
        }
        return math
    }
}


class StackNode<T:PrintProtocol> {
    var data:T?
    var nextData:StackNode?
    var preData:StackNode?
}

class CalculatorStack<T:PrintProtocol> {
    var count = 0
    var header:StackNode<T>?
    
    func isEmptyStack() -> Bool {
        nil == header ? true : false
    }
    
    func pushNode( `var` node:inout StackNode<T>)  {
        if (isEmptyStack()) {
            //set header
            header = node
            count = 1
            return
        }
        
        var currentNode = header!
        var  nextNode = currentNode.nextData
        while nextNode != nil {
            currentNode = nextNode!
            nextNode = nextNode!.nextData
        }
        
        currentNode.nextData = node
        node.preData = currentNode
        count += 1
    }
    
    func popNode( ) -> StackNode<T>? {
        if (isEmptyStack()) {
            print("stack is empty")
            return nil
        }
    
        let lastNode = iterator()
        if lastNode?.preData == nil {
            self.header = nil
            count = 0
        } else {
            //change last element
            lastNode?.preData?.nextData = nil
            count -= 1
        }
        return lastNode
    }
    
    //retrun the last element
    func iterator() -> StackNode<T>? {
        if (isEmptyStack()) {
            print("stack is empty")
            return nil
        }
        
        var  nextNode:StackNode<T>? = header!.nextData
        var preNode:StackNode<T> = header!
        while nextNode != nil {
            preNode = nextNode!
            nextNode = nextNode!.nextData
        }
        return preNode
    }
    
    func clean()  {
        if (isEmptyStack()) {
            print("stack already is empty")
        }
        
        var theLast:StackNode<T>? = iterator()
        while (theLast != nil) {
            let tmp = theLast?.preData
            theLast?.preData?.nextData = nil
            theLast = nil
            theLast = tmp
        }
        header = nil
        count = 0
        print("stack now is empty")
    }
    
    func printEleData()  {
        if (isEmptyStack()) {
            print("stack is empty")
            return
        }
        var  nextNode:StackNode<T>? = header!.nextData
        header?.data?.printValue(let: header?.data! as Any)
        while nextNode != nil {
            nextNode?.data?.printValue(let: nextNode?.data! as Any)
            nextNode = nextNode!.nextData
        }
    }
}


