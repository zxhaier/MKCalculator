//
//  ViewController.swift
//  Calculator
//
//  Created by iosdep on 2023/3/31.
//

import UIKit

class ViewController: UIViewController, MKButtonClickProtocol,CalculatorDelegate {
    var ca:Calculator?
    var rst:UILabel?
    var math:UILabel?
    
    func didClick(type:CalculatorSymbol) {
        if nil == ca {
            ca = Calculator.init()
            ca?.delegate = self
        }
        ca!.pop(type: type)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createUI()
    }

    func createUI() {
        createDisplayView()
        createOperateView()
    }
    
    //显示器
    func createDisplayView() {
        
        let bounds = MKTool.MKScreenBounds.init()
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width:bounds.width , height: 330))
        let mathLabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width:bounds.width , height:view.bounds.size.height*0.5))
        let rstLabel = UILabel.init(frame: CGRect.init(x: 0, y: CGRectGetMaxY(mathLabel.frame), width:bounds.width , height:CGRectGetHeight(mathLabel.bounds)))
        mathLabel.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.6)
        rstLabel.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.6)
        mathLabel.textAlignment = NSTextAlignment.right
        rstLabel.textAlignment = NSTextAlignment.right
        rstLabel.font = UIFont.boldSystemFont(ofSize: 24)
        mathLabel.font = UIFont.boldSystemFont(ofSize: 24)
        mathLabel.textColor = UIColor.white
        rstLabel.textColor = UIColor.white
        self.view.addSubview(rstLabel)
        self.view.addSubview(mathLabel)
        
        self.rst = rstLabel
        self.math = mathLabel
        self.rst?.text = ""
        self.math?.text = ""
    }
    
    //控件区间
    func createOperateView() {
        
        let titles = ["AC","+/-","%","/",
                      "7","8","9","*",
                      "4","5","6","-",
                      "1","2","3","+",
                      "0",".","="]
        let bounds = MKTool.MKScreenBounds.init()
        let col = 4 ,row = 5
        var x:CGFloat = 0,y:CGFloat = 330
        let width = bounds.width / CGFloat(col)
        let height = (bounds.height - CGFloat(y) ) / CGFloat(row)
        let linew:CGFloat = 1.0
        for index in 0..<titles.count {
            let item:MKButtonItem =  MKButtonItem.init(title: titles[index])
            let c = index % col
            let r = index / col
            
            y = CGFloat(index / col) * height+330
            let title = titles[index]
            
            var tmp = width
            if title == "0" {
                tmp = width * 2
            }
            let btnv = MKButtonView.init(frame:  CGRect.init(x: x, y:y , width: tmp, height: height), item: item)
            btnv.delegate = self
            self.view.addSubview(btnv)
            
            if c == col-1 && index >= 0 && index != titles.count - 1  {
                let line = UIView.init(frame: CGRect.init(x: 0, y: y+height-1, width: bounds.width, height: linew))
                line.backgroundColor = UIColor.black
                self.view.addSubview(line);
                
            }
            
            if  r == row-1 && c >= 0 && c < col-1 {
                var line:UIView
                if c == 0 {
                    line = UIView.init(frame: CGRect.init(x: x+width-1, y: CGFloat(330), width: linew, height: bounds.height - CGFloat(330) - height))
                } else {
                    line = UIView.init(frame: CGRect.init(x: x-1, y: CGFloat(330), width: linew, height: bounds.height - height))
                }
                line.backgroundColor = UIColor.black
                self.view.addSubview(line)
            }
            
            x = btnv.frame.maxX
            if x >= bounds.width {
                x = 0
            }
        }
    }
    
    //MARK:-Delegate
    func didInput(value: String) {

        self.math!.text = self.math!.text!.appending(value)
    }
    
    func didClean() {
        self.math!.text = "0"
    }
}

