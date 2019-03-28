//
//  ChatLogController.swift
//
//  Created by Walter Alvarez
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {
    
    var dbHelper = DatabaseHelper()
    var storageHelper = StorageHelper()
    var db = Firestore.firestore()
    let storageRef = Storage.storage().reference()
    var chatID = ""
    var partnerID = ""
    var partnerName = ""
    var partnerPicRef = ""
    var messages = [Message]()
    let cellId = "messageCell"
    var smallTitleView = false
    let customTitleView = UIView()
    
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: UIControl.State())
        button.tintColor = UIColor(named: "RoyalPurple")
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    func observeMessages() {
        db.collection("chats").document(chatID).collection("messages").order(by: "created", descending: false)
            .addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(String(describing: error))")
                    return
                }
                
                snapshot.documentChanges.forEach { diff in
                    if (diff.type == .added) {
                        DispatchQueue.main.async {
                            let dictionary = diff.document.data() as [String: AnyObject]
                            
                            let message = Message(dictionary: dictionary)
                            
                            self.messages.append(message)
                            DispatchQueue.main.async(execute: {
                                self.collectionView?.reloadData()
                                self.scrollToBottom()
                            })
                        }
                    }
                }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        observeMessages()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = self.partnerName
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 58, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(MessageCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        
        setupNavBarWithUser()
        let reportBarBtn = UIBarButtonItem(image: UIImage(named: "reportUser"), style: .plain, target: self, action: #selector(reportUser))
        reportBarBtn.tintColor = .red
        navigationItem.setRightBarButtonItems([reportBarBtn, UIBarButtonItem(image: UIImage(named: "calendar"), style: .plain, target: self, action: #selector(showAvailability))], animated: false)
//        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "calendar"), style: .plain, target: self, action: #selector(showAvailability))
        
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.showProfile))
        navigationController?.navigationBar.addGestureRecognizer(gesture)
        setupInputComponents()
        setupKeyboardObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let height = navigationController?.navigationBar.frame.height else { return }
        if (height <= 64 && !smallTitleView) {
            self.navigationItem.titleView?.isHidden = false
            smallTitleView = true
        }
        else if (height > 64 && smallTitleView){
            self.navigationItem.titleView?.isHidden = true
            smallTitleView = false
        }
    }

    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func handleKeyboardWillShow(_ notification: Notification) {
        let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        let keyboardDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
        let tabBarHeight = tabBarController?.tabBar.frame.size.height
        containerViewBottomAnchor?.constant = -keyboardFrame!.height + tabBarHeight!
        UIView.animate(withDuration: keyboardDuration!, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @objc func handleKeyboardWillHide(_ notification: Notification) {
        let keyboardDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
        containerViewBottomAnchor?.constant = 0
        UIView.animate(withDuration: keyboardDuration!, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @objc func handleKeyboardDidShow(_ notification: Notification) {
        scrollToBottom()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.view.endEditing(true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MessageCollectionViewCell
        
        let message = messages[indexPath.item]
        cell.textView.text = message.text
        
        setupCell(cell, message: message)
        
        cell.bubbleWidthAnchor?.constant = estimateFrameForText(message.text!).width + 32
        
        return cell
    }
    
    fileprivate func setupCell(_ cell: MessageCollectionViewCell, message: Message) {
        let phImage = UIImage(named: "defaultPhoto.png")
        let ref = storageRef.child("profilePictures").child(self.partnerID).child(self.partnerPicRef)
        cell.profileImageView.sd_setImage(with: ref, placeholderImage: phImage)
        
        if message.senderId == Auth.auth().currentUser?.uid {
            //outgoing blue
            cell.bubbleView.backgroundColor = UIColor(named: "RoyalPurple")
            cell.textView.textColor = UIColor.white
            cell.textView.isEditable = false
            cell.profileImageView.isHidden = true
            
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
            
        } else {
            //incoming gray
            cell.bubbleView.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
            cell.textView.textColor = UIColor.black
            cell.textView.isEditable = false
            cell.profileImageView.isHidden = false
            
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 80
        
        //get estimated height somehow????
        if let text = messages[indexPath.item].text {
            height = estimateFrameForText(text).height + 20
        }
        
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
    }
    
    fileprivate func estimateFrameForText(_ text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    var containerViewBottomAnchor: NSLayoutConstraint?
    
    func setupNavBarWithUser() {
        customTitleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        customTitleView.addSubview(containerView)
        
        let phImage = UIImage(named: "defaultPhoto.png")
        let ref = storageRef.child("profilePictures").child(self.partnerID).child(self.partnerPicRef)
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        profileImageView.sd_setImage(with: ref, placeholderImage: phImage)

        containerView.addSubview(profileImageView)
        
        //ios 9 constraint anchors
        //need x,y,width,height anchors
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let nameLabel = UILabel()
        
        containerView.addSubview(nameLabel)
        nameLabel.text = self.partnerName
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.textColor = UIColor(named: "RoyalPurple")
        //need x,y,width,height anchors
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        containerView.centerXAnchor.constraint(equalTo: customTitleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: customTitleView.centerYAnchor).isActive = true

        self.navigationItem.titleView = customTitleView
        self.navigationItem.titleView?.isHidden = true
        
        //        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatController)))
    }
    
    func setupInputComponents() {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(containerView)
        
        //ios9 constraint anchors
        //x,y,w,h
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerViewBottomAnchor = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        containerViewBottomAnchor?.isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        containerView.addSubview(sendButton)
        //x,y,w,h
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        sendButton.isEnabled = false
        
        containerView.addSubview(inputTextField)
        //x,y,w,h
        inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        inputTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor(red: 220, green: 220, blue: 220, alpha: 0)
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorLineView)
        //x,y,w,h
        separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    @objc func showProfile() {
        self.performSegue(withIdentifier: "showUserProfile", sender: self)
        print("Gesture Tap Recognized")
    }
    
    private func scrollToBottom() {
        let lastSectionIndex = 0
        let lastItemIndex = (collectionView?.numberOfItems(inSection: lastSectionIndex))! - 1
        let indexPath = NSIndexPath(item: lastItemIndex, section: lastSectionIndex)
        
        collectionView!.scrollToItem(at: indexPath as IndexPath, at: UICollectionView.ScrollPosition.bottom, animated: false)
    }
    
    @objc func handleSend() {
        let chatID = self.chatID
        let senderID = Auth.auth().currentUser?.uid
        let content = inputTextField.text!
        let timestamp = Date()
        dbHelper.storeMessage(senderID: senderID!, chatID: chatID, content: content, senderName: UserProfile.name.components(separatedBy: " ")[0], timestamp: timestamp)
        inputTextField.text = ""
        scrollToBottom()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        let str = inputTextField.text!
        let trimmed = str.trimmingCharacters(in: .whitespacesAndNewlines)
        if (trimmed != "") {
            sendButton.isEnabled = true
        }
        else if (trimmed == "") {
            sendButton.isEnabled = false
        }
    }
    
    @objc func showAvailability() {
        print("Calendar!")
    }
    
    @objc func reportUser() {
        print("Report User!")
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        super.prepare(for: segue, sender: sender)
        
        switch (segue.identifier ?? "") {
            
        case "showUserProfile":
            guard let userProfileVC = segue.destination as? ProfileViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            userProfileVC.userID = self.partnerID
            
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
        }
    }
}













