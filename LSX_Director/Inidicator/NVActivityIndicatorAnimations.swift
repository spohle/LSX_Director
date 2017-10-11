//
//  NVActivityIndicatorAnimations.swift
//  LSX_Director
//
//  Created by Sven Pohle on 10/5/17.
//  Copyright © 2017 ATVI_MOCAP. All rights reserved.
//

import UIKit

protocol NVActivityIndicatorAnimationDelegate {
    func setUpAnimation(in layer: CALayer, size: CGSize, color: UIColor)
}


class NVActivityIndicatorAnimationAudioEqualizer: NVActivityIndicatorAnimationDelegate {
    
    func setUpAnimation(in layer: CALayer, size: CGSize, color: UIColor) {
        let lineSize = size.width / 9
        let x = (layer.bounds.size.width - lineSize * 7) / 2
        let y = (layer.bounds.size.height - size.height) / 2
        let duration: [CFTimeInterval] = [4.3, 2.5, 1.7, 3.1]
        let values = [0, 0.7, 0.4, 0.05, 0.95, 0.3, 0.9, 0.4, 0.15, 0.18, 0.75, 0.01]
        
        // Draw lines
        for i in 0 ..< 4 {
            let animation = CAKeyframeAnimation()
            
            animation.keyPath = "path"
            animation.isAdditive = true
            animation.values = []
            
            for j in 0 ..< values.count {
                let heightFactor = values[j]
                let height = size.height * CGFloat(heightFactor)
                let point = CGPoint(x: 0, y: size.height - height)
                let path = UIBezierPath(rect: CGRect(origin: point, size: CGSize(width: lineSize, height: height)))
                
                animation.values?.append(path.cgPath)
            }
            animation.duration = duration[i]
            animation.repeatCount = HUGE
            animation.isRemovedOnCompletion = false
            
            let line = NVActivityIndicatorShape.line.layerWith(size: CGSize(width: lineSize, height: size.height), color: color)
            let frame = CGRect(x: x + lineSize * 2 * CGFloat(i),
                               y: y,
                               width: lineSize,
                               height: size.height)
            
            line.frame = frame
            line.add(animation, forKey: "animation")
            layer.addSublayer(line)
        }
    }
}

class NVActivityIndicatorAnimationBallBeat: NVActivityIndicatorAnimationDelegate {
    
    func setUpAnimation(in layer: CALayer, size: CGSize, color: UIColor) {
        let circleSpacing: CGFloat = 2
        let circleSize = (size.width - circleSpacing * 2) / 3
        let x = (layer.bounds.size.width - size.width) / 2
        let y = (layer.bounds.size.height - circleSize) / 2
        let duration: CFTimeInterval = 0.7
        let beginTime = CACurrentMediaTime()
        let beginTimes = [0.35, 0, 0.35]
        
        // Scale animation
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        
        scaleAnimation.keyTimes = [0, 0.5, 1]
        scaleAnimation.values = [1, 0.75, 1]
        scaleAnimation.duration = duration
        
        // Opacity animation
        let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
        
        opacityAnimation.keyTimes = [0, 0.5, 1]
        opacityAnimation.values = [1, 0.2, 1]
        opacityAnimation.duration = duration
        
        // Aniamtion
        let animation = CAAnimationGroup()
        
        animation.animations = [scaleAnimation, opacityAnimation]
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = duration
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false
        
        // Draw circles
        for i in 0 ..< 3 {
            let circle = NVActivityIndicatorShape.circle.layerWith(size: CGSize(width: circleSize, height: circleSize), color: color)
            let frame = CGRect(x: x + circleSize * CGFloat(i) + circleSpacing * CGFloat(i),
                               y: y,
                               width: circleSize,
                               height: circleSize)
            
            animation.beginTime = beginTime + beginTimes[i]
            circle.frame = frame
            circle.add(animation, forKey: "animation")
            layer.addSublayer(circle)
        }
    }
}

class NVActivityIndicatorAnimationBallClipRotate: NVActivityIndicatorAnimationDelegate {
    
    func setUpAnimation(in layer: CALayer, size: CGSize, color: UIColor) {
        let duration: CFTimeInterval = 0.75
        
        //    Scale animation
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        
        scaleAnimation.keyTimes = [0, 0.5, 1]
        scaleAnimation.values = [1, 0.6, 1]
        
        // Rotate animation
        let rotateAnimation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        
        rotateAnimation.keyTimes = scaleAnimation.keyTimes
        rotateAnimation.values = [0, Double.pi, 2 * Double.pi]
        
        // Animation
        let animation = CAAnimationGroup()
        
        animation.animations = [scaleAnimation, rotateAnimation]
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = duration
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false
        
        // Draw circle
        let circle = NVActivityIndicatorShape.ringThirdFour.layerWith(size: CGSize(width: size.width, height: size.height), color: color)
        let frame = CGRect(x: (layer.bounds.size.width - size.width) / 2,
                           y: (layer.bounds.size.height - size.height) / 2,
                           width: size.width,
                           height: size.height)
        
        circle.frame = frame
        circle.add(animation, forKey: "animation")
        layer.addSublayer(circle)
    }
}

class NVActivityIndicatorAnimationBallClipRotateMultiple: NVActivityIndicatorAnimationDelegate {
    
    func setUpAnimation(in layer: CALayer, size: CGSize, color: UIColor) {
        let bigCircleSize: CGFloat = size.width
        let smallCircleSize: CGFloat = size.width / 2
        let longDuration: CFTimeInterval = 1
        let timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        circleOf(shape: .ringTwoHalfHorizontal,
                 duration: longDuration,
                 timingFunction: timingFunction,
                 layer: layer,
                 size: bigCircleSize,
                 color: color, reverse: false)
        circleOf(shape: .ringTwoHalfVertical,
                 duration: longDuration,
                 timingFunction: timingFunction,
                 layer: layer,
                 size: smallCircleSize,
                 color: color, reverse: true)
    }
    
    func createAnimationIn(duration: CFTimeInterval, timingFunction: CAMediaTimingFunction, reverse: Bool) -> CAAnimation {
        // Scale animation
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        
        scaleAnimation.keyTimes = [0, 0.5, 1]
        scaleAnimation.timingFunctions = [timingFunction, timingFunction]
        scaleAnimation.values = [1, 0.6, 1]
        scaleAnimation.duration = duration
        
        // Rotate animation
        let rotateAnimation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        
        rotateAnimation.keyTimes = scaleAnimation.keyTimes
        rotateAnimation.timingFunctions = [timingFunction, timingFunction]
        if !reverse {
            rotateAnimation.values = [0, Double.pi, 2 * Double.pi]
        } else {
            rotateAnimation.values = [0, -Double.pi, -2 * Double.pi]
        }
        rotateAnimation.duration = duration
        
        // Animation
        let animation = CAAnimationGroup()
        
        animation.animations = [scaleAnimation, rotateAnimation]
        animation.duration = duration
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false
        
        return animation
    }
    
    func circleOf(shape: NVActivityIndicatorShape, duration: CFTimeInterval, timingFunction: CAMediaTimingFunction, layer: CALayer, size: CGFloat, color: UIColor, reverse: Bool) {
        let circle = shape.layerWith(size: CGSize(width: size, height: size), color: color)
        let frame = CGRect(x: (layer.bounds.size.width - size) / 2,
                           y: (layer.bounds.size.height - size) / 2,
                           width: size,
                           height: size)
        let animation = createAnimationIn(duration: duration, timingFunction: timingFunction, reverse: reverse)
        
        circle.frame = frame
        circle.add(animation, forKey: "animation")
        layer.addSublayer(circle)
    }
}

class NVActivityIndicatorAnimationBallClipRotatePulse: NVActivityIndicatorAnimationDelegate {
    
    func setUpAnimation(in layer: CALayer, size: CGSize, color: UIColor) {
        let duration: CFTimeInterval = 1
        let timingFunction = CAMediaTimingFunction(controlPoints: 0.09, 0.57, 0.49, 0.9)
        
        smallCircleWith(duration: duration, timingFunction: timingFunction, layer: layer, size: size, color: color)
        bigCircleWith(duration: duration, timingFunction: timingFunction, layer: layer, size: size, color: color)
    }
    
    func smallCircleWith(duration: CFTimeInterval, timingFunction: CAMediaTimingFunction, layer: CALayer, size: CGSize, color: UIColor) {
        // Animation
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        
        animation.keyTimes = [0, 0.3, 1]
        animation.timingFunctions = [timingFunction, timingFunction]
        animation.values = [1, 0.3, 1]
        animation.duration = duration
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false
        
        // Draw circle
        let circleSize = size.width / 2
        let circle = NVActivityIndicatorShape.circle.layerWith(size: CGSize(width: circleSize, height: circleSize), color: color)
        let frame = CGRect(x: (layer.bounds.size.width - circleSize) / 2,
                           y: (layer.bounds.size.height - circleSize) / 2,
                           width: circleSize,
                           height: circleSize)
        
        circle.frame = frame
        circle.add(animation, forKey: "animation")
        layer.addSublayer(circle)
    }
    
    func bigCircleWith(duration: CFTimeInterval, timingFunction: CAMediaTimingFunction, layer: CALayer, size: CGSize, color: UIColor) {
        // Scale animation
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        
        scaleAnimation.keyTimes = [0, 0.5, 1]
        scaleAnimation.timingFunctions = [timingFunction, timingFunction]
        scaleAnimation.values = [1, 0.6, 1]
        scaleAnimation.duration = duration
        
        // Rotate animation
        let rotateAnimation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        
        rotateAnimation.keyTimes = scaleAnimation.keyTimes
        rotateAnimation.timingFunctions = [timingFunction, timingFunction]
        rotateAnimation.values = [0, Double.pi, 2 * Double.pi]
        rotateAnimation.duration = duration
        
        // Animation
        let animation = CAAnimationGroup()
        
        animation.animations = [scaleAnimation, rotateAnimation]
        animation.duration = duration
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false
        
        // Draw circle
        let circle = NVActivityIndicatorShape.ringTwoHalfVertical.layerWith(size: size, color: color)
        let frame = CGRect(x: (layer.bounds.size.width - size.width) / 2,
                           y: (layer.bounds.size.height - size.height) / 2,
                           width: size.width,
                           height: size.height)
        circle.frame = frame
        circle.add(animation, forKey: "animation")
        layer.addSublayer(circle)
    }
}

class NVActivityIndicatorAnimationBallGridBeat: NVActivityIndicatorAnimationDelegate {
    
    func setUpAnimation(in layer: CALayer, size: CGSize, color: UIColor) {
        let circleSpacing: CGFloat = 2
        let circleSize = (size.width - circleSpacing * 2) / 3
        let x = (layer.bounds.size.width - size.width) / 2
        let y = (layer.bounds.size.height - size.height) / 2
        let durations = [0.96, 0.93, 1.19, 1.13, 1.34, 0.94, 1.2, 0.82, 1.19]
        let beginTime = CACurrentMediaTime()
        let beginTimes = [0.36, 0.4, 0.68, 0.41, 0.71, -0.15, -0.12, 0.01, 0.32]
        let timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
        
        // Animation
        let animation = CAKeyframeAnimation(keyPath: "opacity")
        
        animation.keyTimes = [0, 0.5, 1]
        animation.timingFunctions = [timingFunction, timingFunction]
        animation.values = [1, 0.7, 1]
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false
        
        // Draw circles
        for i in 0 ..< 3 {
            for j in 0 ..< 3 {
                let circle = NVActivityIndicatorShape.circle.layerWith(size: CGSize(width: circleSize, height: circleSize), color: color)
                let frame = CGRect(x: x + circleSize * CGFloat(j) + circleSpacing * CGFloat(j),
                                   y: y + circleSize * CGFloat(i) + circleSpacing * CGFloat(i),
                                   width: circleSize,
                                   height: circleSize)
                
                animation.duration = durations[3 * i + j]
                animation.beginTime = beginTime + beginTimes[3 * i + j]
                circle.frame = frame
                circle.add(animation, forKey: "animation")
                layer.addSublayer(circle)
            }
        }
    }
}

class NVActivityIndicatorAnimationBallGridPulse: NVActivityIndicatorAnimationDelegate {
    
    func setUpAnimation(in layer: CALayer, size: CGSize, color: UIColor) {
        let circleSpacing: CGFloat = 2
        let circleSize = (size.width - circleSpacing * 2) / 3
        let x = (layer.bounds.size.width - size.width) / 2
        let y = (layer.bounds.size.height - size.height) / 2
        let durations: [CFTimeInterval] = [0.72, 1.02, 1.28, 1.42, 1.45, 1.18, 0.87, 1.45, 1.06]
        let beginTime = CACurrentMediaTime()
        let beginTimes: [CFTimeInterval] = [ -0.06, 0.25, -0.17, 0.48, 0.31, 0.03, 0.46, 0.78, 0.45]
        let timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
        
        // Scale animation
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        
        scaleAnimation.keyTimes = [0, 0.5, 1]
        scaleAnimation.timingFunctions = [timingFunction, timingFunction]
        scaleAnimation.values = [1, 0.5, 1]
        
        // Opacity animation
        let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
        
        opacityAnimation.keyTimes = [0, 0.5, 1]
        opacityAnimation.timingFunctions = [timingFunction, timingFunction]
        opacityAnimation.values = [1, 0.7, 1]
        
        // Animation
        let animation = CAAnimationGroup()
        
        animation.animations = [scaleAnimation, opacityAnimation]
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false
        
        // Draw circles
        for i in 0 ..< 3 {
            for j in 0 ..< 3 {
                let circle = NVActivityIndicatorShape.circle.layerWith(size: CGSize(width: circleSize, height: circleSize), color: color)
                let frame = CGRect(x: x + circleSize * CGFloat(j) + circleSpacing * CGFloat(j),
                                   y: y + circleSize * CGFloat(i) + circleSpacing * CGFloat(i),
                                   width: circleSize,
                                   height: circleSize)
                
                animation.duration = durations[3 * i + j]
                animation.beginTime = beginTime + beginTimes[3 * i + j]
                circle.frame = frame
                circle.add(animation, forKey: "animation")
                layer.addSublayer(circle)
            }
        }
    }
}

class NVActivityIndicatorAnimationBallPulse: NVActivityIndicatorAnimationDelegate {
    func setUpAnimation(in layer: CALayer, size: CGSize, color: UIColor) {
        let circleSpacing: CGFloat = 2
        let circleSize: CGFloat = (size.width - 2 * circleSpacing) / 3
        let x: CGFloat = (layer.bounds.size.width - size.width) / 2
        let y: CGFloat = (layer.bounds.size.height - circleSize) / 2
        let duration: CFTimeInterval = 0.75
        let beginTime = CACurrentMediaTime()
        let beginTimes: [CFTimeInterval] = [0.12, 0.24, 0.36]
        let timingFunction = CAMediaTimingFunction(controlPoints: 0.2, 0.68, 0.18, 1.08)
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        
        // Animation
        animation.keyTimes = [0, 0.3, 1]
        animation.timingFunctions = [timingFunction, timingFunction]
        animation.values = [1, 0.3, 1]
        animation.duration = duration
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false
        
        // Draw circles
        for i in 0 ..< 3 {
            let circle = NVActivityIndicatorShape.circle.layerWith(size: CGSize(width: circleSize, height: circleSize), color: color)
            let frame = CGRect(x: x + circleSize * CGFloat(i) + circleSpacing * CGFloat(i),
                               y: y,
                               width: circleSize,
                               height: circleSize)
            
            animation.beginTime = beginTime + beginTimes[i]
            circle.frame = frame
            circle.add(animation, forKey: "animation")
            layer.addSublayer(circle)
        }
    }
}

class NVActivityIndicatorAnimationBallPulseRise: NVActivityIndicatorAnimationDelegate {
    
    func setUpAnimation(in layer: CALayer, size: CGSize, color: UIColor) {
        let circleSpacing: CGFloat = 2
        let circleSize = (size.width - 4 * circleSpacing) / 5
        let x = (layer.bounds.size.width - size.width) / 2
        let y = (layer.bounds.size.height - circleSize) / 2
        let deltaY = size.height / 2
        let duration: CFTimeInterval = 1
        let timingFunction = CAMediaTimingFunction(controlPoints: 0.15, 0.46, 0.9, 0.6)
        let oddAnimation = self.oddAnimation(duration: duration, deltaY: deltaY, timingFunction: timingFunction)
        let evenAnimation = self.evenAnimation(duration: duration, deltaY: deltaY, timingFunction: timingFunction)
        
        // Draw circles
        for i in 0 ..< 5 {
            let circle = NVActivityIndicatorShape.circle.layerWith(size: CGSize(width: circleSize, height: circleSize), color: color)
            let frame = CGRect(x: x + circleSize * CGFloat(i) + circleSpacing * CGFloat(i),
                               y: y,
                               width: circleSize,
                               height: circleSize)
            
            circle.frame = frame
            if i % 2 == 0 {
                circle.add(evenAnimation, forKey: "animation")
            } else {
                circle.add(oddAnimation, forKey: "animation")
            }
            layer.addSublayer(circle)
        }
    }
    
    func oddAnimation(duration: CFTimeInterval, deltaY: CGFloat, timingFunction: CAMediaTimingFunction) -> CAAnimation {
        // Scale animation
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        
        scaleAnimation.keyTimes = [0, 0.5, 1]
        scaleAnimation.timingFunctions = [timingFunction, timingFunction]
        scaleAnimation.values = [0.4, 1.1, 0.75]
        scaleAnimation.duration = duration
        
        // Translate animation
        let translateAnimation = CAKeyframeAnimation(keyPath: "transform.translation.y")
        
        translateAnimation.keyTimes = [0, 0.25, 0.75, 1]
        translateAnimation.timingFunctions = [timingFunction, timingFunction, timingFunction]
        translateAnimation.values = [0, deltaY, -deltaY, 0]
        translateAnimation.duration = duration
        
        let animation = CAAnimationGroup()
        
        animation.animations = [scaleAnimation, translateAnimation]
        animation.duration = duration
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false
        
        return animation
    }
    
    func evenAnimation(duration: CFTimeInterval, deltaY: CGFloat, timingFunction: CAMediaTimingFunction) -> CAAnimation {
        // Scale animation
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        
        scaleAnimation.keyTimes = [0, 0.5, 1]
        scaleAnimation.timingFunctions = [timingFunction, timingFunction]
        scaleAnimation.values = [1.1, 0.4, 1]
        scaleAnimation.duration = duration
        
        // Translate animation
        let translateAnimation = CAKeyframeAnimation(keyPath: "transform.translation.y")
        
        translateAnimation.keyTimes = [0, 0.25, 0.75, 1]
        translateAnimation.timingFunctions = [timingFunction, timingFunction, timingFunction]
        translateAnimation.values = [0, -deltaY, deltaY, 0]
        translateAnimation.duration = duration
        
        let animation = CAAnimationGroup()
        
        animation.animations = [scaleAnimation, translateAnimation]
        animation.duration = duration
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false
        
        return animation
    }
}

class NVActivityIndicatorAnimationBallPulseSync: NVActivityIndicatorAnimationDelegate {
    
    func setUpAnimation(in layer: CALayer, size: CGSize, color: UIColor) {
        let circleSpacing: CGFloat = 2
        let circleSize = (size.width - circleSpacing * 2) / 3
        let x = (layer.bounds.size.width - size.width) / 2
        let y = (layer.bounds.size.height - circleSize) / 2
        let deltaY = (size.height / 2 - circleSize / 2) / 2
        let duration: CFTimeInterval = 0.6
        let beginTime = CACurrentMediaTime()
        let beginTimes: [CFTimeInterval] = [0.07, 0.14, 0.21]
        let timingFunciton = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        // Animation
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.y")
        
        animation.keyTimes = [0, 0.33, 0.66, 1]
        animation.timingFunctions = [timingFunciton, timingFunciton, timingFunciton]
        animation.values = [0, deltaY, -deltaY, 0]
        animation.duration = duration
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false
        
        // Draw circles
        for i in 0 ..< 3 {
            let circle = NVActivityIndicatorShape.circle.layerWith(size: CGSize(width: circleSize, height: circleSize), color: color)
            let frame = CGRect(x: x + circleSize * CGFloat(i) + circleSpacing * CGFloat(i),
                               y: y,
                               width: circleSize,
                               height: circleSize)
            
            animation.beginTime = beginTime + beginTimes[i]
            circle.frame = frame
            circle.add(animation, forKey: "animation")
            layer.addSublayer(circle)
        }
    }
}

class NVActivityIndicatorAnimationBallRotate: NVActivityIndicatorAnimationDelegate {
    
    func setUpAnimation(in layer: CALayer, size: CGSize, color: UIColor) {
        let circleSize: CGFloat = size.width / 5
        let duration: CFTimeInterval = 1
        let timingFunction = CAMediaTimingFunction(controlPoints: 0.7, -0.13, 0.22, 0.86)
        
        // Scale animation
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        
        scaleAnimation.keyTimes = [0, 0.5, 1]
        scaleAnimation.timingFunctions = [timingFunction, timingFunction]
        scaleAnimation.values = [1, 0.6, 1]
        scaleAnimation.duration = duration
        
        // Rotate animation
        let rotateAnimation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        
        rotateAnimation.keyTimes = [0, 0.5, 1]
        rotateAnimation.timingFunctions = [timingFunction, timingFunction]
        rotateAnimation.values = [0, Double.pi, 2 * Double.pi]
        rotateAnimation.duration = duration
        
        // Animation
        let animation = CAAnimationGroup()
        
        animation.animations = [scaleAnimation, rotateAnimation]
        animation.duration = duration
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false
        
        // Draw circles
        let leftCircle = NVActivityIndicatorShape.circle.layerWith(size: CGSize(width: circleSize, height: circleSize), color: color)
        let rightCircle = NVActivityIndicatorShape.circle.layerWith(size: CGSize(width: circleSize, height: circleSize), color: color)
        let centerCircle = NVActivityIndicatorShape.circle.layerWith(size: CGSize(width: circleSize, height: circleSize), color: color)
        
        leftCircle.opacity = 0.8
        leftCircle.frame = CGRect(x: 0, y: (size.height - circleSize) / 2, width: circleSize, height: circleSize)
        rightCircle.opacity = 0.8
        rightCircle.frame = CGRect(x: size.width - circleSize, y: (size.height - circleSize) / 2, width: circleSize, height: circleSize)
        centerCircle.frame = CGRect(x: (size.width - circleSize) / 2, y: (size.height - circleSize) / 2, width: circleSize, height: circleSize)
        
        let circle = CALayer()
        let frame = CGRect(x: (layer.bounds.size.width - size.width) / 2, y: (layer.bounds.size.height - size.height) / 2, width: size.width, height: size.height)
        
        circle.frame = frame
        circle.addSublayer(leftCircle)
        circle.addSublayer(rightCircle)
        circle.addSublayer(centerCircle)
        circle.add(animation, forKey: "animation")
        layer.addSublayer(circle)
    }
}

class NVActivityIndicatorAnimationBallRotateChase: NVActivityIndicatorAnimationDelegate {
    
    func setUpAnimation(in layer: CALayer, size: CGSize, color: UIColor) {
        let circleSize = size.width / 5
        
        // Draw circles
        for i in 0 ..< 5 {
            let factor = Float(i) * 1 / 5
            let circle = NVActivityIndicatorShape.circle.layerWith(size: CGSize(width: circleSize, height: circleSize), color: color)
            let animation = rotateAnimation(factor, x: layer.bounds.size.width / 2, y: layer.bounds.size.height / 2, size: CGSize(width: size.width - circleSize, height: size.height - circleSize))
            
            circle.frame = CGRect(x: 0, y: 0, width: circleSize, height: circleSize)
            circle.add(animation, forKey: "animation")
            layer.addSublayer(circle)
        }
    }
    
    func rotateAnimation(_ rate: Float, x: CGFloat, y: CGFloat, size: CGSize) -> CAAnimationGroup {
        let duration: CFTimeInterval = 1.5
        let fromScale = 1 - rate
        let toScale = 0.2 + rate
        let timeFunc = CAMediaTimingFunction(controlPoints: 0.5, 0.15 + rate, 0.25, 1)
        
        // Scale animation
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.duration = duration
        scaleAnimation.repeatCount = HUGE
        scaleAnimation.fromValue = fromScale
        scaleAnimation.toValue = toScale
        
        // Position animation
        let positionAnimation = CAKeyframeAnimation(keyPath: "position")
        positionAnimation.duration = duration
        positionAnimation.repeatCount = HUGE
        positionAnimation.path = UIBezierPath(arcCenter: CGPoint(x: x, y: y), radius: size.width / 2, startAngle: CGFloat(3 * Double.pi * 0.5), endAngle: CGFloat(3 * Double.pi * 0.5 + 2 * Double.pi), clockwise: true).cgPath
        
        // Aniamtion
        let animation = CAAnimationGroup()
        animation.animations = [scaleAnimation, positionAnimation]
        animation.timingFunction = timeFunc
        animation.duration = duration
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false
        
        return animation
    }
}

class NVActivityIndicatorAnimationBallScale: NVActivityIndicatorAnimationDelegate {
    
    func setUpAnimation(in layer: CALayer, size: CGSize, color: UIColor) {
        let duration: CFTimeInterval = 1
        
        // Scale animation
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        
        scaleAnimation.duration = duration
        scaleAnimation.fromValue = 0
        scaleAnimation.toValue = 1
        
        // Opacity animation
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        
        opacityAnimation.duration = duration
        opacityAnimation.fromValue = 1
        opacityAnimation.toValue = 0
        
        // Animation
        let animation = CAAnimationGroup()
        
        animation.animations = [scaleAnimation, opacityAnimation]
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.duration = duration
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false
        
        // Draw circle
        let circle = NVActivityIndicatorShape.circle.layerWith(size: size, color: color)
        
        circle.frame = CGRect(x: (layer.bounds.size.width - size.width) / 2,
                              y: (layer.bounds.size.height - size.height) / 2,
                              width: size.width,
                              height: size.height)
        circle.add(animation, forKey: "animation")
        layer.addSublayer(circle)
    }
}

class NVActivityIndicatorAnimationBallScaleMultiple: NVActivityIndicatorAnimationDelegate {
    
    func setUpAnimation(in layer: CALayer, size: CGSize, color: UIColor) {
        let duration: CFTimeInterval = 1
        let beginTime = CACurrentMediaTime()
        let beginTimes = [0, 0.2, 0.4]
        
        // Scale animation
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        
        scaleAnimation.duration = duration
        scaleAnimation.fromValue = 0
        scaleAnimation.toValue = 1
        
        // Opacity animation
        let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
        
        opacityAnimation.duration = duration
        opacityAnimation.keyTimes = [0, 0.05, 1]
        opacityAnimation.values = [0, 1, 0]
        
        // Animation
        let animation = CAAnimationGroup()
        
        animation.animations = [scaleAnimation, opacityAnimation]
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = duration
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false
        
        // Draw balls
        for i in 0 ..< 3 {
            let circle = NVActivityIndicatorShape.circle.layerWith(size: size, color: color)
            let frame = CGRect(x: (layer.bounds.size.width - size.width) / 2,
                               y: (layer.bounds.size.height - size.height) / 2,
                               width: size.width,
                               height: size.height)
            
            animation.beginTime = beginTime + beginTimes[i]
            circle.frame = frame
            circle.opacity = 0
            circle.add(animation, forKey: "animation")
            layer.addSublayer(circle)
        }
    }
}

class NVActivityIndicatorAnimationBallScaleRipple: NVActivityIndicatorAnimationDelegate {
    
    func setUpAnimation(in layer: CALayer, size: CGSize, color: UIColor) {
        let duration: CFTimeInterval = 1
        let timingFunction = CAMediaTimingFunction(controlPoints: 0.21, 0.53, 0.56, 0.8)
        
        // Scale animation
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        
        scaleAnimation.keyTimes = [0, 0.7]
        scaleAnimation.timingFunction = timingFunction
        scaleAnimation.values = [0.1, 1]
        scaleAnimation.duration = duration
        
        // Opacity animation
        let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
        
        opacityAnimation.keyTimes = [0, 0.7, 1]
        opacityAnimation.timingFunctions = [timingFunction, timingFunction]
        opacityAnimation.values = [1, 0.7, 0]
        opacityAnimation.duration = duration
        
        // Animation
        let animation = CAAnimationGroup()
        
        animation.animations = [scaleAnimation, opacityAnimation]
        animation.duration = duration
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false
        
        // Draw circle
        let circle = NVActivityIndicatorShape.ring.layerWith(size: size, color: color)
        let frame = CGRect(x: (layer.bounds.size.width - size.width) / 2,
                           y: (layer.bounds.size.height - size.height) / 2,
                           width: size.width,
                           height: size.height)
        
        circle.frame = frame
        circle.add(animation, forKey: "animation")
        layer.addSublayer(circle)
    }
}

class NVActivityIndicatorAnimationBallScaleRippleMultiple: NVActivityIndicatorAnimationDelegate {
    
    func setUpAnimation(in layer: CALayer, size: CGSize, color: UIColor) {
        let duration: CFTimeInterval = 1.25
        let beginTime = CACurrentMediaTime()
        let beginTimes = [0, 0.2, 0.4]
        let timingFunction = CAMediaTimingFunction(controlPoints: 0.21, 0.53, 0.56, 0.8)
        
        // Scale animation
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        
        scaleAnimation.keyTimes = [0, 0.7]
        scaleAnimation.timingFunction = timingFunction
        scaleAnimation.values = [0, 1]
        scaleAnimation.duration = duration
        
        // Opacity animation
        let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
        
        opacityAnimation.keyTimes = [0, 0.7, 1]
        opacityAnimation.timingFunctions = [timingFunction, timingFunction]
        opacityAnimation.values = [1, 0.7, 0]
        opacityAnimation.duration = duration
        
        // Animation
        let animation = CAAnimationGroup()
        
        animation.animations = [scaleAnimation, opacityAnimation]
        animation.duration = duration
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false
        
        // Draw circles
        for i in 0 ..< 3 {
            let circle = NVActivityIndicatorShape.ring.layerWith(size: size, color: color)
            let frame = CGRect(x: (layer.bounds.size.width - size.width) / 2,
                               y: (layer.bounds.size.height - size.height) / 2,
                               width: size.width,
                               height: size.height)
            
            animation.beginTime = beginTime + beginTimes[i]
            circle.frame = frame
            circle.add(animation, forKey: "animation")
            layer.addSublayer(circle)
        }
    }
}

class NVActivityIndicatorAnimationBallSpinFadeLoader: NVActivityIndicatorAnimationDelegate {
    
    func setUpAnimation(in layer: CALayer, size: CGSize, color: UIColor) {
        let circleSpacing: CGFloat = -2
        let circleSize = (size.width - 4 * circleSpacing) / 5
        let x = (layer.bounds.size.width - size.width) / 2
        let y = (layer.bounds.size.height - size.height) / 2
        let duration: CFTimeInterval = 1
        let beginTime = CACurrentMediaTime()
        let beginTimes: [CFTimeInterval] = [0, 0.12, 0.24, 0.36, 0.48, 0.6, 0.72, 0.84]
        
        // Scale animation
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        
        scaleAnimation.keyTimes = [0, 0.5, 1]
        scaleAnimation.values = [1, 0.4, 1]
        scaleAnimation.duration = duration
        
        // Opacity animation
        let opacityAnimaton = CAKeyframeAnimation(keyPath: "opacity")
        
        opacityAnimaton.keyTimes = [0, 0.5, 1]
        opacityAnimaton.values = [1, 0.3, 1]
        opacityAnimaton.duration = duration
        
        // Animation
        let animation = CAAnimationGroup()
        
        animation.animations = [scaleAnimation, opacityAnimaton]
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = duration
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false
        
        // Draw circles
        for i in 0 ..< 8 {
            let circle = circleAt(angle: CGFloat(Double.pi / 4) * CGFloat(i),
                                  size: circleSize,
                                  origin: CGPoint(x: x, y: y),
                                  containerSize: size,
                                  color: color)
            
            animation.beginTime = beginTime + beginTimes[i]
            circle.add(animation, forKey: "animation")
            layer.addSublayer(circle)
        }
    }
    
    func circleAt(angle: CGFloat, size: CGFloat, origin: CGPoint, containerSize: CGSize, color: UIColor) -> CALayer {
        let radius = containerSize.width / 2 - size / 2
        let circle = NVActivityIndicatorShape.circle.layerWith(size: CGSize(width: size, height: size), color: color)
        let frame = CGRect(
            x: origin.x + radius * (cos(angle) + 1),
            y: origin.y + radius * (sin(angle) + 1),
            width: size,
            height: size)
        
        circle.frame = frame
        
        return circle
    }
}

class NVActivityIndicatorAnimationBallTrianglePath: NVActivityIndicatorAnimationDelegate {
    
    func setUpAnimation(in layer: CALayer, size: CGSize, color: UIColor) {
        let circleSize = size.width / 5
        let deltaX = size.width / 2 - circleSize / 2
        let deltaY = size.height / 2 - circleSize / 2
        let x = (layer.bounds.size.width - size.width) / 2
        let y = (layer.bounds.size.height - size.height) / 2
        let duration: CFTimeInterval = 2
        let timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        // Animation
        let animation = CAKeyframeAnimation(keyPath: "transform")
        
        animation.keyTimes = [0, 0.33, 0.66, 1]
        animation.timingFunctions = [timingFunction, timingFunction, timingFunction]
        animation.duration = duration
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false
        
        // Top-center circle
        let topCenterCircle = NVActivityIndicatorShape.ring.layerWith(size: CGSize(width: circleSize, height: circleSize), color: color)
        
        changeAnimation(animation, values: ["{0,0}", "{hx,fy}", "{-hx,fy}", "{0,0}"], deltaX: deltaX, deltaY: deltaY)
        topCenterCircle.frame = CGRect(x: x + size.width / 2 - circleSize / 2, y: y, width: circleSize, height: circleSize)
        topCenterCircle.add(animation, forKey: "animation")
        layer.addSublayer(topCenterCircle)
        
        // Bottom-left circle
        let bottomLeftCircle = NVActivityIndicatorShape.ring.layerWith(size: CGSize(width: circleSize, height: circleSize), color: color)
        
        changeAnimation(animation, values: ["{0,0}", "{hx,-fy}", "{fx,0}", "{0,0}"], deltaX: deltaX, deltaY: deltaY)
        bottomLeftCircle.frame = CGRect(x: x, y: y + size.height - circleSize, width: circleSize, height: circleSize)
        bottomLeftCircle.add(animation, forKey: "animation")
        layer.addSublayer(bottomLeftCircle)
        
        // Bottom-right circle
        let bottomRightCircle = NVActivityIndicatorShape.ring.layerWith(size: CGSize(width: circleSize, height: circleSize), color: color)
        
        changeAnimation(animation, values: ["{0,0}", "{-fx,0}", "{-hx,-fy}", "{0,0}"], deltaX: deltaX, deltaY: deltaY)
        bottomRightCircle.frame = CGRect(x: x + size.width - circleSize, y: y + size.height - circleSize, width: circleSize, height: circleSize)
        bottomRightCircle.add(animation, forKey: "animation")
        layer.addSublayer(bottomRightCircle)
    }
    
    func changeAnimation(_ animation: CAKeyframeAnimation, values rawValues: [String], deltaX: CGFloat, deltaY: CGFloat) {
        let values = NSMutableArray(capacity: 5)
        
        for rawValue in rawValues {
            let point = CGPointFromString(translateString(rawValue, deltaX: deltaX, deltaY: deltaY))
            
            values.add(NSValue(caTransform3D: CATransform3DMakeTranslation(point.x, point.y, 0)))
        }
        animation.values = values as [AnyObject]
    }
    
    func translateString(_ valueString: String, deltaX: CGFloat, deltaY: CGFloat) -> String {
        let valueMutableString = NSMutableString(string: valueString)
        let fullDeltaX = 2 * deltaX
        let fullDeltaY = 2 * deltaY
        var range = NSMakeRange(0, valueMutableString.length)
        
        valueMutableString.replaceOccurrences(of: "hx", with: "\(deltaX)", options: NSString.CompareOptions.caseInsensitive, range: range)
        range.length = valueMutableString.length
        valueMutableString.replaceOccurrences(of: "fx", with: "\(fullDeltaX)", options: NSString.CompareOptions.caseInsensitive, range: range)
        range.length = valueMutableString.length
        valueMutableString.replaceOccurrences(of: "hy", with: "\(deltaY)", options: NSString.CompareOptions.caseInsensitive, range: range)
        range.length = valueMutableString.length
        valueMutableString.replaceOccurrences(of: "fy", with: "\(fullDeltaY)", options: NSString.CompareOptions.caseInsensitive, range: range)
        
        return valueMutableString as String
    }
}

class NVActivityIndicatorAnimationBallZigZag: NVActivityIndicatorAnimationDelegate {
    
    func setUpAnimation(in layer: CALayer, size: CGSize, color: UIColor) {
        let circleSize: CGFloat = size.width / 5
        let duration: CFTimeInterval = 0.7
        let deltaX = size.width / 2 - circleSize / 2
        let deltaY = size.height / 2 - circleSize / 2
        let frame = CGRect(x: (layer.bounds.size.width - circleSize) / 2, y: (layer.bounds.size.height - circleSize) / 2, width: circleSize, height: circleSize)
        
        // Circle 1 animation
        let animation = CAKeyframeAnimation(keyPath: "transform")
        
        animation.keyTimes = [0, 0.33, 0.66, 1]
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        animation.values = [
            NSValue(caTransform3D: CATransform3DMakeTranslation(0, 0, 0)),
            NSValue(caTransform3D: CATransform3DMakeTranslation(-deltaX, -deltaY, 0)),
            NSValue(caTransform3D: CATransform3DMakeTranslation(deltaX, -deltaY, 0)),
            NSValue(caTransform3D: CATransform3DMakeTranslation(0, 0, 0)),
        ]
        animation.duration = duration
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false
        
        // Draw circle 1
        circleAt(frame: frame, layer: layer, size: CGSize(width: circleSize, height: circleSize), color: color, animation: animation)
        
        // Circle 2 animation
        animation.values = [
            NSValue(caTransform3D: CATransform3DMakeTranslation(0, 0, 0)),
            NSValue(caTransform3D: CATransform3DMakeTranslation(deltaX, deltaY, 0)),
            NSValue(caTransform3D: CATransform3DMakeTranslation(-deltaX, deltaY, 0)),
            NSValue(caTransform3D: CATransform3DMakeTranslation(0, 0, 0)),
        ]
        
        // Draw circle 2
        circleAt(frame: frame, layer: layer, size: CGSize(width: circleSize, height: circleSize), color: color, animation: animation)
    }
    
    func circleAt(frame: CGRect, layer: CALayer, size: CGSize, color: UIColor, animation: CAAnimation) {
        let circle = NVActivityIndicatorShape.circle.layerWith(size: size, color: color)
        
        circle.frame = frame
        circle.add(animation, forKey: "animation")
        layer.addSublayer(circle)
    }
}

class NVActivityIndicatorAnimationBallZigZagDeflect: NVActivityIndicatorAnimationDelegate {
    
    func setUpAnimation(in layer: CALayer, size: CGSize, color: UIColor) {
        let circleSize: CGFloat = size.width / 5
        let duration: CFTimeInterval = 0.75
        let deltaX = size.width / 2 - circleSize / 2
        let deltaY = size.height / 2 - circleSize / 2
        let frame = CGRect(x: (layer.bounds.size.width - circleSize) / 2, y: (layer.bounds.size.height - circleSize) / 2, width: circleSize, height: circleSize)
        
        // Circle 1 animation
        let animation = CAKeyframeAnimation(keyPath: "transform")
        
        animation.keyTimes = [0, 0.33, 0.66, 1]
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        animation.values = [
            NSValue(caTransform3D: CATransform3DMakeTranslation(0, 0, 0)),
            NSValue(caTransform3D: CATransform3DMakeTranslation(-deltaX, -deltaY, 0)),
            NSValue(caTransform3D: CATransform3DMakeTranslation(deltaX, -deltaY, 0)),
            NSValue(caTransform3D: CATransform3DMakeTranslation(0, 0, 0)),
        ]
        animation.duration = duration
        animation.repeatCount = HUGE
        animation.autoreverses = true
        animation.isRemovedOnCompletion = false
        
        // Draw circle 1
        circleAt(frame: frame, layer: layer, size: CGSize(width: circleSize, height: circleSize), color: color, animation: animation)
        
        // Circle 2 animation
        animation.values = [
            NSValue(caTransform3D: CATransform3DMakeTranslation(0, 0, 0)),
            NSValue(caTransform3D: CATransform3DMakeTranslation(deltaX, deltaY, 0)),
            NSValue(caTransform3D: CATransform3DMakeTranslation(-deltaX, deltaY, 0)),
            NSValue(caTransform3D: CATransform3DMakeTranslation(0, 0, 0)),
        ]
        
        // Draw circle 2
        circleAt(frame: frame, layer: layer, size: CGSize(width: circleSize, height: circleSize), color: color, animation: animation)
    }
    
    func circleAt(frame: CGRect, layer: CALayer, size: CGSize, color: UIColor, animation: CAAnimation) {
        let circle = NVActivityIndicatorShape.circle.layerWith(size: size, color: color)
        
        circle.frame = frame
        circle.add(animation, forKey: "animation")
        layer.addSublayer(circle)
    }
}

class NVActivityIndicatorAnimationBlank: NVActivityIndicatorAnimationDelegate {
    
    func setUpAnimation(in _: CALayer, size _: CGSize, color _: UIColor) {
        // Do nothing
    }
}

class NVActivityIndicatorAnimationCubeTransition: NVActivityIndicatorAnimationDelegate {
    
    func setUpAnimation(in layer: CALayer, size: CGSize, color: UIColor) {
        let squareSize = size.width / 5
        let x = (layer.bounds.size.width - size.width) / 2
        let y = (layer.bounds.size.height - size.height) / 2
        let deltaX = size.width - squareSize
        let deltaY = size.height - squareSize
        let duration: CFTimeInterval = 1.6
        let beginTime = CACurrentMediaTime()
        let beginTimes: [CFTimeInterval] = [0, -0.8]
        let timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        // Scale animation
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        
        scaleAnimation.keyTimes = [0, 0.25, 0.5, 0.75, 1]
        scaleAnimation.timingFunctions = [timingFunction, timingFunction, timingFunction, timingFunction]
        scaleAnimation.values = [1, 0.5, 1, 0.5, 1]
        scaleAnimation.duration = duration
        
        // Translate animation
        let translateAnimation = CAKeyframeAnimation(keyPath: "transform.translation")
        
        translateAnimation.keyTimes = scaleAnimation.keyTimes
        translateAnimation.timingFunctions = scaleAnimation.timingFunctions
        translateAnimation.values = [
            NSValue(cgSize: CGSize(width: 0, height: 0)),
            NSValue(cgSize: CGSize(width: deltaX, height: 0)),
            NSValue(cgSize: CGSize(width: deltaX, height: deltaY)),
            NSValue(cgSize: CGSize(width: 0, height: deltaY)),
            NSValue(cgSize: CGSize(width: 0, height: 0)),
        ]
        translateAnimation.duration = duration
        
        // Rotate animation
        let rotateAnimation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        
        rotateAnimation.keyTimes = scaleAnimation.keyTimes
        rotateAnimation.timingFunctions = scaleAnimation.timingFunctions
        rotateAnimation.values = [0, -Double.pi / 2, -Double.pi, -1.5 * Double.pi, -2 * Double.pi]
        rotateAnimation.duration = duration
        
        // Animation
        let animation = CAAnimationGroup()
        
        animation.animations = [scaleAnimation, translateAnimation, rotateAnimation]
        animation.duration = duration
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false
        
        // Draw squares
        for i in 0 ..< 2 {
            let square = NVActivityIndicatorShape.rectangle.layerWith(size: CGSize(width: squareSize, height: squareSize), color: color)
            let frame = CGRect(x: x, y: y, width: squareSize, height: squareSize)
            
            animation.beginTime = beginTime + beginTimes[i]
            square.frame = frame
            square.add(animation, forKey: "animation")
            layer.addSublayer(square)
        }
    }
}

class NVActivityIndicatorAnimationLineScale: NVActivityIndicatorAnimationDelegate {
    
    func setUpAnimation(in layer: CALayer, size: CGSize, color: UIColor) {
        let lineSize = size.width / 9
        let x = (layer.bounds.size.width - size.width) / 2
        let y = (layer.bounds.size.height - size.height) / 2
        let duration: CFTimeInterval = 1
        let beginTime = CACurrentMediaTime()
        let beginTimes = [0.1, 0.2, 0.3, 0.4, 0.5]
        let timingFunction = CAMediaTimingFunction(controlPoints: 0.2, 0.68, 0.18, 1.08)
        
        // Animation
        let animation = CAKeyframeAnimation(keyPath: "transform.scale.y")
        
        animation.keyTimes = [0, 0.5, 1]
        animation.timingFunctions = [timingFunction, timingFunction]
        animation.values = [1, 0.4, 1]
        animation.duration = duration
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false
        
        // Draw lines
        for i in 0 ..< 5 {
            let line = NVActivityIndicatorShape.line.layerWith(size: CGSize(width: lineSize, height: size.height), color: color)
            let frame = CGRect(x: x + lineSize * 2 * CGFloat(i), y: y, width: lineSize, height: size.height)
            
            animation.beginTime = beginTime + beginTimes[i]
            line.frame = frame
            line.add(animation, forKey: "animation")
            layer.addSublayer(line)
        }
    }
}

class NVActivityIndicatorAnimationLineScaleParty: NVActivityIndicatorAnimationDelegate {
    
    func setUpAnimation(in layer: CALayer, size: CGSize, color: UIColor) {
        let lineSize = size.width / 7
        let x = (layer.bounds.size.width - size.width) / 2
        let y = (layer.bounds.size.height - size.height) / 2
        let durations: [CFTimeInterval] = [1.26, 0.43, 1.01, 0.73]
        let beginTime = CACurrentMediaTime()
        let beginTimes: [CFTimeInterval] = [0.77, 0.29, 0.28, 0.74]
        let timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
        
        // Animation
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        
        animation.keyTimes = [0, 0.5, 1]
        animation.timingFunctions = [timingFunction, timingFunction]
        animation.values = [1, 0.5, 1]
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false
        
        for i in 0 ..< 4 {
            let line = NVActivityIndicatorShape.line.layerWith(size: CGSize(width: lineSize, height: size.height), color: color)
            let frame = CGRect(x: x + lineSize * 2 * CGFloat(i), y: y, width: lineSize, height: size.height)
            
            animation.beginTime = beginTime + beginTimes[i]
            animation.duration = durations[i]
            line.frame = frame
            line.add(animation, forKey: "animation")
            layer.addSublayer(line)
        }
    }
}

class NVActivityIndicatorAnimationLineScalePulseOut: NVActivityIndicatorAnimationDelegate {
    
    func setUpAnimation(in layer: CALayer, size: CGSize, color: UIColor) {
        let lineSize = size.width / 9
        let x = (layer.bounds.size.width - size.width) / 2
        let y = (layer.bounds.size.height - size.height) / 2
        let duration: CFTimeInterval = 1
        let beginTime = CACurrentMediaTime()
        let beginTimes = [0.4, 0.2, 0, 0.2, 0.4]
        let timingFunction = CAMediaTimingFunction(controlPoints: 0.85, 0.25, 0.37, 0.85)
        
        // Animation
        let animation = CAKeyframeAnimation(keyPath: "transform.scale.y")
        
        animation.keyTimes = [0, 0.5, 1]
        animation.timingFunctions = [timingFunction, timingFunction]
        animation.values = [1, 0.4, 1]
        animation.duration = duration
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false
        
        // Draw lines
        for i in 0 ..< 5 {
            let line = NVActivityIndicatorShape.line.layerWith(size: CGSize(width: lineSize, height: size.height), color: color)
            let frame = CGRect(x: x + lineSize * 2 * CGFloat(i),
                               y: y,
                               width: lineSize,
                               height: size.height)
            
            animation.beginTime = beginTime + beginTimes[i]
            line.frame = frame
            line.add(animation, forKey: "animation")
            layer.addSublayer(line)
        }
    }
}

class NVActivityIndicatorAnimationLineScalePulseOutRapid: NVActivityIndicatorAnimationDelegate {
    
    func setUpAnimation(in layer: CALayer, size: CGSize, color: UIColor) {
        let lineSize = size.width / 9
        let x = (layer.bounds.size.width - size.width) / 2
        let y = (layer.bounds.size.height - size.height) / 2
        let duration: CFTimeInterval = 0.9
        let beginTime = CACurrentMediaTime()
        let beginTimes = [0.5, 0.25, 0, 0.25, 0.5]
        let timingFunction = CAMediaTimingFunction(controlPoints: 0.11, 0.49, 0.38, 0.78)
        
        // Animation
        let animation = CAKeyframeAnimation(keyPath: "transform.scale.y")
        
        animation.keyTimes = [0, 0.8, 0.9]
        animation.timingFunctions = [timingFunction, timingFunction]
        animation.beginTime = beginTime
        animation.values = [1, 0.3, 1]
        animation.duration = duration
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false
        
        // Draw lines
        for i in 0 ..< 5 {
            let line = NVActivityIndicatorShape.line.layerWith(size: CGSize(width: lineSize, height: size.height), color: color)
            let frame = CGRect(x: x + lineSize * 2 * CGFloat(i),
                               y: y,
                               width: lineSize,
                               height: size.height)
            
            animation.beginTime = beginTime + beginTimes[i]
            line.frame = frame
            line.add(animation, forKey: "animation")
            layer.addSublayer(line)
        }
    }
}

class NVActivityIndicatorAnimationLineSpinFadeLoader: NVActivityIndicatorAnimationDelegate {
    
    func setUpAnimation(in layer: CALayer, size: CGSize, color: UIColor) {
        let lineSpacing: CGFloat = 2
        let lineSize = CGSize(width: (size.width - 4 * lineSpacing) / 5, height: (size.height - 2 * lineSpacing) / 3)
        let x = (layer.bounds.size.width - size.width) / 2
        let y = (layer.bounds.size.height - size.height) / 2
        let duration: CFTimeInterval = 1.2
        let beginTime = CACurrentMediaTime()
        let beginTimes: [CFTimeInterval] = [0.12, 0.24, 0.36, 0.48, 0.6, 0.72, 0.84, 0.96]
        let timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        // Animation
        let animation = CAKeyframeAnimation(keyPath: "opacity")
        
        animation.keyTimes = [0, 0.5, 1]
        animation.timingFunctions = [timingFunction, timingFunction]
        animation.values = [1, 0.3, 1]
        animation.duration = duration
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false
        
        // Draw lines
        for i in 0 ..< 8 {
            let line = lineAt(angle: CGFloat(Double.pi / 4 * Double(i)),
                              size: lineSize,
                              origin: CGPoint(x: x, y: y),
                              containerSize: size,
                              color: color)
            
            animation.beginTime = beginTime + beginTimes[i]
            line.add(animation, forKey: "animation")
            layer.addSublayer(line)
        }
    }
    
    func lineAt(angle: CGFloat, size: CGSize, origin: CGPoint, containerSize: CGSize, color: UIColor) -> CALayer {
        let radius = containerSize.width / 2 - max(size.width, size.height) / 2
        let lineContainerSize = CGSize(width: max(size.width, size.height), height: max(size.width, size.height))
        let lineContainer = CALayer()
        let lineContainerFrame = CGRect(
            x: origin.x + radius * (cos(angle) + 1),
            y: origin.y + radius * (sin(angle) + 1),
            width: lineContainerSize.width,
            height: lineContainerSize.height)
        let line = NVActivityIndicatorShape.line.layerWith(size: size, color: color)
        let lineFrame = CGRect(
            x: (lineContainerSize.width - size.width) / 2,
            y: (lineContainerSize.height - size.height) / 2,
            width: size.width,
            height: size.height)
        
        lineContainer.frame = lineContainerFrame
        line.frame = lineFrame
        lineContainer.addSublayer(line)
        lineContainer.sublayerTransform = CATransform3DMakeRotation(CGFloat(Double.pi / 2) + angle, 0, 0, 1)
        
        return lineContainer
    }
}

class NVActivityIndicatorAnimationOrbit: NVActivityIndicatorAnimationDelegate {
    let duration: CFTimeInterval = 1.9
    let satelliteCoreRatio: CGFloat = 0.25
    let distanceRatio: CGFloat = 1.5 // distance / core size
    
    var coreSize: CGFloat = 0
    var satelliteSize: CGFloat = 0
    
    func setUpAnimation(in layer: CALayer, size: CGSize, color: UIColor) {
        coreSize = size.width / (1 + satelliteCoreRatio + distanceRatio)
        satelliteSize = coreSize * satelliteCoreRatio
        
        ring1InLayer(layer, size: size, color: color)
        ring2InLayer(layer, size: size, color: color)
        coreInLayer(layer, size: size, color: color)
        satelliteInLayer(layer, size: size, color: color)
    }
    
    func ring1InLayer(_ layer: CALayer, size _: CGSize, color: UIColor) {
        // Scale animation
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        
        scaleAnimation.keyTimes = [0, 0.45, 0.45, 1]
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        scaleAnimation.values = [0, 0, 1.3, 2]
        scaleAnimation.duration = duration
        
        // Opacity animation
        let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
        let timingFunction = CAMediaTimingFunction(controlPoints: 0.19, 1, 0.22, 1)
        
        opacityAnimation.keyTimes = [0, 0.45, 1]
        scaleAnimation.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear), timingFunction]
        opacityAnimation.values = [0.8, 0.8, 0]
        opacityAnimation.duration = duration
        
        // Animation
        let animation = CAAnimationGroup()
        
        animation.animations = [scaleAnimation, opacityAnimation]
        animation.duration = duration
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false
        
        // Draw circle
        let circle = NVActivityIndicatorShape.circle.layerWith(size: CGSize(width: coreSize, height: coreSize), color: color)
        let frame = CGRect(x: (layer.bounds.size.width - coreSize) / 2,
                           y: (layer.bounds.size.height - coreSize) / 2,
                           width: coreSize,
                           height: coreSize)
        
        circle.frame = frame
        circle.add(animation, forKey: "animation")
        layer.addSublayer(circle)
    }
    
    func ring2InLayer(_ layer: CALayer, size _: CGSize, color: UIColor) {
        // Scale animation
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        
        scaleAnimation.keyTimes = [0, 0.55, 0.55, 1]
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        scaleAnimation.values = [0, 0, 1.3, 2.1]
        scaleAnimation.duration = duration
        
        // Opacity animation
        let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
        let timingFunction = CAMediaTimingFunction(controlPoints: 0.19, 1, 0.22, 1)
        
        opacityAnimation.keyTimes = [0, 0.55, 0.65, 1]
        scaleAnimation.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear), timingFunction]
        opacityAnimation.values = [0.7, 0.7, 0, 0]
        opacityAnimation.duration = duration
        
        // Animation
        let animation = CAAnimationGroup()
        
        animation.animations = [scaleAnimation, opacityAnimation]
        animation.duration = duration
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false
        
        // Draw circle
        let circle = NVActivityIndicatorShape.circle.layerWith(size: CGSize(width: coreSize, height: coreSize), color: color)
        let frame = CGRect(x: (layer.bounds.size.width - coreSize) / 2,
                           y: (layer.bounds.size.height - coreSize) / 2,
                           width: coreSize,
                           height: coreSize)
        
        circle.frame = frame
        circle.add(animation, forKey: "animation")
        layer.addSublayer(circle)
    }
    
    func coreInLayer(_ layer: CALayer, size _: CGSize, color: UIColor) {
        let inTimingFunction = CAMediaTimingFunction(controlPoints: 0.7, 0, 1, 0.5)
        let outTimingFunction = CAMediaTimingFunction(controlPoints: 0, 0.7, 0.5, 1)
        let standByTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        // Scale animation
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        
        scaleAnimation.keyTimes = [0, 0.45, 0.55, 1]
        scaleAnimation.timingFunctions = [inTimingFunction, standByTimingFunction, outTimingFunction]
        scaleAnimation.values = [1, 1.3, 1.3, 1]
        scaleAnimation.duration = duration
        scaleAnimation.repeatCount = HUGE
        scaleAnimation.isRemovedOnCompletion = false
        
        // Draw circle
        let circle = NVActivityIndicatorShape.circle.layerWith(size: CGSize(width: coreSize, height: coreSize), color: color)
        let frame = CGRect(x: (layer.bounds.size.width - coreSize) / 2,
                           y: (layer.bounds.size.height - coreSize) / 2,
                           width: coreSize,
                           height: coreSize)
        
        circle.frame = frame
        circle.add(scaleAnimation, forKey: "animation")
        layer.addSublayer(circle)
    }
    
    func satelliteInLayer(_ layer: CALayer, size: CGSize, color: UIColor) {
        // Rotate animation
        let rotateAnimation = CAKeyframeAnimation(keyPath: "position")
        
        rotateAnimation.path = UIBezierPath(arcCenter: CGPoint(x: layer.bounds.midX, y: layer.bounds.midY),
                                            radius: (size.width - satelliteSize) / 2,
                                            startAngle: CGFloat(Double.pi * 1.5),
                                            endAngle: CGFloat(Double.pi * 1.5 + 4 * Double.pi),
                                            clockwise: true).cgPath
        rotateAnimation.duration = duration * 2
        rotateAnimation.repeatCount = HUGE
        rotateAnimation.isRemovedOnCompletion = false
        
        // Draw circle
        let circle = NVActivityIndicatorShape.circle.layerWith(size: CGSize(width: satelliteSize, height: satelliteSize), color: color)
        let frame = CGRect(x: 0, y: 0, width: satelliteSize, height: satelliteSize)
        
        circle.frame = frame
        circle.add(rotateAnimation, forKey: "animation")
        layer.addSublayer(circle)
    }
}

class NVActivityIndicatorAnimationPacman: NVActivityIndicatorAnimationDelegate {
    
    func setUpAnimation(in layer: CALayer, size: CGSize, color: UIColor) {
        circleInLayer(layer, size: size, color: color)
        pacmanInLayer(layer, size: size, color: color)
    }
    
    func pacmanInLayer(_ layer: CALayer, size: CGSize, color: UIColor) {
        let pacmanSize = 2 * size.width / 3
        let pacmanDuration: CFTimeInterval = 0.5
        let timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
        
        // Stroke start animation
        let strokeStartAnimation = CAKeyframeAnimation(keyPath: "strokeStart")
        
        strokeStartAnimation.keyTimes = [0, 0.5, 1]
        strokeStartAnimation.timingFunctions = [timingFunction, timingFunction]
        strokeStartAnimation.values = [0.125, 0, 0.125]
        strokeStartAnimation.duration = pacmanDuration
        
        // Stroke end animation
        let strokeEndAnimation = CAKeyframeAnimation(keyPath: "strokeEnd")
        
        strokeEndAnimation.keyTimes = [0, 0.5, 1]
        strokeEndAnimation.timingFunctions = [timingFunction, timingFunction]
        strokeEndAnimation.values = [0.875, 1, 0.875]
        strokeEndAnimation.duration = pacmanDuration
        
        // Animation
        let animation = CAAnimationGroup()
        
        animation.animations = [strokeStartAnimation, strokeEndAnimation]
        animation.duration = pacmanDuration
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false
        
        // Draw pacman
        let pacman = NVActivityIndicatorShape.pacman.layerWith(size: CGSize(width: pacmanSize, height: pacmanSize), color: color)
        let frame = CGRect(
            x: (layer.bounds.size.width - size.width) / 2,
            y: (layer.bounds.size.height - pacmanSize) / 2,
            width: pacmanSize,
            height: pacmanSize
        )
        
        pacman.frame = frame
        pacman.add(animation, forKey: "animation")
        layer.addSublayer(pacman)
    }
    
    func circleInLayer(_ layer: CALayer, size: CGSize, color: UIColor) {
        let circleSize = size.width / 5
        let circleDuration: CFTimeInterval = 1
        
        // Translate animation
        let translateAnimation = CABasicAnimation(keyPath: "transform.translation.x")
        
        translateAnimation.fromValue = 0
        translateAnimation.toValue = -size.width / 2
        translateAnimation.duration = circleDuration
        
        // Opacity animation
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        
        opacityAnimation.fromValue = 1
        opacityAnimation.toValue = 0.7
        opacityAnimation.duration = circleDuration
        
        // Animation
        let animation = CAAnimationGroup()
        
        animation.animations = [translateAnimation, opacityAnimation]
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = circleDuration
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false
        
        // Draw circles
        let circle = NVActivityIndicatorShape.circle.layerWith(size: CGSize(width: circleSize, height: circleSize), color: color)
        let frame = CGRect(
            x: (layer.bounds.size.width - size.width) / 2 + size.width - circleSize,
            y: (layer.bounds.size.height - circleSize) / 2,
            width: circleSize,
            height: circleSize
        )
        
        circle.frame = frame
        circle.add(animation, forKey: "animation")
        layer.addSublayer(circle)
    }
}

class NVActivityIndicatorAnimationSemiCircleSpin: NVActivityIndicatorAnimationDelegate {
    
    func setUpAnimation(in layer: CALayer, size: CGSize, color: UIColor) {
        let duration: CFTimeInterval = 0.6
        
        // Animation
        let animation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        
        animation.keyTimes = [0, 0.5, 1]
        animation.values = [0, Double.pi, 2 * Double.pi]
        animation.duration = duration
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false
        
        // Draw circle
        let circle = NVActivityIndicatorShape.circleSemi.layerWith(size: size, color: color)
        let frame = CGRect(
            x: (layer.bounds.width - size.width) / 2,
            y: (layer.bounds.height - size.height) / 2,
            width: size.width,
            height: size.height
        )
        
        circle.frame = frame
        circle.add(animation, forKey: "animation")
        layer.addSublayer(circle)
    }
}

class NVActivityIndicatorAnimationSquareSpin: NVActivityIndicatorAnimationDelegate {
    
    func setUpAnimation(in layer: CALayer, size: CGSize, color: UIColor) {
        let duration: CFTimeInterval = 3
        let timingFunction = CAMediaTimingFunction(controlPoints: 0.09, 0.57, 0.49, 0.9)
        
        // Animation
        let animation = CAKeyframeAnimation(keyPath: "transform")
        
        animation.keyTimes = [0, 0.25, 0.5, 0.75, 1]
        animation.timingFunctions = [timingFunction, timingFunction, timingFunction, timingFunction]
        animation.values = [
            NSValue(caTransform3D: CATransform3DConcat(createRotateXTransform(angle: 0), createRotateYTransform(angle: 0))),
            NSValue(caTransform3D: CATransform3DConcat(createRotateXTransform(angle: CGFloat(Double.pi)), createRotateYTransform(angle: 0))),
            NSValue(caTransform3D: CATransform3DConcat(createRotateXTransform(angle: CGFloat(Double.pi)), createRotateYTransform(angle: CGFloat(Double.pi)))),
            NSValue(caTransform3D: CATransform3DConcat(createRotateXTransform(angle: 0), createRotateYTransform(angle: CGFloat(Double.pi)))),
            NSValue(caTransform3D: CATransform3DConcat(createRotateXTransform(angle: 0), createRotateYTransform(angle: 0))),
        ]
        animation.duration = duration
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false
        
        // Draw square
        let square = NVActivityIndicatorShape.rectangle.layerWith(size: size, color: color)
        let frame = CGRect(x: (layer.bounds.size.width - size.width) / 2,
                           y: (layer.bounds.size.height - size.height) / 2,
                           width: size.width,
                           height: size.height)
        
        square.frame = frame
        square.add(animation, forKey: "animation")
        layer.addSublayer(square)
    }
    
    func createRotateXTransform(angle: CGFloat) -> CATransform3D {
        var transform = CATransform3DMakeRotation(angle, 1, 0, 0)
        
        transform.m34 = CGFloat(-1) / 100
        
        return transform
    }
    
    func createRotateYTransform(angle: CGFloat) -> CATransform3D {
        var transform = CATransform3DMakeRotation(angle, 0, 1, 0)
        
        transform.m34 = CGFloat(-1) / 100
        
        return transform
    }
}

class NVActivityIndicatorAnimationTriangleSkewSpin: NVActivityIndicatorAnimationDelegate {
    
    func setUpAnimation(in layer: CALayer, size: CGSize, color: UIColor) {
        let x = (layer.bounds.size.width - size.width) / 2
        let y = (layer.bounds.size.height - size.height) / 2
        let duration: CFTimeInterval = 3
        let timingFunction = CAMediaTimingFunction(controlPoints: 0.09, 0.57, 0.49, 0.9)
        
        // Animation
        let animation = CAKeyframeAnimation(keyPath: "transform")
        
        animation.keyTimes = [0, 0.25, 0.5, 0.75, 1]
        animation.timingFunctions = [timingFunction, timingFunction, timingFunction, timingFunction]
        animation.values = [
            NSValue(caTransform3D: CATransform3DConcat(createRotateXTransform(angle: 0), createRotateYTransform(angle: 0))),
            NSValue(caTransform3D: CATransform3DConcat(createRotateXTransform(angle: CGFloat(Double.pi)), createRotateYTransform(angle: 0))),
            NSValue(caTransform3D: CATransform3DConcat(createRotateXTransform(angle: CGFloat(Double.pi)), createRotateYTransform(angle: CGFloat(Double.pi)))),
            NSValue(caTransform3D: CATransform3DConcat(createRotateXTransform(angle: 0), createRotateYTransform(angle: CGFloat(Double.pi)))),
            NSValue(caTransform3D: CATransform3DConcat(createRotateXTransform(angle: 0), createRotateYTransform(angle: 0))),
        ]
        animation.duration = duration
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false
        
        // Draw triangle
        let triangle = NVActivityIndicatorShape.triangle.layerWith(size: size, color: color)
        
        triangle.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
        triangle.add(animation, forKey: "animation")
        layer.addSublayer(triangle)
    }
    
    func createRotateXTransform(angle: CGFloat) -> CATransform3D {
        var transform = CATransform3DMakeRotation(angle, 1, 0, 0)
        
        transform.m34 = CGFloat(-1) / 100
        
        return transform
    }
    
    func createRotateYTransform(angle: CGFloat) -> CATransform3D {
        var transform = CATransform3DMakeRotation(angle, 0, 1, 0)
        
        transform.m34 = CGFloat(-1) / 100
        
        return transform
    }
}

