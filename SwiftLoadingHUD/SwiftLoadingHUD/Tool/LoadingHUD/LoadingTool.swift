//
//  LoadingTool.swift
//  Mara
//
//  Created by 周际航 on 2016/12/29.
//  Copyright © 2016年 com.maramara. All rights reserved.
//

import Foundation
import UIKit

class LoadingTool {
    
    static let tool = LoadingTool()
    var loadingView: LoadingView?                   // window上的弹窗
    var loadingVCArray: [UIViewController] = []   // 记录正在显示loading视图的 vc
    
    
}
// window 级别的弹窗
extension LoadingTool {
    static func show() {
        guard self.tool.loadingView == nil else {return}
        guard let window = UIApplication.shared.delegate?.window else {return}
        guard let win = window else {return}
        
        if let currentVC = win.ext_currentViewController() {
            currentVC.ldt_hideLoading(true)
        }
        self.tool.loadingView = LoadingView.addTo(win)
    }
    
    static func dismiss() {
        guard self.tool.loadingView != nil else {return}
        guard let window = UIApplication.shared.delegate?.window else {return}
        guard let win = window else {return}
        
        if let currentVC = win.ext_currentViewController() {
            currentVC.ldt_hideLoading(false)
        }
        self.tool.loadingView?.removeFromSuperview()
        self.tool.loadingView = nil
        
    }
}

// MARK: - 扩展 BaseViewController loading弹窗扩展
private var kLoadingViewKey: Void?
private var kLoadingCountKey: Void?
private var kIsHideLoadingKey: Void?
extension UIViewController {
    // 修改loading计数
    func ldt_loadingCountAdd() {
        let count = self.ldt_loadingCount.intValue + 1
        self.ldt_loadingCount = NSNumber(integerLiteral: count)
        self.ldt_showLoading()
        "\(self) add loadingCount \(count)".ext_debugPrint()
    }
    func ldt_loadingCountReduce() {
        let count = self.ldt_loadingCount.intValue > 0 ? self.ldt_loadingCount.intValue-1 : 0
        self.ldt_loadingCount = NSNumber(integerLiteral: count)
        count > 0 ? self.ldt_showLoading() : self.ldt_dismissLoading()
        "\(self) reduce loadingCount \(count)".ext_debugPrint()
    }
    
    // loading视图
    private var ldt_loadingView: LoadingView? {
        get {return objc_getAssociatedObject(self, &kLoadingViewKey) as? LoadingView}
        set {objc_setAssociatedObject(self, &kLoadingViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)}
    }
    // loading计数器
    private var ldt_loadingCount: NSNumber {
        get {return (objc_getAssociatedObject(self, &kLoadingCountKey) as? NSNumber) ?? 0}
        set {objc_setAssociatedObject(self, &kLoadingCountKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)}
    }
    // 隐藏vc的loading
    private var ldt_isHideLoading: NSNumber {
        get {return (objc_getAssociatedObject(self, &kIsHideLoadingKey) as? NSNumber) ?? 0}
        set {objc_setAssociatedObject(self, &kIsHideLoadingKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)}
    }
    
    private func ldt_showLoading() {
        guard self.ldt_loadingView == nil else {return}
        let loadingView = LoadingView.addTo(self.view)
        self.ldt_loadingView = loadingView
        
        let isHide = self.ldt_isHideLoading==0 ? false : true
        loadingView.isHidden = isHide
    }
    private func ldt_dismissLoading() {
        guard let loadingView = self.ldt_loadingView else {return}
        loadingView.removeFromSuperview()
        self.ldt_loadingView = nil
    }
    fileprivate func ldt_hideLoading(_ hide: Bool) {
        guard let loadingView = self.ldt_loadingView else {return}
        guard self.ldt_loadingCount.intValue > 0 else {return}
        
        loadingView.isHidden = hide
        self.ldt_isHideLoading = NSNumber(booleanLiteral: hide)
    }
}

// MARK: - 扩展 页面层级扩展
private extension UIWindow {
    // 找到 window 下显示在最上层的 vc
    func ext_currentViewController() -> UIViewController? {
        return self.rootViewController?.ext_topShowViewController()
    }
}

private extension UIViewController {
    // 该 vc 下，最后一个 presented 的vc
    func ext_lastPresentedViewController() -> UIViewController? {
        guard var vc = self.presentedViewController else {return nil}
        while vc.presentedViewController != nil {
            vc = vc.presentedViewController!
        }
        return vc
    }
    // 该 vc 下，显示在最上层的 vc
    func ext_topShowViewController() -> UIViewController {
        if let topPresentVC = self.ext_lastPresentedViewController() {
            return topPresentVC.ext_topShowViewController()
        }
        if let tabBarVC = self as? UITabBarController {
            guard let selectedVC = tabBarVC.selectedViewController else {return self}
            return selectedVC.ext_topShowViewController()
        }
        if let navVC = self as? UINavigationController {
            guard let topVC = navVC.topViewController else {return self}
            return topVC.ext_topShowViewController()
        }
        return self
    }
}
