//
//  ConventionListController.swift
//  ConArtist
//
//  Created by Cameron Eldridge on 2017-12-20.
//  Copyright © 2017 Cameron Eldridge. All rights reserved.
//

import Strongbox
import Foundation

class ConventionListController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        ensureSignedIn()
    }
    
    // MARK: - Navigation
    
    func ensureSignedIn() {
        if ConArtist.API.AuthToken == ConArtist.API.Unauthorized {
            performSegue(withIdentifier: SegueIdentifier.ShowSignIn.rawValue, sender: self)
        } else {
            // TODO: store user data and load that before reaching for the server
            Auth.reauthorize().then(execute: refresh)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifier.ShowSignIn.rawValue {
            (segue.destination as? ConArtistViewController)?.setCompletionCallback { _ in self.refresh() }
        }
    }
    
    private enum SegueIdentifier: String {
        case ShowSignIn, ShowConventionDetails
    }

    // MARK: - TableView
    
    enum ConventionTimePeriod: Int {
        case Present = 0, Future, Past
    }
    
    let cachedConventions: Cache<[ConventionTimePeriod: [Convention]]> = Cache {
        guard let model = ConArtist.Model else {
            return [.Past: [], .Present: [], .Future: []]
        }
        return [
            // TODO: this could be more efficient, but this is clean for now
            .Past: model.cons(before: Date.today()),
            .Present: model.cons(during: Date.today()),
            .Future: model.cons(after: Date.today())
        ]
    }

    func refresh() {
        cachedConventions.clear()
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard
            let timePeriod = ConventionTimePeriod(rawValue: section),
            let cons = cachedConventions.get()[timePeriod]
        else {
            return 0
        }
        return cons.count
    }
    
    let SectionHeaderHeight: CGFloat = 25
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let timePeriod = ConventionTimePeriod(rawValue: section) else {
            return nil
        }

        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: SectionHeaderHeight))
        let label = UILabel(frame: CGRect(x: 15, y: 0, width: tableView.bounds.width - 30, height: SectionHeaderHeight))
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = UIColor.black
        
        switch timePeriod {
        case .Past:
            label.text = "Previous"
        case .Present:
            label.text = "Current"
        case .Future:
            label.text = "Upcoming"
        }
        
        view.addSubview(label)
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard
            let timePeriod = ConventionTimePeriod(rawValue: section),
            let cons = cachedConventions.get()[timePeriod]
        else {
            return 0
        }
        return cons.isEmpty ? 0 as CGFloat : SectionHeaderHeight
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConventionListCell", for: indexPath) as! ConventionListRow
        if
            let timePeriod = ConventionTimePeriod(rawValue: indexPath.section),
            let item = cachedConventions.get()[timePeriod]?[indexPath.row]
        {
            cell.titleLabel?.text = item.name
            cell.dateLabel?.text = "Test date" // TODO: date range formatting (Mmm. DD, YYYY -- Mmm. DD, YYYY)
        }

        return cell
    }
}

