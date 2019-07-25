import UIKit
import FirebaseDatabase
import FirebaseAuth

enum ProfileType {
    case personal, otherUser
}
class ProfileViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var profileType: ProfileType = .personal
    var posts: [Post] = [Post]()
    var user: UserModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "FeedTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedTableViewCell")
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        loadData()
    }
    
    func loadData() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let userRef = UserModel.collection.child(userId)
        let spinner = UIViewController.displayLoading(withView: self.view)
        userRef.observe(.value) { [weak self] (snapshot) in
            guard let strongSelf = self else  { return }
            UIViewController.removeLoading(spinner: spinner)
            guard let user = UserModel(snapshot) else { return }
            strongSelf.user = user
            DispatchQueue.main.async {
                strongSelf.tableView.reloadData()
            }
        }
    }
}
extension ProfileViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        else if section == 1 {
            return 1
        }
        else {
            return posts.count
        }
    }
}

extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let profileHeaderTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ProfileHeaderTableViewCell") as! ProfileHeaderTableViewCell
            profileHeaderTableViewCell.profileType = profileType
            profileHeaderTableViewCell.nameLabel.text = ""
            
            if let user = user {
                print(user)
                profileHeaderTableViewCell.nameLabel.text = user.username
            }
            switch profileType {
            case .otherUser:
                profileHeaderTableViewCell.profileButton.setTitle("Follow", for: .normal)
                
            case .personal:
                profileHeaderTableViewCell.profileButton.setTitle("Logout", for: .normal)
                profileHeaderTableViewCell.profileButton.setTitleColor(UIColor.red, for: .normal)
            }
            return profileHeaderTableViewCell
        }
        else if indexPath.section == 1 {
            let profileViewStyleTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ProfileViewStyleTableViewCell") as! ProfileViewStyleTableViewCell
            return profileViewStyleTableViewCell
        }
        else if indexPath.section == 2 {
            let feedTableViewCell = tableView.dequeueReusableCell(withIdentifier: "FeedTableViewCell") as! FeedTableViewCell
            return feedTableViewCell
        }
        else {
            return UITableViewCell()
        }
        
    }
}
