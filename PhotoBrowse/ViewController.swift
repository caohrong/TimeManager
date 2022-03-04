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

        modalPresentationStyle = .fullScreen
        let tabbar = UITabBarController()

        let mainPage = UINavigationController(rootViewController: AssetGridViewController())
        mainPage.tabBarItem = UITabBarItem(title: "图片", image: UIImage(systemName: "photo.tv"), tag: 0)

        let toolsPage = UINavigationController(rootViewController: ToolsController())
        toolsPage.tabBarItem = UITabBarItem(title: "工具", image: UIImage(systemName: "tv.inset.filled"), tag: 1)

        tabbar.setViewControllers([mainPage, toolsPage], animated: false)
        tabbar.modalPresentationStyle = .fullScreen
        present(tabbar, animated: true, completion: nil)
    }
}
