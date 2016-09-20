import UIKit

class ViewController: UIViewController {
    @IBOutlet private var regexField : UITextField!
    @IBOutlet private var textField : UITextField!
    
    @IBAction func checkRegex() {
        let regex = RustRegex(regex: regexField.text)!
        let position = regex.find(textField.text)
        
        let message = (position < 0) ? "Not found" : "Found at \(position)"
        let alert = UIAlertView(title: "Result", message: message, delegate: nil, cancelButtonTitle: "OK")
        alert.show()
    }
}

