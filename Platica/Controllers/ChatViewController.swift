//
//  ChatViewController.swift
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ChatViewController: UIViewController {
    
    var db: Firestore!
    
    var conversation: Conversation = Conversation(owner: "null", watchers: ["null"], chatLogID: "null")
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    var messages: [Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.title = conversation.watchers.joined(separator: ",")

        
//        let newBackButton = UIBarButtonItem(image: UIImage(systemName: "arrowshape.turn.up.left.circle.fill"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.customFunc))
//        navigationItem.leftBarButtonItem = newBackButton
        
        //FireBase setup
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        tableView.dataSource = self
        tableView.register(UINib(nibName: K.Messages.cellNibName, bundle: nil), forCellReuseIdentifier: K.Messages.cellIdentifier)
        
        loadMessages()
        

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidLoad()
//        NotificationCenter.default.addObserver(self, selector: #selector(self.openActivity), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
//    @objc private func openActivity(){
//        view.endEditing(true)
//    }
    
//    @objc private func customFunc(){
//        let viewControllers = self.navigationController?.viewControllers
//        for controller in viewControllers! {
//            if controller is ConversationsViewController {
//                self.navigationController?.popToViewController(controller, animated: true)
//            }
//        }
        
//    }
    
    
    func loadMessages(){

        self.messages = []
        db.collection(K.FStore.conversationsCollectionName).document(conversation.chatLogID).collection(K.FStore.messagesCollectionName)
            .order(by: K.Messages.dateField)
            .addSnapshotListener({ (querySnapshot, error) in
                if let e = error {
                    let alert = UIAlertController(title: "Sorry, theres an error...", message: e.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Click", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    if let snapShotDoc = querySnapshot?.documents {
                        self.messages = []
                        for doc in snapShotDoc {
                            let data = doc.data()
                            if let messageSender = data[K.Messages.senderField] as? String, let messageBody = data[K.Messages.bodyField] as? String, let messageWatchers = data[K.Messages.watchersField] as? [String] {
                                let message = Message(sender: messageSender, body: messageBody, watchers: messageWatchers)
                                self.messages.append(message)
                                print("Messages loaded")
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                    let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                                    self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                                }

                            }
                        }
                    }
                }
            })
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        if let messageBody = messageTextfield.text, let messageSender = Auth.auth().currentUser?.email {
            db.collection(K.FStore.conversationsCollectionName).document(conversation.chatLogID).collection(K.FStore.messagesCollectionName)
                .addDocument(
                    data: [
                        K.Messages.senderField: messageSender,
                        K.Messages.bodyField: messageBody,
                        K.Messages.dateField: Date().timeIntervalSince1970,
                        K.Messages.watchersField: conversation.watchers
                    ]) { (error) in
                        if let e = error {
                            let alert = UIAlertController(title: "Sorry, theres an error...", message: e.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                            alert.addAction(UIAlertAction(title: "Click", style: UIAlertAction.Style.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        } else {
                            self.loadMessages()
                            DispatchQueue.main.async {
                                self.messageTextfield.text = ""
                            }
                            
                        }

                    }
        }
        
    }
    
    @IBAction func signOutPressed(_ sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            navigationController?.popToRootViewController(animated: true)
            
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
}

//MARK: - TableView Datasource

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Messages.cellIdentifier, for: indexPath) as! MessageCell
        let message = messages[indexPath.item]
        if message.sender == Auth.auth().currentUser?.email {
            cell.leftImageVeiew.isHidden = true
            cell.rightImageView.isHidden  = false
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.lightPurple)
            cell.label.textColor = UIColor(named: K.BrandColors.purple)
            
        } else {
            cell.leftImageVeiew.isHidden = false
            cell.rightImageView.isHidden  = true
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.purple)
            cell.label.textColor = UIColor(named: K.BrandColors.lightPurple)
        }
        
        cell.label.text = messages[indexPath.item].body
        return cell
    }
    
    
}
