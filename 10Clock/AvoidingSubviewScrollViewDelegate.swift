//
// Created by joe on 12/2/16.
// Copyright (c) 2016 Joseph Daniels. All rights reserved.
//

import Foundation
import UIKit
public class ConditionallyScrollingTableView: UITableView {

    public var avoidingView: UIView? = nil
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let avoidingView = avoidingView, touches.count == 1, let touch = touches.first else {
                    return super.touchesBegan(touches, with: event)
        }
        let location = touch.location(in: avoidingView)
        self.isScrollEnabled = true
        if avoidingView.bounds.contains(location) {
            self.isScrollEnabled = false
            return
        }
        return super.touchesBegan(touches, with: event)
    }

//    }
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.isScrollEnabled = true
    }
    override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let avoidingView = avoidingView, touches.count == 1, let touch = touches.first else {
//            return super.touchesCancelled(touches, with: event)
//        }
//        let location = touch.location(in: avoidingView)
        self.isScrollEnabled = true
//        if avoidingView.bounds.contains(location) {
//            self.isScrollEnabled = false
////            return false
//        }
        return super.touchesCancelled(touches, with: event)
    }
    override public func touchesShouldBegin (_ touches: Set<UITouch>, with event: UIEvent?, `in` view: UIView) -> Bool {
        guard let avoidingView = avoidingView, touches.count == 1, let touch = touches.first else {
            return super.touchesShouldBegin(touches, with: event, in: view)
        }
        let location = touch.location(in: avoidingView)
        self.isScrollEnabled = true
        if avoidingView.bounds.contains(location) {
            self.isScrollEnabled = false
            return false
        }
        return super.touchesShouldBegin(touches, with: event, in: view)
    }
}


