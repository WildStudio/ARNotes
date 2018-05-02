//
//  ScribbleViewController.swift
//  ARNotes
//
//  Created by Christian Aranda on 02/05/2018.
//  Copyright © 2018 We Are Mobile First. All rights reserved.
//

import UIKit

protocol ScribbleViewControllerDelegate {
    func scribbleUpdated(blank:Bool, image:UIImage?)
}

class ScribbleViewController: UIViewController {
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var tempImageView: UIImageView!
    
    var enabled:Bool = true {
        didSet {
            self.view.alpha = enabled ? 1.0 : 0.5
            self.panGestureRec?.isEnabled = enabled
        }
    }
    
    var brushColor:UIColor = UIColor.blue
    var brushWidth:CGFloat = 4.0
    
    var lastPoint = CGPoint.zero
    var opacity: CGFloat = 1.0
    
    var delegate:ScribbleViewControllerDelegate?
    
    private var swiped = false
    
    private var panGestureRec:UIPanGestureRecognizer?
    
    
    override func viewDidLoad() {
        let gestureRec = UIPanGestureRecognizer(target: self, action: #selector(self.self.didPan(_:)))
        self.view.addGestureRecognizer(gestureRec)
        self.panGestureRec = gestureRec
    }
    
    
    @objc func didPan(_ sender:UIPanGestureRecognizer) {
        switch(sender.state){
        case .began:
            swiped = false
            lastPoint = sender.location(in: self.view)
            break
            
        case .changed:
            swiped = true
            let currentPoint = sender.location(in: view)
            drawLineFrom(fromPoint: lastPoint, toPoint: currentPoint)
            lastPoint = currentPoint
            break
            
        case .ended:
            if !swiped {
                // draw a single point
                drawLineFrom(fromPoint: lastPoint, toPoint: lastPoint)
            }
            let canvasSize = mainImageView.frame.size
            let canvasFrame = CGRect(x: 0, y: 0, width: canvasSize.width, height: canvasSize.height)
            // Merge tempImageView into mainImageView
            UIGraphicsBeginImageContextWithOptions(canvasSize, false,2.0)
            mainImageView.image?.draw(in: canvasFrame, blendMode: .normal, alpha: 1.0)
            tempImageView.image?.draw(in: canvasFrame, blendMode: .normal, alpha: opacity)
            mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            tempImageView.image = nil
            
            self.delegate?.scribbleUpdated(blank:false, image:mainImageView.image)
            break
            
        default: break
        }
    }
    
    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
        let canvasSize = mainImageView.frame.size
        let canvasFrame = CGRect(x: 0, y: 0, width: canvasSize.width, height: canvasSize.height)
        
        UIGraphicsBeginImageContextWithOptions(canvasSize, false,2.0)
        let context = UIGraphicsGetCurrentContext()
        
        tempImageView.image?.draw(in: canvasFrame)
        
        context?.move(to: CGPoint(x:fromPoint.x, y:fromPoint.y))
        context?.addLine(to: CGPoint(x:toPoint.x, y:toPoint.y))
        
        context?.setLineCap(.round)
        context?.setLineWidth(brushWidth)
        
        context?.setStrokeColor(brushColor.cgColor)
        
        context?.setBlendMode(.normal)
        context?.strokePath()
        
        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        tempImageView.alpha = opacity
        UIGraphicsEndImageContext()
    }
    
    @IBAction func reset(_ sender: Any) {
        mainImageView.image = nil
        self.delegate?.scribbleUpdated(blank:true, image:nil)
    }
}
