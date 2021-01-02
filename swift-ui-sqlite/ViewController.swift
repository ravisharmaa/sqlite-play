//
//  ViewController.swift
//  swift-ui-sqlite
//
//  Created by Ravi Bastola on 12/31/20.
//

import UIKit
import Combine

class ViewController: UIViewController {
    
    let todoViewModel: TodoViewModel = TodoViewModel()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        view.backgroundColor = .red
        
        todoViewModel.fetch()

        todoViewModel.$todos.sink { (toDo) in
            print(toDo)
        }.store(in: &todoViewModel.subscription)
    }

}
