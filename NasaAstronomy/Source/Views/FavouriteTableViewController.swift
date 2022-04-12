//
//  FavouriteTableViewController.swift
//  NasaAstronomy
//
//  Created by Sugeet Goyal on 13/04/22.
//

import UIKit

protocol FavouriteTableViewControllerDelegate: class {
    func didSelectItem(for date: String)
}

class FavouriteTableViewController: UITableViewController {
    weak var delegate: FavouriteTableViewControllerDelegate?
    weak var favouriteListModel: FavouriteListModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Favourites"
        
        let deleteAllBarButton = UIBarButtonItem(title: "Clear All", style: UIBarButtonItem.Style.done, target: self, action: #selector(clearAll))
        self.navigationItem.rightBarButtonItem = deleteAllBarButton
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favouriteListModel?.favouriteList.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = favouriteListModel?.favouriteList[indexPath.row].title
        
        return cell ?? UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectItem(for: favouriteListModel?.favouriteList[indexPath.row].date ?? "")
        self.navigationController?.popViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            tableView.beginUpdates()
            favouriteListModel?.favouriteList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
    }

    @objc func clearAll() {
        favouriteListModel?.favouriteList.removeAll()
        tableView.reloadData()
    }
}
