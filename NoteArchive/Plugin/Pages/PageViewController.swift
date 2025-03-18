//
//  PageViewController.swift
//  Pages
//
//  Created by Nacho Navarro on 03/11/2019.
//  Copyright © 2019 nachonavarro. All rights reserved.
//
//特此免费向任何获得副本的人授予许可
//本软件和相关文档文件（“软件”），以处理
//在软件中不受限制，包括但不限于权利
//使用、复制、修改、合并、发布、分发、再许可和/或销售
//软件的副本，并允许软件的接收者
//根据以下条件提供：
//
//上述版权声明和本许可声明应包含在
//软件的所有副本或实质性部分。
//
//软件按“原样”提供，不提供任何形式的明示或明示担保
//隐含的，包括但不限于适销性保证，
//适用于特定目的且不造成伤害。在任何情况下
//作者或版权持有人对任何索赔、损害赔偿或其他
//因以下原因产生的责任，无论是在合同、侵权或其他诉讼中，
//出于或与软件、使用或其他交易有关
//软件。

import SwiftUI
import UIKit

/// The UIPageViewController in charge of the pages.
@available(iOS 13.0, *)
struct PageViewController: UIViewControllerRepresentable {

    @Binding var currentPage: Int

    var navigationOrientation: UIPageViewController.NavigationOrientation
    var transitionStyle: UIPageViewController.TransitionStyle
    var bounce: Bool
    var wrap: Bool
    var controllers: [UIViewController]
    
    // 更新回调，增加 Bool 值表示翻页方向
    var onPageChangeSuccess: ((Int, Bool) -> Void)?
    var onPageChangeCancel: ((Int) -> Void)?
    var onLastPageReached: ((Int) -> Void)?

    func makeCoordinator() -> PagesCoordinator {
        PagesCoordinator(self)
    }

    func makeUIViewController(context: Context) -> UIPageViewController {
        let pageViewController = UIPageViewController(
            transitionStyle: self.transitionStyle,
            navigationOrientation: self.navigationOrientation
        )
        pageViewController.dataSource = context.coordinator
        pageViewController.delegate = context.coordinator
        pageViewController.view.backgroundColor = .clear

        for view in pageViewController.view.subviews {
            if let scrollView = view as? UIScrollView {
                scrollView.delegate = context.coordinator
                break
            }
        }

        return pageViewController
    }

    func updateUIViewController(_ pageViewController: UIPageViewController, context: Context) {
        let previousPage = context.coordinator.parent.currentPage
        context.coordinator.parent = self

        if currentPage == previousPage,
           pageViewController.viewControllers != nil,
           pageViewController.viewControllers?.count ?? 0 > 0 {
            return
        }
        pageViewController.setViewControllers(
            [controllers[currentPage]],
            direction: currentPage - previousPage > 0 ? .forward : .reverse,
            animated: false
        )
    }

}

@available(iOS 13.0, *)
class PagesCoordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    var parent: PageViewController

    init(_ pageViewController: PageViewController) {
        self.parent = pageViewController
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let index = parent.controllers.firstIndex(of: viewController) else {
            return nil
        }
        return index == 0 ? (self.parent.wrap ? parent.controllers.last : nil) : parent.controllers[index - 1]
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let index = parent.controllers.firstIndex(of: viewController) else {
            return nil
        }
        return index == parent.controllers.count - 1 ? (self.parent.wrap ? parent.controllers.first : nil) : parent.controllers[index + 1]
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        if completed,
           let visibleViewController = pageViewController.viewControllers?.first,
           let index = parent.controllers.firstIndex(of: visibleViewController) {
            let previousPage = parent.currentPage
            parent.currentPage = index

            // 判断翻页方向
            let isForward = index > previousPage
            parent.onPageChangeSuccess?(index, isForward)

            // 检查是否翻到最后一页
            if index == parent.controllers.count - 1 {
                parent.onLastPageReached?(index)
            }
        } else if !completed {
            // 翻页取消
            if let previousViewController = previousViewControllers.first,
               let index = parent.controllers.firstIndex(of: previousViewController) {
                parent.onPageChangeCancel?(index)
            }
        }
    }
}

@available(iOS 13.0, *)
extension PagesCoordinator: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !parent.bounce {
            if parent.navigationOrientation == .horizontal {
                disableHorizontalBounce(scrollView)
            } else {
                disableVerticalBounce(scrollView)
            }
        }
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        scrollViewDidScroll(scrollView)
    }

    private func disableHorizontalBounce(_ scrollView: UIScrollView) {
        if parent.currentPage == 0 && scrollView.contentOffset.x < scrollView.bounds.size.width ||
           parent.currentPage == self.parent.controllers.count - 1 && scrollView.contentOffset.x > scrollView.bounds.size.width {
            scrollView.contentOffset = CGPoint(x: scrollView.bounds.size.width, y: 0)
        }
    }

    private func disableVerticalBounce(_ scrollView: UIScrollView) {
        if parent.currentPage == 0 && scrollView.contentOffset.y < scrollView.bounds.size.height ||
           parent.currentPage == self.parent.controllers.count - 1 && scrollView.contentOffset.y > scrollView.bounds.size.height {
            scrollView.contentOffset = CGPoint(x: 0, y: scrollView.bounds.size.height)
        }
    }
}
