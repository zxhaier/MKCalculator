//
//  MKButton.swift
//  Calculator
//
//  Created by iosdep on 2023/4/7.
//

import Foundation
import UIKit

protocol MKButtonClickProtocol {
    func didClick(type:CalculatorSymbol)
}

class MKButton: UIButton {
    var type:CalculatorSymbol!
    var delegate:MKButtonClickProtocol?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.gray
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(frame:CGRect,type:CalculatorSymbol) {
        self.type = type
        super.init(frame: frame)
        let white = UIColor.init(red: 148.0/255.0, green: 148.0/255.0, blue: 148.0/255.0, alpha: 1)
        let blackColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
        let color = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.3)
        switch type {
        case .Add,
             .Mul,
             .Equal,
             .Sub,
             .Div:
            self.setImage(MKTool.imageFromColor(color: UIColor.orange, size: frame.size), for: UIControl.State.normal)
            self.setImage(MKTool.imageFromColor(color: UIColor.init(red: 190.0/255.0, green: 106.0/255.0, blue: 10.0/255.0, alpha: 1), size: frame.size), for: UIControl.State.highlighted)
            break
        case .Clean,
            .AllClean,
            .NegativeOrPositive,
            .Percentage:
            self.setImage(MKTool.imageFromColor(color: blackColor, size: frame.size), for: UIControl.State.normal)
            self.setImage(MKTool.imageFromColor(color: white, size: frame.size), for: UIControl.State.highlighted)
            break
        default:
            self.setImage(MKTool.imageFromColor(color: color, size: frame.size), for: UIControl.State.normal)
            self.setImage(MKTool.imageFromColor(color: white, size: frame.size), for: UIControl.State.highlighted)
            break
        }
        self.addTarget(self, action: #selector(btnAciton), for: UIControl.Event.touchUpInside)
        
    }
    
    @objc func btnAciton()  {
        if let  delegate = self.delegate {
            delegate.didClick(type: self.type)
        }
    }
    
    
}

class MKButtonView:UIView {
    
    var btn:MKButton!
    var titleLabel:UILabel!
    public var delegate:MKButtonClickProtocol? {
        set {
            btn.delegate = newValue
        }
        get {
            btn.delegate
        }
    }
    
    init(frame: CGRect,item:MKButtonItem) {
    
        let btn:MKButton = MKButton.init(frame: CGRect.init(x: 0, y: 0, width: frame.size.width, height: frame.size.height),type: item.type)
        self.btn = btn
        
        
        let label = UILabel.init(frame: btn.bounds)
        label.text = item.title
        label.font = UIFont.boldSystemFont(ofSize: 36)
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.white
        self.titleLabel = label
        
        super.init(frame: frame)
        self.addSubview(self.btn)
        self.addSubview(self.titleLabel)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
//    func customInit(frame:CGRect,item:MKButtonItem) -> MKButtonView {
//        let v = MKButtonView.init(frame: frame)
//        let btn:MKButton = MKButton.init(frame: v.bounds,type: item.type)
//        v.btn = btn
//        v.addSubview(btn)
//
//        let label = UILabel.init(frame: v.bounds)
//        label.text = item.title
//        label.font = UIFont.boldSystemFont(ofSize: 36)
//        label.textAlignment = NSTextAlignment.center
//        label.textColor = UIColor.white
//        v.addSubview(label)
//        v.titleLabel = label
//        return v
//    }

}


class MKButtonItem {
    
    
    
    
    let type:CalculatorSymbol!
    let title:String!
    
    init(title:String) {
        /*["AC","+/-","%","÷",
        "7","8","9","*",
        "4","5","6","-",
        "1","2","3","+",
        "0",".","="]
        */
        if title == "+" {
            self.type = CalculatorSymbol.Add(value: title)
        } else if (title == "-") {
            self.type = CalculatorSymbol.Sub(value: title)
        } else if (title == "*") {
            self.type = CalculatorSymbol.Mul(value: title)
        } else if (title == "/") {
            self.type = CalculatorSymbol.Div(value: title)
        } else if (title == "AC") {
            self.type = CalculatorSymbol.AllClean(value: title)
        } else if (title == "+/-") {
            self.type = CalculatorSymbol.NegativeOrPositive(value: title)
        } else if (title == "%") {
            self.type = CalculatorSymbol.Percentage(value: title)
        } else if (title == "=") {
            self.type = CalculatorSymbol.Equal(value: title)
        } else if (title == ".") {
            self.type = CalculatorSymbol.Point(value: title)
        } else {
            self.type = CalculatorSymbol.Number(value: Double(title) ?? 0)
        }
        self.title = title
    }
}
