//
//  ViewController.swift
//  MovaGettySearch
//
//  Created by Artem Misesin on 1/25/18.
//  Copyright © 2018 misesin. All rights reserved.
//

import UIKit
import RealmSwift

class GettySearchViewController: UIViewController {
    
    fileprivate let cellId = "cellId"
    
    fileprivate let realmManager = RealmManager()
    fileprivate var sessionRecords: Results<GettySearchRecord>?
    
    private let searchBar: UISearchBar = {
        let search = UISearchBar()
        search.translatesAutoresizingMaskIntoConstraints = false
        search.autocorrectionType = .no
        search.searchBarStyle = UISearchBarStyle.minimal
        search.placeholder = "Start searching now ..."
        return search
    }()
    
    private let resultsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "History"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        return label
    }()
    
    private let noResultsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Nothing found"
        label.textColor = UIColor(red: 244/255, green: 71/255, blue: 71/255, alpha: 1)
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.alpha = 0
        return label
    }()
    
    private let searchSpinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    private let resultsTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No records yet"
        label.textColor = .gray
        label.textAlignment = .center
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateData()
        self.setupTableView()
        self.setupViews()
        self.setupSearchBar()
    }
    
    private func setupViews() {
        self.view.backgroundColor = .white
        var guide = self.view.layoutMarginsGuide
        
        self.view.addSubview(self.searchBar)
        self.view.addSubview(self.resultsLabel)
        self.view.addSubview(self.noResultsLabel)
        self.view.addSubview(self.searchSpinner)
        self.view.addSubview(self.resultsTableView)
        
        // MARK: Autolayout
        
        self.resultsLabel.sizeToFit()
        self.resultsLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
        self.noResultsLabel.sizeToFit()
        self.noResultsLabel.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -20).isActive = true
        self.noResultsLabel.centerYAnchor.constraint(equalTo: self.resultsLabel.centerYAnchor).isActive = true
        
        self.searchSpinner.leadingAnchor.constraint(equalTo: self.resultsLabel.trailingAnchor, constant: 10).isActive = true
        self.searchSpinner.centerYAnchor.constraint(equalTo: self.resultsLabel.centerYAnchor).isActive = true
        
        if #available(iOS 11, *) {
            guide = view.safeAreaLayoutGuide
        }
        
        self.searchBar.topAnchor.constraint(equalTo: guide.topAnchor, constant: 8).isActive = true
        self.searchBar.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
        self.searchBar.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
        
        self.resultsLabel.topAnchor.constraint(equalTo: self.searchBar.bottomAnchor, constant: 10).isActive = true
        
        self.resultsTableView.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
        self.resultsTableView.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
        self.resultsTableView.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
        self.resultsTableView.topAnchor.constraint(equalTo: self.resultsLabel.bottomAnchor, constant: 16).isActive = true
        
    }
    
    private func setupTableView() {
        self.resultsTableView.delegate = self
        self.resultsTableView.dataSource = self
        resultsTableView.register(RecordTableViewCell.self, forCellReuseIdentifier: cellId)
        self.emptyLabel.frame = self.resultsTableView.frame
        if self.sessionRecords == nil {
            self.resultsTableView.backgroundView = self.emptyLabel
        } else if self.sessionRecords!.isEmpty {
            self.resultsTableView.backgroundView = self.emptyLabel
        } else {
            self.resultsTableView.backgroundView = nil
        }
    }
    
    private func setupSearchBar() {
        self.searchBar.delegate = self
    }
    
    private func updateData() {
        if let records = self.realmManager.getRecords() {
            self.sessionRecords = records
        } else {
            self.showAlert(with: "There was a problem with accessing Realm")
        }
    }
    
    private func saveSearch(record: GettySearchRecord) {
        DispatchQueue.main.async {
            self.realmManager.addRecord(record, completion: { (result) in
                switch result{
                case .failure(let error):
                    self.showAlert(with: error.localizedDescription)
                case .success:
                    self.updateData()
                    self.resultsTableView.insertRows(at: [IndexPath(item: 0, section: 0)], with: .top)
                }
            })
        }
    }
    
    private func showNoResultsLabel() {
        UIView.animate(withDuration: 0.3, animations: {
            self.noResultsLabel.alpha = 1
        }) { (_) in
            UIView.animate(withDuration: 0.3, delay: 0.5, options: .curveLinear, animations: {
                self.noResultsLabel.alpha = 0
            }, completion: nil)
        }
    }
    
    private func showAlert(with message: String) {
        let alertController = UIAlertController(title: message, message: "", preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}

extension GettySearchViewController: UISearchBarDelegate {
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let newSearchWord = searchBar.text {
            let request = RequestType.search(sortMethod: "best", searchWord: newSearchWord)
            self.searchSpinner.startAnimating()
            RequestManager.sendRequest(of: request) { (result) in
                self.searchSpinner.stopAnimating()
                switch result {
                case .success(let result):
                    guard result.result_count > 0 else {
                        self.showNoResultsLabel()
                        return
                    }
                    self.resultsTableView.backgroundView = nil
                    
                    let searchRecord = GettySearchRecord()
                    searchRecord.searchPhrase = newSearchWord
                    let imageURI = result.images[0].display_sizes[0].uri
                    guard let uri = URL(string: imageURI) else {
                        self.showAlert(with: "Invalid URL")
                        return
                    }
                    RequestManager.getDataFromUrl(url: uri) { data, response, error in
                        guard let data = data, error == nil else { return }
                        searchRecord.imageData = data
                        self.saveSearch(record: searchRecord)
                    }
                case .failure(let error):
                    self.showAlert(with: error.localizedDescription)
                }
            }
        }
        searchBar.resignFirstResponder()
    }
    
}

extension GettySearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard self.sessionRecords != nil else {
            return 0
        }
        return self.sessionRecords!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! RecordTableViewCell
        guard self.sessionRecords != nil else {
            return cell
        }
        let records = self.sessionRecords!
        cell.record = records[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.realmManager.deleteRecord(self.sessionRecords![indexPath.row]) { (result) in
                switch result{
                case .failure(let error):
                    self.showAlert(with: error.localizedDescription)
                case .success:
                    self.updateData()
                    self.resultsTableView.deleteRows(at: [indexPath], with: .left)
                }
            }
        }
        if self.sessionRecords!.isEmpty {
            self.resultsTableView.backgroundView = self.emptyLabel
        }
    }
    
}
