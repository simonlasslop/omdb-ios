//
//  DetailViewController.swift
//  OMDB
//
//  Created by LasslopS on 17.11.20.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var imdbID = String()
    var poster = String()
    private var movie: Movie? {
        didSet {
          self.configureView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureView()
    }
    
    func configureView() {
        NetworkClient.shared.getMovie(with: imdbID) {(movieObject, error) in
            if let movie = movieObject, error == nil {
                    DispatchQueue.main.async {
                        self.tableView.isHidden = false
                        self.title = movie.title
                        self.movie = movie
                        self.tableView.reloadData()
                    }
                }
        }
    }

}

extension DetailViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DetailViewCell", for: indexPath) as? DetailViewCell  else {
            fatalError()
        }
        guard let current = movie else { return cell }
        cell.configureCell(movie: current)
        return cell
    }
}
