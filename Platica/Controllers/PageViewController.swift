////  PageViewController.swift
//  Platica
//
//  Created by Jesus Lopez on 11/13/20.
//  
// 

import Foundation
import UIKit

class PageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var pages = [UIViewController]()

        override func viewDidLoad() {
            super.viewDidLoad()
            self.delegate = self
            self.dataSource = self

            let p1: UIViewController! = storyboard?.instantiateViewController(withIdentifier: "TestView")
            let p2: UIViewController! = storyboard?.instantiateViewController(withIdentifier: "ConversationView")

            // etc ...

            pages.append(p1)
            pages.append(p2)

            // etc ...

            setViewControllers([p2], direction: UIPageViewController.NavigationDirection.forward, animated: false, completion: nil)
        }

        func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController)-> UIViewController? {
           
            let cur = pages.firstIndex(of: viewController)!

            // if you prefer to NOT scroll circularly, simply add here:
            if cur == 0 { return nil }

            var prev = (cur - 1) % pages.count
            if prev < 0 {
                prev = pages.count - 1
            }
            return pages[prev]
        }

        func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController)-> UIViewController? {
             
            let cur = pages.firstIndex(of: viewController)!

            // if you prefer to NOT scroll circularly, simply add here:
            if cur == (pages.count - 1) { return nil }

            let nxt = abs((cur + 1) % pages.count)
            return pages[nxt]
        }

        func presentationIndex(for pageViewController: UIPageViewController)-> Int {
            return pages.count
        }
}
