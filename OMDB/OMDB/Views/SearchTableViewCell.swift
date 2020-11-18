//
//  SearchTableViewCell.swift
//  OMDB
//
//  Created by LasslopS on 17.11.20.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var year: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var poster: UIImageView!
    
    func configureCell(movie: Search.Movie) {
        
        title?.text = movie.title
        type?.text = movie.type
        year?.text = movie.year
        
        NetworkClient.shared.getImage(url: movie.poster, handler: { [weak self] (data, error) in
            if let _data = data {
                DispatchQueue.main.async {
                    self?.poster.image = UIImage(data: _data)
                }
            }
        })
    }
}
