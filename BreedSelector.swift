//
//  BreedSelector.swift
//  LocationSelector
//
//  Created by 刘月 on 7/4/17.
//  Copyright © 2017 Tianmaying. All rights reserved.
//

import UIKit
var multipleChoice: Bool?

enum BreedType {
    case specie
    case breed
}


protocol BreedSelectorDelegate {
    func breedSelected(_ breeds: [String])
}

class BreedSelector: UITableViewController {

    var delegate: BreedSelectorDelegate?

    var breedType = BreedType.specie
    var breedPath = ""
    var breeds: NSArray!
    var multipleChoice: Bool!
  
    //slove the checkmark issue
    var selectedCells = [NSIndexPath]()

    
    init(_ multipleChoice: Bool){
        self.multipleChoice = multipleChoice
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if breedType == .specie {
            if let path = Bundle.main.path(forResource: "breed", ofType: "plist") {
                breeds = NSArray(contentsOfFile: path)
            }
        }
        
        self.tableView.tableFooterView = UIView()
        self.navigationItem.title = "选择品种"
        
        //new back button
        let backBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = backBtn
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return breeds.count
    }
    
    func back(){
        _ = self.navigationController?.popViewController(animated: true)
        
    }
    
    //cell config
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "breedCell")

        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "breedCell")
        }

        switch breedType {
      
            case .specie:
                cell.textLabel?.text = (self.breeds[indexPath.row] as! NSDictionary)["specie"] as? String

            case .breed:
                    
                cell.textLabel?.text = self.breeds[indexPath.row] as? String
                cell.selectionStyle = .none


                if multipleChoice == true {
                    //breed 可以多选
                    self.tableView!.allowsMultipleSelection = true
                
                    //save button
                    let saveBtn = UIBarButtonItem(title: "保存", style: .plain, target: self, action:#selector(save))
                    self.navigationItem.rightBarButtonItem = saveBtn
                    
                    cell.accessoryType = selectedCells.contains(indexPath as NSIndexPath) ? .checkmark : .none
                    
                }
            

        }
        
        return cell
    }
    
  
    
    func save(){
        var selectedBreeds = [String]()

        //存储选中单元格的内容
        if let selectedItems = tableView.indexPathsForSelectedRows {
            for indexPath in selectedItems {
                
                
                let currentBreed = breeds[indexPath.row]
                selectedBreeds.append("\(breedPath) \(currentBreed)")
            }
        }

        self.delegate?.breedSelected(selectedBreeds)
    
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let nextBreedSelector = BreedSelector(multipleChoice)
        nextBreedSelector.delegate = self.delegate
        let currentBreed = tableView.cellForRow(at: indexPath)?.textLabel?.text
        nextBreedSelector.breedPath = "\(breedPath) \(currentBreed!)"
        
        switch breedType {
        
            case .specie:
                nextBreedSelector.breeds = (self.breeds[indexPath.row] as! NSDictionary)["breed"] as! NSArray
                nextBreedSelector.breedType = .breed

            default:
                nextBreedSelector.breeds = []
                let cell = self.tableView?.cellForRow(at: indexPath)
                
                if multipleChoice == true {
                    self.tableView?.cellForRow(at: indexPath)?.accessoryType = .checkmark
                    selectedCells.append(indexPath as NSIndexPath)

                } else if multipleChoice == false {
                    
                    var selectedBreeds = [String]()
                    
                    //存储选中单元格的内容
                    let currentBreed = cell!.textLabel?.text
                    selectedBreeds.append("\(breedPath) \(currentBreed!)")
                    
                    self.delegate?.breedSelected(selectedBreeds)
                }
                break
        }
        
        if (nextBreedSelector.breeds.count > 0) {
            navigationController?.pushViewController(nextBreedSelector, animated: true)
        }
    }
    
    
    //消选选中时, 去掉cell尾部对勾
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {

        self.tableView?.cellForRow(at: indexPath)?.accessoryType = .none
        selectedCells = selectedCells.filter {$0 as IndexPath != indexPath}
        
    }
    
    
}
