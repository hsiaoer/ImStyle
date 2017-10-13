//
//  PageViewController.swift
//  ImStyle
//
//  Created by Jake Carlson on 10/12/17.
//  Copyright © 2017 ImageStyle. All rights reserved.
//

// tutorial: https://spin.atomicobject.com/2015/12/23/swift-uipageviewcontroller-tutorial/

import Foundation
import UIKit

let modelPicker = ModelPickerController()

class PageViewController: UIPageViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        
        if orderedViewControllers.count > 2 {
            setViewControllers([orderedViewControllers[1]],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
    }
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.newViewController(name: "PhotoLib"),
                self.newViewController(name: "Main"),
                self.newViewController(name: "VR"),
                self.newViewController(name: "Settings")]
    }()
    
    private func newViewController(name: String) -> UIViewController {
        return (self.storyboard?.instantiateViewController(withIdentifier: "\(name)ViewController"))!
    }
    
}

extension PageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return orderedViewControllers.last
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return orderedViewControllers.first
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
}
