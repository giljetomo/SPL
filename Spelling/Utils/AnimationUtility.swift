//
//  AnimationUtility.swift
//  Spelling
//
//  Created by Gil Jetomo on 2021-06-22.
//

import Foundation
import UIKit

class AnimationUtility: UIViewController, CAAnimationDelegate {
  
  static let kSlideAnimationDuration: CFTimeInterval = 0.6
  
  static func viewSlideInFromRight(toLeft views: UIView) {
    var transition: CATransition? = nil
    transition = CATransition.init()
    transition?.duration = kSlideAnimationDuration
    transition?.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
    transition?.type = CATransitionType.push
    transition?.subtype = CATransitionSubtype.fromRight
    views.layer.add(transition!, forKey: nil)
  }
  
  static func viewSlideInFromLeft(toRight views: UIView) {
    var transition: CATransition? = nil
    transition = CATransition.init()
    transition?.duration = kSlideAnimationDuration
    transition?.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
    transition?.type = CATransitionType.push
    transition?.subtype = CATransitionSubtype.fromLeft
    views.layer.add(transition!, forKey: nil)
  }
  
  static func viewSlideInFromTop(toBottom views: UIView) {
    var transition: CATransition? = nil
    transition = CATransition.init()
    transition?.duration = kSlideAnimationDuration
    transition?.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
    transition?.type = CATransitionType.push
    transition?.subtype = CATransitionSubtype.fromBottom
    views.layer.add(transition!, forKey: nil)
  }
  
  static func viewSlideInFromBottom(toTop views: UIView) {
    var transition: CATransition? = nil
    transition = CATransition.init()
    transition?.duration = kSlideAnimationDuration
    transition?.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
    transition?.type = CATransitionType.push
    transition?.subtype = CATransitionSubtype.fromTop
    views.layer.add(transition!, forKey: nil)
  }
}
