//
//  ViewController.swift
//  OMDB
//
//  Created by LasslopS on 17.11.20.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var movies = [Search.Movie]()
    private var currentPage = 1
    private var totalCount = 0
    private var isLoading = false
    private let networkClient = NetworkClient.shared
    private let searchController = UISearchController(searchResultsController: nil)
    fileprivate var searchText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
       configureView()
    }
    
    func configureView() {
        self.title = "Movie Search"
        navigationController?.navigationBar.prefersLargeTitles = true

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        
        tableView.prefetchDataSource = self
        tableView.keyboardDismissMode = .onDrag
        
    }
    
    func searchMovies() {
        guard !isLoading else {return}
        isLoading = true
        
        networkClient.search(for: searchText!, page: currentPage) {(searchObject, error) in
            if let search = searchObject, error == nil {
                self.isLoading = false
                if let searchResults = searchObject?.results {
                    DispatchQueue.main.async {
                        self.currentPage += 1
                        self.totalCount = Int(search.totalResults!) ?? 0
                        self.movies.append(contentsOf: searchResults)
                        self.tableView.reloadData()
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.movies.removeAll()
                    self.tableView.reloadData()
                }
            }
            
        }
    }
    
    func resetSearch() {
        self.currentPage = 1
        self.totalCount = 0
        self.movies.removeAll()
    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("totalcount: \(totalCount), movies.count: \(movies.count), selectedIndex: \(tableView.indexPathForSelectedRow!.row)")
        let movie = movies[tableView.indexPathForSelectedRow!.row]
        let detailVC = segue.destination as! DetailViewController
        detailVC.imdbID = movie.imdbID
        detailVC.poster = movie.poster
    }
    
}

extension MainViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return totalCount
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell", for: indexPath) as? SearchTableViewCell  else {
            fatalError()
        }
        
        if !isLoadingCell(for: indexPath) {
            let movie = movies[indexPath.row]
            cell.configureCell(movie: movie)
        }
        return cell
    }
    
}

extension MainViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchTerm = searchController.searchBar.text {
            guard searchTerm.count > 2, searchTerm != self.searchText else {return}
            self.searchText = searchTerm
            resetSearch()
            searchMovies()
        }
    }
}

extension MainViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
      if indexPaths.contains(where: isLoadingCell) {
        self.searchMovies()
      }
    }

}

private extension MainViewController {
  func isLoadingCell(for indexPath: IndexPath) -> Bool {
    return indexPath.row >= movies.count
  }

}



