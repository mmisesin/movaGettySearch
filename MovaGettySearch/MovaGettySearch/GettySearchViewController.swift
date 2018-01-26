//
//  ViewController.swift
//  MovaGettySearch
//
//  Created by Artem Misesin on 1/25/18.
//  Copyright © 2018 misesin. All rights reserved.
//

import UIKit

class GettySearchViewController: UIViewController {

    let cellId = "cellId"
    
    let realmManager = RealmManager()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableView()
        self.setupViews()
        self.setupSearchBar()
    }

    private func setupViews() {
        self.view.backgroundColor = .white
        var guide = self.view.layoutMarginsGuide
        
        self.view.addSubview(self.searchBar)
        self.view.addSubview(self.resultsLabel)
        self.view.addSubview(self.searchSpinner)
        self.view.addSubview(self.resultsTableView)
        
        // MARK: Autolayout
        
        self.resultsLabel.sizeToFit()
        self.resultsLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
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
        
        if realmManager.getRecords().isEmpty {
            let emptyStateLabel = UILabel(frame: resultsTableView.frame)
            emptyStateLabel.text = "No records yet"
            emptyStateLabel.textColor = .gray
            emptyStateLabel.textAlignment = .center
            resultsTableView.backgroundView = emptyStateLabel
        } else {
            resultsTableView.backgroundView = nil
        }
    }
    
    private func setupSearchBar() {
        self.searchBar.delegate = self
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
                    self.resultsTableView.backgroundView = nil
                    let searchRecord = GettySearchRecord()
                    searchRecord.id = self.realmManager.getRecords().count
                    searchRecord.searchPhrase = newSearchWord
                    let imageURI = result.images[0].display_sizes[0].uri
                    guard let uri = URL(string: imageURI) else {
                        print("Invalid URL")
                        return
                    }
                    searchRecord.downloadData(url: uri)
                    self.realmManager.addRecord(searchRecord, completion: { (result) in
                        switch result{
                        case .failure(let error):
                            print(error.localizedDescription)
                        case .success:
                            self.resultsTableView.insertRows(at: [IndexPath(item: 0, section: 0)], with: .top)
                        }
                    })
                case .failure(let error):
                    print(error.localizedDescription)
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
        return realmManager.getRecords().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! RecordTableViewCell
        let records = realmManager.getRecords()
        cell.record = records[records.count - indexPath.row - 1]
        return cell
    }
    
}
