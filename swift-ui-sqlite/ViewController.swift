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
    
    let newsViewModel: NewsViewModel = NewsViewModel()
    
    fileprivate var subscription: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        view.backgroundColor = .red
        todoViewModel.fetch()
        
        print("showing in ui")
        
        todoViewModel.$todos.receive(on: RunLoop.main).sink { (todos) in
            print(todos)
            print("showed")
        }.store(in: &subscription)
        
        
    }

}
