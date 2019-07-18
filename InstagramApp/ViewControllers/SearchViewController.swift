import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var reuseIdentifier = "ExploreCollectionViewCell"
    var searchController: UISearchController!
    
    lazy var posts: [Post] = {
        let model = Model()
        return model.postList
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.searchBar.showsCancelButton = false
        
        for subView in searchController.searchBar.subviews {
            for subView1 in subView.subviews {
                if let textField = subView1 as? UITextField {
                    textField.backgroundColor = UIColor(red: 0.93, green: 0.93, blue: 0.93, alpha: 1.0)
                    textField.textAlignment = NSTextAlignment.center
                }
            }
            searchController.dimsBackgroundDuringPresentation = false
            searchController.definesPresentationContext = true
            searchController.hidesNavigationBarDuringPresentation = false
            
            let searchBarContainer = SearchBarContainerView(customSearchBar: searchController.searchBar)
            searchBarContainer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
            navigationItem.titleView = searchBarContainer
        }
    }
}

extension SearchViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
}
extension SearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExploreCollectionViewCell", for: indexPath) as? ExploreCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.exploreImage.image = posts[indexPath.item].postImage
        return cell
    }
}
