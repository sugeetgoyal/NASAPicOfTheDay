//
//  HomeViewController.swift
//  NasaAstronomy
//
//  Created by Sugeet Goyal on 10/04/22.
//

import UIKit

class HomeViewController: BaseViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nasaImageView: UIImageView!
    @IBOutlet weak var datePickerTextField: UITextField!
    @IBOutlet weak var descriptionLabel: UITextView!
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    var homeViewModel = HomeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addDatePicker()
        updateModel(date: Date())
    }
    
    override func didSelectDefaultAlertButton(with title: String?, and data: Any = []) {
        updateModel(date: Date())
    }
    
    private func updateModel(date: Date) {
        activityIndicator.startAnimating()
        
        homeViewModel.getPictureOfTheDay(date) { [weak self] (success, errorMessage) in
            if success {
                self?.updateView()
            } else {
                self?.showAlert(error: errorMessage)
            }
        }
    }
    
    private func addDatePicker() {
        datePickerTextField.rightViewMode = UITextField.ViewMode.always
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        let image = UIImage(named: "calender")
        imageView.image = image
        datePickerTextField.rightView = imageView
        self.datePickerTextField.datePicker(target: self,
                                            done: #selector(handleDonePicker),
                                            cancel: #selector(handleCancelPicker),
                                            datePickerMode: .date)
        activityIndicator.color = UIColor.gray
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        activityIndicator.center = self.view.center
    }
    
    private func clearView() {
        self.titleLabel.text = ""
        self.descriptionLabel.text = ""
        self.datePickerTextField.text = ""
        self.nasaImageView.image = UIImage()
    }
    
    private func updateView() {
        DispatchQueue.main.async { [self] in
            self.titleLabel.text = homeViewModel.title
            self.descriptionLabel.text = homeViewModel.description
            datePickerTextField.text = homeViewModel.date
            
            if homeViewModel.media_type == .image {
                self.nasaImageView.loadImage(withUrl: homeViewModel.imageUrl ?? "")
            } else {
                self.nasaImageView.image = UIImage(named: "default_image")
                //We can write code to load video here or other media. As of now we are only receiving images from the API.
            }
            
            self.activityIndicator.stopAnimating()
        }
    }
    
    private func showAlert(error: String) {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.displayAlertViewController(title: "Error!", message: error, defaultTitle: "Retry", canceltTitle: "Cancel")
        }
    }
    
    @objc func handleDonePicker() {
        if let datePickerView = self.datePickerTextField.inputView as? UIDatePicker {
            
            DispatchQueue.main.async { [self] in
                self.datePickerTextField.resignFirstResponder()
                self.activityIndicator.startAnimating()
                clearView()
            }
            
            updateModel(date: datePickerView.date)
        }
    }
    
    @objc func handleCancelPicker() {
        self.datePickerTextField.resignFirstResponder()
    }
}
