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
    private let imagePicker = UIImagePickerController()
    
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
            profileHeaderTableViewCell.delegate = self
            
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
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            if let resizedImage = pickedImage.resized(toWidth: 1080) {
                if let imageData = resizedImage.jpegData(compressionQuality: 0.75) {
                    // upload to firebase
                }
                
            }
        }
    }
}
extension ProfileViewController: ProfileHeaderDelegate {
    func profileImageDidTouch() {
        let alertController = UIAlertController(title: "Change Profile", message: "Choose an option to change your profile photo", preferredStyle: .actionSheet)
        
        let libraryOption = UIAlertAction(title: "Import from Library", style: .default){ (action) in
            self.imagePicker.allowsEditing = true
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        let takePhotoOption = UIAlertAction(title: "Take Photo", style: .default) { (action) in
            self.imagePicker.allowsEditing = true
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(libraryOption)
        alertController.addAction(takePhotoOption)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
