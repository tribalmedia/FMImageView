//
//  TableViewController.swift
//  Example
//
//  Created by Trần Quang Minh on 7/5/18.
//  Copyright © 2018 Hoang Trong Anh. All rights reserved.
//

import UIKit
import FMImageView

class TableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 200
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 5
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! ImageCell
        
        cell.presentFMImageView = { [unowned self] (_ index: Int, _ imageView: UIImageView, _ photoURLs: [URL]) -> Void in
            
            let fmImageVC = self.setupPresenter(fromImage: imageView, initIndex: index, photoURLs: photoURLs)
            
            // update new destination frame when swipe page
            fmImageVC.didMoveToViewControllerHandler = { index in
                let imageViewAtIndex = cell.photoGrid.getImageView(index: index)
                fmImageVC.setNewDestinatonFrame(imageView: imageViewAtIndex)
            }
            
            self.present(fmImageVC, animated: true, completion: nil)
        }
        cell.updateCell()
        
        return cell
    }
    
    // set up presenter
    private func setupPresenter(fromImage: UIImageView, initIndex: Int, photoURLs: [URL]) -> FMImageSlideViewController {
        var config = Config(initImageView: fromImage, initIndex: initIndex)
        config.bottomView = HorizontalStackView(view: FMImageViewBottomView())
        
        let vc = FMImageSlideViewController(datasource: FMImageDataSource(imageURLs: photoURLs), config: config)
        
        vc.view.frame = self.view.frame
        
        return vc
    }
    
}
