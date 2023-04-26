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


enum CalculatorSymbol:PrintProtocol {
    case Add(value:String)
    case Sub(value:String)
    case Mul(value:String)
    case Div(value:String)
    
    case Zero(value:String)
    case One(value:String)
    case Two(value:String)
    case Three(value:String)
    case Four(value:String)
    case Five(value:String)
    case Six(value:String)
    case Seven(value:String)
    case Eight(value:String)
    case Nine(value:String)
    case Point(value:String)
    
    case AllClean(value:String)
    case NegativeOrPositive(value:String)
    case Clean(value:String)
    case Percentage(value:String)
    case Equal(value:String)
    
    func numberValueForType(`let` type:CalculatorSymbol) -> Int {
        var typeValue:Int = 0
        switch type {
        case.One(_) :
            typeValue = 1
        case .Two(_):
            typeValue = 2
        case .Three(_):
            typeValue = 3
        case .Four(_):
            typeValue = 4
        case .Five(_):
            typeValue = 5
        case .Six(_):
            typeValue = 6
        case .Seven(_):
            typeValue = 7
        case .Eight(_):
            typeValue = 8
        case .Nine(_):
            typeValue = 9
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
        case .Zero(value: let value):
            typeValue = value
        case .One(value: let value):
            typeValue = value
        case .Two(value: let value):
            typeValue = value
        case .Three(value: let value):
            typeValue = value
        case .Four(value: let value):
            typeValue = value
        case .Five(value: let value):
            typeValue = value
        case .Six(value: let value):
            typeValue = value
        case .Seven(value: let value):
            typeValue = value
        case .Eight(value: let value):
            typeValue = value
        case .Nine(value: let value):
            typeValue = value
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
            let r = stringValueForType(let: real)
            print("CalculatorSymbolValue -- \(r)")
        default:
            let r =  numberValueForType(let: real)
            print("CalculatorSymbolValue -- \(r)")
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
    
    var numberValue:Int {
        get {
            return value as! Int
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
    func didClean()
}

class Calculator {
    var stack:CalculatorStack<CalculatorSymbol>?
    var operaterStack:CalculatorStack<OperaterSymbol>?
    
    var delegate:CalculatorDelegate?
    func pop(type:CalculatorSymbol) {
        var node = StackNode<CalculatorSymbol>.init()
        node.data = type
        if nil == stack {
            stack = CalculatorStack()
        }
        
        if nil == operaterStack {
            operaterStack = CalculatorStack()
        }
        
        switch type {
        case .Add(_),.Sub(_),.Div(_),.Mul(_):
            delegate?.didInput(value: String(stringLiteral: "\(type.stringValueForType(let:type))"))
            //把stack中的元素组成一个元素
            let number = saveToNumberOperatorStack()
            if number == -1 {
                //没有任何操作数
                break
            } else {
                operaterStackPushNode(let: OperaterSymbol.OpersterType.Number, value: number)
            }
            //添加 加减乘除符号
            operaterStackPushNode(let: OperaterSymbol.OpersterType.Symbol, value: type.stringValueForType(let: type))
            
        case .One(_),.Two(_),.Three(_),.Four(_),.Five(_),.Six(_),.Seven(_),.Eight(_),.Nine(_),.Zero(_):
            delegate?.didInput(value: String(stringLiteral: "\(type.numberValueForType(let:type))"))
            let _ = stack!.pushNode(var:&node)
        case .Clean(_):
            //撤销 operaterStack
            //如果stack中有内容，清空stack中的内容，如果stack中没有内容，operaterStack最后一个元素删除
            if stack?.count ?? 0 > 0 {
                let _ = stack?.popNode()
            } else if (operaterStack?.count ?? 0 > 0) {
                let _ = operaterStack?.popNode()
            } else {
                //do nothing
            }
            delegate?.didInput(value: String(stringLiteral: "\(type.stringValueForType(let:type))"))
        case.AllClean(_):
            //清空stack 和 operaterStack
            stack?.clean()
            operaterStack?.clean()
            self.delegate?.didClean()
        case .Equal(_):
            let number = saveToNumberOperatorStack()
            if number == -1 {
                //没有任何操作数
            } else {
                operaterStackPushNode(let: OperaterSymbol.OpersterType.Number, value: number)
            }
            //处理operaterStack 中内容--》逆波兰
            var f =  reversePolishNotation(stack: operaterStack!)
            var b = _PrivateCalculate(stack: f!)
            break
        default:
            let number = saveToNumberOperatorStack()
            if number == -1 {
                //没有任何操作数
            } else {
                operaterStackPushNode(let: OperaterSymbol.OpersterType.Number, value: number)
            }
            self.operaterStack?.printEleData()
        }
    }
    
    func _PrivateCalculate(stack:CalculatorStack<OperaterSymbol>) -> Int {
        if (stack.isEmptyStack()) {
            
            return Int(0)
        }
        
        var cStack:CalculatorStack<OperaterSymbol> = CalculatorStack()
        
        var  nextNode:StackNode<OperaterSymbol>? = stack.header!
        while nextNode != nil {
            var node:StackNode<OperaterSymbol> = StackNode()
            if (nextNode!.data?.type == .Number) {
                //数字入栈
                node.data = nextNode?.data
                cStack.pushNode(var: &node)
            } else {
                //符号则取出栈顶两个数字
                var node1 = cStack.popNode()
                var node2 = cStack.popNode()
                
                var value:Int = 0
                //计算
                var opeater:String = nextNode!.data!.strinValue
                
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
        var lastV = cStack.popNode()?.data?.numberValue
        return 1
    }
    
    
    func operaterStackPushNode(`let` type:OperaterSymbol.OpersterType,value:Any) {
        let sym = OperaterSymbol(type: type, value: value)
        var node = StackNode<OperaterSymbol>()
        node.data = sym
        let _ = operaterStack?.pushNode(var: &node)
    }
    
    func saveToNumberOperatorStack() -> Int {
        if stack?.count == 0 {
            return Int(-1)
        }
        //change stack elements to  number
        var i = 1
        var number = 0
        
        var lastNode:StackNode<CalculatorSymbol>?
        repeat {
            lastNode = stack?.popNode()
            if lastNode == nil {
                break
            }
            let type:CalculatorSymbol = lastNode!.data!
            let value = type.numberValueForType(let: type)
            number += (i * value)
            
            i = i * 10
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
                
                print("=====》\(next?.data?.strinValue)")
                break
            case .Number:
                reverseStack.pushNode(var: &node!)
                print("=====》\(next?.data?.numberValue)")
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


