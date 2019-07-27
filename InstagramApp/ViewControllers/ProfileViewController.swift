import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import SDWebImage

enum ProfileType {
    case personal, otherUser
}

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var profileType: ProfileType = .personal
    var posts: [Post] = [Post]()
    var user: UserModel?
    private let imagePicker = UIImagePickerController()
    
    lazy var progressIndicator: UIProgressView = {
        let _progressIndicator = UIProgressView()
        _progressIndicator.trackTintColor = UIColor.lightGray
        _progressIndicator.progressTintColor = UIColor.black
        _progressIndicator.progress = Float(0)
        _progressIndicator.translatesAutoresizingMaskIntoConstraints = false
        return _progressIndicator
    }()
    
    lazy var cancelButton: UIButton = {
        let _cancelButton = UIButton()
        _cancelButton.setTitle("Cancel Upload", for: .normal)
        _cancelButton.setTitleColor(UIColor.black, for: .normal)
        _cancelButton.addTarget(self, action: #selector(cancelUpload), for: .touchUpInside)
        _cancelButton.translatesAutoresizingMaskIntoConstraints = false
        return _cancelButton
    }()
    
    var uploadTask: StorageUploadTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "FeedTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedTableViewCell")
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        view.addSubview(progressIndicator)
        view.addSubview(cancelButton)
        let constraints: [NSLayoutConstraint] = [
            progressIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            progressIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0),
            progressIndicator.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            progressIndicator.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            cancelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            cancelButton.topAnchor.constraint(equalTo: progressIndicator.bottomAnchor, constant: 5)
        ]
        NSLayoutConstraint.activate(constraints)
        progressIndicator.isHidden = true
        cancelButton.isHidden = true
        imagePicker.delegate = self
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
    
    func uploadImage(data: Data) {
        if let user = Auth.auth().currentUser {
            progressIndicator.isHidden = false
            cancelButton.isHidden = false
            progressIndicator.progress = Float(0)
            
            let imageId: String = UUID().uuidString.lowercased().replacingOccurrences(of: "-", with: "_")
            let imageName = "\(imageId).jpg"
            let pathToPicture = "images/\(user.uid)/\(imageName)"
            let storageRef = Storage.storage().reference(withPath: pathToPicture)
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpg"
            uploadTask = storageRef.putData(data, metadata: metaData, completion: { [weak self] (metaData, error) in
                guard let strongSelf = self else { return }
                DispatchQueue.main.async {
                    strongSelf.progressIndicator.isHidden = true
                    strongSelf.cancelButton.isHidden = true
                }
                if let error = error {
                    print(error.localizedDescription)
                    let alert = Helper.errorAlert(title: "Upload Error", message: "There was a problem uploading the image")
                    DispatchQueue.main.async {
                        strongSelf.present(alert, animated: true, completion: nil)
                    }
                }
                else {
                    storageRef.downloadURL(completion: {(url, error) in
                        if let url = url,
                            error == nil {
                            UserModel.collection.child(user.uid).updateChildValues(["profileImage": url.absoluteString])
                        }
                        else {
                            let alert = Helper.errorAlert(title: "Upload Error", message: "There was a problem downloading the image")
                            DispatchQueue.main.async {
                                strongSelf.present(alert, animated: true, completion: nil)
                            }
                        }
                    })
                    
                }
            })
            uploadTask?.observe(.progress) { [weak self] (snapshot) in
                guard let strongSelf = self else { return }
                let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
                DispatchQueue.main.async {
                    strongSelf.progressIndicator.setProgress(Float(percentComplete), animated: true)
                }
            }
        }
    }
    
    @objc func cancelUpload() {
        progressIndicator.isHidden = true
        cancelButton.isHidden = true
        uploadTask?.cancel()
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
                profileHeaderTableViewCell.nameLabel.text = user.username
                if let profileImage = user.profileImage {
                    profileHeaderTableViewCell.profileImageView.sd_cancelCurrentImageLoad()
                    profileHeaderTableViewCell.profileImageView.sd_setImage(with: profileImage, completed: nil)
                }
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
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            if let resizedImage = pickedImage.resized(toWidth: 1080) {
                if let imageData = resizedImage.jpegData(compressionQuality: 0.75) {
                    uploadImage(data: imageData)
                }
            }
        }
        dismiss(animated: true, completion: nil)
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
