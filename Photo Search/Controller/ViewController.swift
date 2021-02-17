//
//  ViewController.swift
//  Photo Search
//
//  Created by Alexander  Sapianov on 04.02.2021.
//

import UIKit
import SDWebImage



class ViewController: UIViewController,UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate{
    
    private var results: [Result?] = []
    private let searchbar = UISearchBar()
    private var collectionView: UICollectionView?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        searchbar.delegate = self
        view.addSubview(searchbar)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: view.frame.size.width-10, height: view.frame.size.width)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: ImageCollectionViewCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
        
        view.addSubview(collectionView)
        self.collectionView = collectionView
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchbar.frame = CGRect(x: 10, y: view.safeAreaInsets.top, width: view.frame.size.width-20, height: 50)
        collectionView?.frame = CGRect(x: 0, y: view.safeAreaInsets.top+55, width: view.frame.size.width, height: view.frame.size.height-55)
        
    }
    
    // MARK: - Functions
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchbar.text {
            searchbar.resignFirstResponder()
            results = []
            collectionView?.reloadData()
            fetchPhotos(query: text)
        }
    }

    func fetchPhotos(query: String) {
        let urlString = "https://api.unsplash.com/search/photos?page=1&per_page=30&query=\(query)&client_id=jWrCY2q87ZBoNXnb93FhPOSv0vd6iVKSGRmbqBwW7tE"
        guard let url = URL(string: urlString) else { return }
        let task = URLSession.shared.dataTask(with: url) {[weak self] data,_, error in
            guard let data = data, error == nil else { return }
            
            do {
                let jsonResult = try JSONDecoder().decode(APIResponse.self, from: data)
                print(jsonResult.results.count)
                DispatchQueue.main.async {
                    self?.results = jsonResult.results
                    self?.collectionView?.reloadData()
                }
            }
            catch {
                print(error)
            }
        }
        task.resume()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return results.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let imageURLString = (results[indexPath.row]?.urls.regular)! 
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.identifier, for: indexPath) as? ImageCollectionViewCell else { return UICollectionViewCell()}
        cell.configure(with: imageURLString)
        return cell
    }
}

