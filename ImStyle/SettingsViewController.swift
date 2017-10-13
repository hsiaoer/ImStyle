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
        
        self.styleModelPicker.delegate = modelPicker
        self.styleModelPicker.dataSource = modelPicker
        self.updateImage()
        modelPicker.setSettingsView(sv: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.styleModelPicker.selectRow(modelPicker.currentStyle, inComponent: 0, animated: true)
        self.updateImage()
    }
    
    func updateImage() {
        self.styleModelImagePreview.image = UIImage(named: modelList[modelPicker.currentStyle] + "-source-image")
    }
    
}

class ModelPickerController: UIPickerView, UIPickerViewDataSource, UIPickerViewDelegate {
    var currentStyle = 0
    var settingsView: SettingsViewController?
    
    func setSettingsView(sv: SettingsViewController) {
        self.settingsView = sv
    }
    
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
        self.currentStyle = row
        if (self.settingsView != nil) {
            self.settingsView!.updateImage()
        }
    }
}

let modelPicker = ModelPickerController()
