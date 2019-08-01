import UIKit

enum NewPostPagesToShow: Int {
    case library, camera
    
    var identifier: String {
        switch self {
        case .library:
            return "PhotoLibraryVC"
        case .camera:
            return "CameraVC"
        }
    }
    static func PagesToShow() -> [NewPostPagesToShow] {
        return [.library, .camera]
    }
}

class NewPostViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonPressed))
  //      NotificationCenter.default.addObserver(self, selector: #selector(NewPostViewController.moveToCreatePost(notification:)), name: NSNotification.Name(rawValue: "createNewPost"), object: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @objc func cancelButtonPressed() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func moveToCreatePost(notification: NSNotification) {
        if let receivedObject = notification.object as? UIImage {
            performSegue(withIdentifier: "CreatePost", sender: receivedObject)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CreatePost" {
            guard let postImage = sender as? UIImage else { return }
            let destinationVC = segue.destination as! CreatePostViewController
            destinationVC.postImage = postImage
        }
    }
    @IBAction func libraryButtonTapped(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NSNotification.Name.RawValue("newPage")), object: NewPostPagesToShow.library)
    }
    
    @IBAction func photoButtonTapped(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NSNotification.Name.RawValue("newPage")), object: NewPostPagesToShow.camera)
    }
}
