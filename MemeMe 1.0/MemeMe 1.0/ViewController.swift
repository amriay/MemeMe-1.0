//
//  ViewController.swift
//  MemeMe 1.0
//
//  Created by Genuis on 24/09/2019.
//  Copyright © 2019 Abdullah ALAmri. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UITextFieldDelegate {

   

    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    
    @IBOutlet weak var bottomTextField: UITextField!
    
    @IBOutlet weak var toolBar: UIToolbar!
    
    @IBOutlet weak var nanBar: UIToolbar!
    
    func memeTextAttributes(_ textField: UITextField){
        textField.defaultTextAttributes = [
           NSAttributedString.Key.strokeColor : UIColor.black,
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSAttributedString.Key.strokeWidth: -4
             ]
        textField.textAlignment = .center
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
     
        memeTextAttributes(topTextField)
        memeTextAttributes(bottomTextField)
        textFieldDidEndEditing(bottomTextField)
        textFieldDidEndEditing(topTextField)
    
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        subscribeToKeyboardNotifications()
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeFromKeyboardNotifications()
        
    }
    

    @IBAction func picimag(_ sender: UIButton) {
        
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        imagePicker.sourceType = (sender.tag == 0) ? .photoLibrary : .camera
            
        present(imagePicker, animated: true, completion: nil)
        
    }
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageChange(image: image)
            
        }
        
        dismiss(animated: true, completion: nil)
        
   }
   
    func textFieldDidBeginEditing(_ textField: UITextField) {
        bottomTextField.delegate = self
        topTextField.delegate = self
        
        let text = textField.text ?? ""
        if (textField == topTextField && text == "TOP"){
            textField.text = ""
            
        } else if (textField == bottomTextField && text == "BOTTOM"){
            textField.text = "" }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        bottomTextField.delegate = self
        topTextField.delegate = self
        let emp = textField.text?.isEmpty ?? false
        if emp && textField == topTextField{
            topTextField.text = "TOP"}
        else if emp && textField == bottomTextField{
            bottomTextField.text = "BOTTOM" }
    }
    
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector( keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self,name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if bottomTextField.isEditing{
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    @objc func keyboardWillHide(_ notification:Notification){
        view.frame.origin.y = 0
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        
        
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        
      
        imageChange(image:nil)
    }
    
    @IBAction func shareButton(_ sender: Any) {
        
       
        let controller = UIActivityViewController(activityItems: [generateMemedImage()], applicationActivities: nil)
        controller.completionWithItemsHandler = {
            
            (activity, completed, items, error) in if completed{
                self.save()
            }
            
        }
        
        
        self.present(controller, animated: true, completion: nil)
    }
    
    func generateMemedImage() -> UIImage {
        // TODO: Hide toolbar and navbar
        // Render view to an image
        nanBar.isHidden = true
        toolBar.isHidden = true
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
       
        // TODO: Show toolbar and navbar
        nanBar.isHidden = false
        toolBar.isHidden = false
        return memedImage
    }
    
    func save() {
        
        let topText = topTextField.text!
        let bottomText = bottomTextField.text!
        let imageView = img.image!
        let memedImage = generateMemedImage()
        
        // Create the meme
        
        _ = Meme(topText: topText, bottomText: bottomText, originalImage: imageView, memedImage: memedImage)
        
    }
    
    
    func imageChange(image: UIImage?) {
        
        img.image = image
        
        shareButton.isEnabled = (image != nil)
        
        
    }


}

