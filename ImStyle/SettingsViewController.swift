//
//  SettingsViewController.swift
//  ImStyle
//
//  Created by Jake Carlson on 10/6/17.
//  Copyright © 2017 ImageStyle. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var styleLabel: UILabel!
    @IBOutlet weak var styleModelPicker: UIPickerView!
    @IBOutlet weak var styleModelImagePreview: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.styleModelPicker.delegate = self
        self.styleModelPicker.dataSource = self
        self.styleModelImagePreview.image = UIImage(named: modelList[0] + "-source-image")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}

extension SettingsViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return modelNames.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return modelNames[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        setModel(targetModel: modelList[row])
        self.styleModelImagePreview.image = UIImage(named: modelList[row] + "-source-image")
    }
}
