//
//  ViewController.swift
//  SwiftLoadingHUD
//
//  Created by 周际航 on 2017/3/30.
//  Copyright © 2017年 com.maramara. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController {

    fileprivate lazy var tableView: UITableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
}

// MARK: - 扩展 UI
private extension ViewController {
    func setup() {
        self.setupView()
        self.setupConstraints()
    }
    
    func setupView() {
        self.view.addSubview(self.tableView)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.backgroundColor = UIColor.clear
    }
    
    func setupConstraints() {
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
    }
}

// MARK: - 扩展 UITableViewDelegate
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellID = "cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) ?? UITableViewCell(style: .default, reuseIdentifier: cellID)
        cell.selectionStyle = .none
        
        var title = "\(indexPath.section) - \(indexPath.row)"
        
        if indexPath.row == 0 {
            title = "测试 - vc 弹窗显示消失"
        } else if indexPath.row == 1 {
            title = "测试 - vc 弹窗自动计数器"
        } else if indexPath.row == 2 {
            title = "测试 - vc 弹窗，win 弹窗互斥效果"
        }
        
        cell.textLabel?.text = title
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            self.test0()
        } else if indexPath.row == 1 {
            self.test1()
        } else if indexPath.row == 2 {
            self.test2()
        }
    }
}

// MARK: - 扩展 点击事件
private extension ViewController {
    // 测试 vc 弹窗的显示
    func test0() {
        self.ldt_loadingCountAdd()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) { [weak self] in
            self?.ldt_loadingCountReduce()
        }
    }
    
    // 测试 vc 弹窗的计数器效果
    func test1() {
        self.ldt_loadingCountAdd()
        self.ldt_loadingCountAdd()
        self.ldt_loadingCountAdd()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) { [weak self] in
            self?.ldt_loadingCountReduce()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) { [weak self] in
                self?.ldt_loadingCountReduce()
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) { [weak self] in
                    self?.ldt_loadingCountReduce()
                }
            }
        }
    }
    
    // 测试 vc 弹窗 和 win 弹窗的互斥效果
    func test2() {
        // vc弹窗显示
        self.ldt_loadingCountAdd()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
            // win级别弹窗，会让vc级别弹窗暂时隐藏
            LoadingTool.show()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
                // win级别弹窗消失时，通知vc弹窗显示（假如有的话）
                LoadingTool.dismiss()
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) { [weak self] in
                    // vc 弹窗消失
                    self?.ldt_loadingCountReduce()
                }
            }
        }
    }
    
}

