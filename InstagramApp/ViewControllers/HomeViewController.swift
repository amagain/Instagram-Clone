import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var rightBarItemImage = UIImage(named: "send_nav_icon")
    var leftBarItemImage = UIImage(named: "camera_nav_icon")
    
    lazy var posts: [Post] = {
        let model = Model()
        return model.postList
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 88.0
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.tableFooterView = UIView()
        rightBarItemImage?.withRenderingMode(.alwaysOriginal)
        leftBarItemImage?.withRenderingMode(.alwaysOriginal)
        
        tableView.register(UINib(nibName: "FeedTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedTableViewCell")
        tableView.register(UINib(nibName: "StoriesTableViewCell", bundle: nil), forCellReuseIdentifier: "StoriesTableViewCell")
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: rightBarItemImage, style: .plain, target: .none, action: .none)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: leftBarItemImage, style: .plain, target: .none, action: .none)
        
        let profileImageView = UIImageView(image: UIImage(named: "logo_nav_icon"))
        self.navigationItem.titleView = profileImageView
    }
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count + 1
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "StoriesTableViewCell") as? StoriesTableViewCell {
                return cell
            }
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedTableViewCell") as! FeedTableViewCell
        let currentIndex = indexPath.row - 1
        let postData = posts[currentIndex]
        cell.profileImage.image = postData.user.profileImage
        cell.postImage.image = postData.postImage
        cell.dateLabel.text = postData.datePosted
        cell.likesCountLabel.text = "\(postData.likesCount) likes"
        cell.postCommentLabel.text = postData.postComment
        cell.usernameTItleButton.setTitle(postData.user.name, for: .normal)
        cell.commentCountButton.setTitle("View all \(postData.commentCount) comments", for: .normal)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
