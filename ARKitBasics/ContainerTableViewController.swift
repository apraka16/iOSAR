//
//  ContainerTableViewController.swift
//  ARKitBasics
//
//  Created by Abhinav Prakash on 10/11/17.
//  Copyright © 2017 Apple. All rights reserved.


import UIKit
import SceneKit

protocol VCFinalDelegate {
    func passVirtualObject() -> [(name: String, scn: String, count: Int)]
}

class ContainerTableViewController: UITableViewController {
    
    var delegate: VCFinalDelegate?
    
//    private let virtualObjects = VirtualObjects()
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        presentingViewController?.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let size = tableView.minimumSize(forSection: 0)
        preferredContentSize = size
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let data = delegate?.passVirtualObject()
//        return virtualObjects.virtualObjectCountArray.count
        return data?.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = delegate?.passVirtualObject()
        let dequeued = tableView.dequeueReusableCell(withIdentifier: "Virtual Object Count", for: indexPath)
        if data != nil {
            dequeued.textLabel?.text = data![indexPath.row].name
            dequeued.detailTextLabel?.text = String(data![indexPath.row].count)
            dequeued.imageView?.image = UIImage(named: data![indexPath.row].name.lowercased() + "-red")
        }
        return dequeued
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
}

extension UITableView {
    func minimumSize(forSection section: Int) -> CGSize {
        var width: CGFloat = 0
        var height: CGFloat = 0
        for row in 0..<numberOfRows(inSection: section) {
            let indexPath = IndexPath(item: row, section: section)
            if let cell = cellForRow(at: indexPath) ?? dataSource?.tableView(self, cellForRowAt: indexPath) {
//                print(cell.contentView.frame.height)
//                let cellSize = cell.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
//                width = max(width, cellSize.width)
                width = cell.contentView.frame.width
                height += cell.contentView.frame.height
                // height += heightForRow(at: indexPath)
//                height += cellSize.height
//                print(height, width)
            }
        }
        return CGSize(width: width, height: height)
    }
    
    func heightForRow(at indexPath: IndexPath? = nil) -> CGFloat {
        if indexPath != nil, let height = delegate?.tableView?(self, heightForRowAt: indexPath!) {
            return height
        } else {
            return rowHeight
        }
    }
}


