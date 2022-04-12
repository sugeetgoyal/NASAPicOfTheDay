//
//  HomeViewController.swift
//  NasaAstronomy
//
//  Created by Sugeet Goyal on 10/04/22.
//

import UIKit
import YouTubePlayer

class HomeViewController: BaseViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nasaImageView: UIImageView!
    @IBOutlet weak var datePickerTextField: UITextField!
    @IBOutlet weak var descriptionLabel: UITextView!
    @IBOutlet weak var mediaView: YouTubePlayerView!
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    var homeViewModel = HomeViewModel()
    var favouriteListModel = FavouriteListModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.addDatePicker()
        updateModel(date: Date())
    }
    
    override func didSelectDefaultAlertButton(with title: String?, and data: Any = []) {
        updateModel(date: Date())
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    @IBAction func handleFavouriteButton(_ sender: Any) {
        if let aVC = UIStoryboard(name: "Main", bundle:nil).instantiateViewController(withIdentifier: "FavouriteTableViewController") as? FavouriteTableViewController {
            aVC.favouriteListModel = favouriteListModel
            aVC.delegate = self
            self.navigationController?.pushViewController(aVC, animated: true)
        }
    }
    
    @IBAction func handleAddToFavourite(_ sender: Any) {
        if homeViewModel.hasError == true {
            displayAlertViewController(title: "Can not Add to favourite!", message: "Because of incorrecr data, it cannot add to your favourite list", defaultTitle: nil, canceltTitle: "OK")
        } else if favouriteListModel.favouriteList.filter({ (model) in
            model.date == homeViewModel.date
        }).count == 0 {
            let homeModel = HomeViewModel()
            homeModel.title = homeViewModel.title
            homeModel.mediaURL = homeViewModel.mediaURL
            homeModel.media_type = homeViewModel.media_type
            homeModel.date = homeViewModel.date
            homeModel.description = homeViewModel.description

            favouriteListModel.favouriteList.append(homeModel)
            displayAlertViewController(title: "Added to Favourite", message: "This is added to your favourite list", defaultTitle: nil, canceltTitle: "OK")
        } else {
            displayAlertViewController(title: "Already Added!", message: "This is already added to your favourite list", defaultTitle: nil, canceltTitle: "OK")
        }
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
                self.mediaView.isHidden = true
                self.nasaImageView.isHidden = false
                self.nasaImageView.loadImage(withUrl: homeViewModel.mediaURL ?? "")
            } else if homeViewModel.media_type == .video {
                self.mediaView.isHidden = false
                self.nasaImageView.isHidden = true
                if let url = URL(string: homeViewModel.mediaURL ?? "") {
                    self.mediaView.loadVideoURL(url)
                }
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

extension HomeViewController: FavouriteTableViewControllerDelegate {
    func didSelectItem(for date: String) {
        updateModel(date: date.toDate())
    }
}
