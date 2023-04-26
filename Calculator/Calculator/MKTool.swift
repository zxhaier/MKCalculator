//
//  MKTool.swift
//  Calculator
//
//  Created by iosdep on 2023/3/31.
//

import Foundation
import UIKit




class MKTool {
    struct MKScreenBounds{
        let window = (UIApplication.shared.connectedScenes.first as! UIWindowScene).windows.first
        var width:CGFloat {
            return self.window?.bounds.width ?? 0.0
        }
        var height:CGFloat {
            return self.window?.bounds.height ?? 0.0
        }
    }
    
    
    //返回状态栏高度、底部安全高度
   static func safeSpace()-> (CGFloat,CGFloat?) {
        var statusBarFrame:CGRect
        if #available(iOS 13.0, *) {
            let scenes = UIApplication.shared.connectedScenes
            let windowScene = scenes.first as! UIWindowScene
            let window = windowScene.windows.first
            statusBarFrame = window!.windowScene!.statusBarManager!.statusBarFrame
            
        } else {
            statusBarFrame = UIApplication.shared.statusBarFrame
        }
        
        let bottomFrame = UIApplication.shared.windows.last?.safeAreaInsets
        if bottomFrame != nil {
            return (statusBarFrame.height,bottomFrame!.bottom as CGFloat)
        } else {
            return (statusBarFrame.height,0)
        }
    }
    
    static func imageFromColor(color:UIColor,size:CGSize) -> UIImage{
        let rect = CGRect.init(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}
