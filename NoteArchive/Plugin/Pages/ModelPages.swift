//
//型号Pages.swift
//页面
//
//由Nacho Navarro于2019年11月1日创建。
//版权所有©2019 nachonavarro。保留所有权利。
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

/// A paging view that generates pages dynamically based on some user-defined data.
@available(iOS 13.0, *)
public struct ModelPages<Data, Content>: View where Data: RandomAccessCollection, Content: View {

    @Binding var currentPage: Int
    var items: [Data.Element]

    private var template: (Int, Data.Element) -> Content
    private var navigationOrientation: UIPageViewController.NavigationOrientation
    private var transitionStyle: UIPageViewController.TransitionStyle
    private var bounce: Bool
    private var wrap: Bool
    private var hasControl: Bool
    private var pageControl: UIPageControl? = nil
    private var controlAlignment: Alignment
    private var currentTintColor: UIColor
    private var tintColor: UIColor

    // 新增回调
    private var onPageChangeSuccess: ((Int, Bool) -> Void)?
    private var onPageChangeCancel: ((Int) -> Void)?
    private var onLastPageReached: ((Int) -> Void)?
    /**
    Creates the paging view that generates pages dynamically based on some user-defined data.

    `ModelPages` can be used as follows:
       ```
           struct Car: {
               var model: String
           }

           struct CarsView: View {

               @State var index: Int = 0
               let cars = [Car(model: "Ford"), Car(model: "Ferrari")

               var body: some View {
                   ModelPages(self.cars, currentPage: $index) { i, car in
                       Text("Car is \(car.model)!")
                   }
               }
           }
       ```

       - Parameters:
         -items：将驱动页面创建的数据集合。
         -currentPage：一个绑定，使用户可以控制当前页面索引。
         -navigationOrientation：是水平还是垂直分页。
         -transitionStyle：是否在翻页时执行页面卷曲或滚动效果。
         -bounce：当用户试图滚动浏览所有页面时是否反弹。
         -wrap：一个标志，指示当用户滚动到开头或结尾时，是否循环包裹页面。
         -hasControl：是否显示页面控件。
         -控件：用户定义的页面控件。
         -control对齐：放置页面控件的位置。
         -template：一个函数，指定给定页面的位置和与页面相关的项目时页面的外观。
    */
    public init(
        _ items: Data,
        currentPage: Binding<Int>,
        navigationOrientation: UIPageViewController.NavigationOrientation = .horizontal,
        transitionStyle: UIPageViewController.TransitionStyle = .scroll,
        bounce: Bool = true,
        wrap: Bool = false,
        hasControl: Bool = true,
        control: UIPageControl? = nil,
        controlAlignment: Alignment = .bottom,
        currentTintColor: UIColor = .white,
        tintColor: UIColor = .gray,
        template: @escaping (Int, Data.Element) -> Content,
        onPageChangeSuccess: ((Int) -> Void)? = nil,
        onPageChangeCancel: ((Int) -> Void)? = nil,
        onLastPageReached: ((Int) -> Void)? = nil
        
    ) {
        self._currentPage = currentPage
        self.navigationOrientation = navigationOrientation
        self.transitionStyle = transitionStyle
        self.bounce = bounce
        self.wrap = wrap
        self.hasControl = hasControl
        self.pageControl = control
        self.controlAlignment = controlAlignment
        self.items = items.map { $0 }
        self.template = template
        self.currentTintColor = currentTintColor
        self.tintColor = tintColor
        self.onPageChangeSuccess = onPageChangeSuccess
        self.onPageChangeCancel = onPageChangeCancel
        self.onLastPageReached = onLastPageReached
    }

    public var body: some View {
        ZStack(alignment: self.controlAlignment) {
            PageViewController(
                currentPage: $currentPage,
                navigationOrientation: navigationOrientation,
                transitionStyle: transitionStyle,
                bounce: bounce,
                wrap: wrap,
                controllers: (0..<items.count).map { i in
                    let h = UIHostingController(rootView: template(i, items[i]))
                    h.view.backgroundColor = .clear
                    return h
                },
                onPageChangeSuccess: onPageChangeSuccess,
                onPageChangeCancel: onPageChangeCancel,
                onLastPageReached: onLastPageReached
            )
            if self.hasControl {
                PageControl(
                    numberOfPages: items.count,
                    pageControl: pageControl,
                    currentPageIndicatorTintColor: currentTintColor,
                    pageIndicatorTintColor: tintColor,
                    currentPage: $currentPage
                ).padding()
            }
        }
    }

}
