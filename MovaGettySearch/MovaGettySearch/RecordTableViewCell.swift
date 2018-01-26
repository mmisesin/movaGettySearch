//
//  RecordTableViewCell.swift
//  MovaGettySearch
//
//  Created by Artem Misesin on 1/25/18.
//  Copyright © 2018 misesin. All rights reserved.
//

import UIKit

class RecordTableViewCell: UITableViewCell {

    var record: GettySearchRecord? {
        didSet {
            if let newRecord = record {
                if let newImageData = newRecord.imageData {
                    self.recordImageView.image = UIImage(data: newImageData)
                }
                self.searchWordLabel.text = newRecord.searchPhrase
            }
        }
    }
    
    private let recordImageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFill
        image.layer.cornerRadius = 8
        image.clipsToBounds = true
        return image
    }()
    
    private let imageSpinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    private let searchWordLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.baselineAdjustment = .alignBaselines
        label.numberOfLines = 0
        return label
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    private func setupViews() {
        addSubview(recordImageView)
        recordImageView.addSubview(imageSpinner)
        addSubview(searchWordLabel)
        
        self.recordImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        self.recordImageView.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        self.recordImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8).isActive = true
        self.recordImageView.widthAnchor.constraint(equalTo: self.recordImageView.heightAnchor, multiplier: 16/12).isActive = true
        
        self.imageSpinner.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        self.imageSpinner.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        self.searchWordLabel.leadingAnchor.constraint(equalTo: self.recordImageView.trailingAnchor, constant: 20).isActive = true
        self.searchWordLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        self.searchWordLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        self.searchWordLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8).isActive = true
    }

}
