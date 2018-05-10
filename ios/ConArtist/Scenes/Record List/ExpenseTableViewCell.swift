//
//  ExpenseTableViewCell.swift
//  ConArtist
//
//  Created by Cameron Eldridge on 2018-03-08.
//  Copyright © 2018 Cameron Eldridge. All rights reserved.
//

import UIKit

class ExpenseTableViewCell: UITableViewCell {
    static let ID = "ExpenseCell"

    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var modifiedMarkView: UIView!

    func setup(for expense: Expense) {
        DispatchQueue.main.async {
            self.categoryLabel.text = expense.category
            self.amountLabel.text = expense.price.toString()
            self.amountLabel.font = self.amountLabel.font.usingFeatures([.tabularFigures])
            self.modifiedMarkView.backgroundColor = expense.id.isTemp ? ConArtist.Color.BrandVariant : ConArtist.Color.Brand
        }
    }
}
