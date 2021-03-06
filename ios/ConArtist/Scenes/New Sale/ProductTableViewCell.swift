//
//  ProductTableViewCell.swift
//  ConArtist
//
//  Created by Cameron Eldridge on 2018-02-03.
//  Copyright © 2018 Cameron Eldridge. All rights reserved.
//

import UIKit

class ProductTableViewCell: ConArtistTableViewCell {
    static let ID = "ProductCell"
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var countView: UIView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var inventoryLabel: UILabel!

    func setup(with product: Product, records: [Record], count: Int) {
        nameLabel.text = product.name
        countLabel.text = "\(count)"
        countView.isHidden = count == 0
        inventoryLabel.text = "\(max(0, product.remainingQuantity(havingSold: records) - count))"
    }
}
