//
//  ViewController.swift
//  PhotoBrowse
//
//  Created by Huanrong on 10/22/21.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        self.present(MainController(), animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.modalPresentationStyle = .fullScreen
        let tabbar = UITabBarController()
        
        let mainPage = UINavigationController(rootViewController: AssetGridViewController())
        mainPage.tabBarItem = UITabBarItem(title: "图片", image: nil, tag: 0)
        
        let toolsPage = UINavigationController(rootViewController: ToolsController())
        toolsPage.tabBarItem = UITabBarItem(title: "工具", image: nil, tag: 1)
        
        tabbar.setViewControllers([mainPage, toolsPage], animated: false)
        tabbar.modalPresentationStyle = .fullScreen
        self.present(tabbar, animated: true, completion: nil)
    }
}
