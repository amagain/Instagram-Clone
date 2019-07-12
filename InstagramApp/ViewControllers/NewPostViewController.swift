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
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @objc func cancelButtonPressed() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func libraryButtonTapped(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NSNotification.Name.RawValue("newPage")), object: NewPostPagesToShow.library)
    }
    
    @IBAction func photoButtonTapped(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NSNotification.Name.RawValue("newPage")), object: NewPostPagesToShow.camera)
    }
}
