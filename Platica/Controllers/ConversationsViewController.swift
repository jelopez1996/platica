//
//  RecipientViewController.swift
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import SkeletonView

class ConversationsViewController: UIViewController {
    

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var newConversationButton: UIButton!
    
    
    var conversation: Conversation!
    var db: Firestore!
    var conversations: [Conversation] = []
    var listenerRef: ListenerRegistration!
    var userEmail: String = ""
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
        
        //
        tableView.layer.cornerRadius = K.cornerRadius
        
        // Add a shadow to the newConversationButton
        
        newConversationButton.layer.cornerRadius = newConversationButton.frame.size.height / 2
        newConversationButton.layer.shadowColor = UIColor.black.cgColor
        newConversationButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        newConversationButton.layer.shadowOpacity = 0.5
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        if let user = Auth.auth().currentUser?.email {
            userEmail = user
        }
        
        tableView.delegate  = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: K.Conversations.cellNibName, bundle: nil), forCellReuseIdentifier: K.Conversations.cellIdentifier)
        tableView.isSkeletonable = true
        tableView.showAnimatedSkeleton(usingColor: .wetAsphalt, transition: .crossDissolve(0.25))

        
        
        
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
        loadConversations()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.conversationsToChatSegue {
            let ChatVC  = segue.destination as! ChatViewController
            ChatVC.conversation = conversation
            
        }
    }
    
    @IBAction func signOutPressed(_ sender: Any) {
        let firebaseAuth = Auth.auth()
            do {
                listenerRef.remove()
               try firebaseAuth.signOut()
               navigationController?.popToRootViewController(animated: true)
               
            } catch let signOutError as NSError {
               print ("Error signing out: %@", signOutError)
            }
        }

    @IBAction func newConversationButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: K.conversationsToNewConversation, sender: self)
    }
    
    func loadConversations(){
        listenerRef = db.collection(K.FStore.conversationsCollectionName)
            .whereField(K.Conversations.watchersField, arrayContains: userEmail)
            .addSnapshotListener { (querySnapshot, error) in
                if let e = error {
                    let alert = UIAlertController(title: "Sorry, theres an error...", message: e.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Click", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    self.conversations = []
                    if let snapShotDoc = querySnapshot?.documents {
                        for doc in snapShotDoc {
                            let data = doc.data()
                            if let watchers = data[K.Conversations.watchersField] as? [String], let owner = data[K.Conversations.ownerField] as? String {
                                let conversation = Conversation(owner: owner, watchers: watchers, chatLogID: doc.documentID)
                                self.conversations.append(conversation)
                            }
                        }
                        DispatchQueue.main.async {
                            self.tableView.stopSkeletonAnimation()
                            self.tableView.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.5))
                        }
                    }
                }
            }
            
        
    }
    
    func deleteConversation(_ indexPath: IndexPath){
        db.collection(K.FStore.conversationsCollectionName).document(conversations[indexPath.item].chatLogID).delete { (error) in
            if((error) != nil) {
                print(error?.localizedDescription)
            } else {
                self.tableView.reloadData()
            }
        }
    }
    
    func removeFromConversation(_ indexPath: IndexPath){
        tableView.showSkeleton()
        var watchers = conversations[indexPath.item].watchers
        watchers.removeAll { (watcher) -> Bool in
            return watcher == userEmail
        }
        db.collection(K.FStore.conversationsCollectionName).document(conversations[indexPath.item].chatLogID).updateData(["watchers" : watchers]) { (error) in
            if((error) != nil) {
                print(error?.localizedDescription)
            } else {
                self.tableView.reloadData()
            }
        }
        
    }
}
//MARK: - TableView Datasource

extension ConversationsViewController: SkeletonTableViewDataSource {
    func numSections(in collectionSkeletonView: UITableView) -> Int {
        return 1
    }
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return K.Conversations.cellIdentifier
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Conversations.cellIdentifier, for: indexPath) as! ConversationCell
        if !conversations.isEmpty {
            let conversation = conversations[indexPath.item]
            if conversation.watchers.count == 2 {
               cell.conversationImage.image = UIImage(systemName: "person.2.fill")
            } else {
                cell.conversationImage.image = UIImage(systemName: "person.3.fill")
            }
            var newWatchers = conversation.watchers
            newWatchers.removeAll(where: { $0 == userEmail })
            cell.conversationInfo.text = newWatchers.joined(separator: ",")
        }
        return cell
    }
}

//MARK: - TableView Delegate
extension ConversationsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        conversation = conversations[indexPath.item]
        performSegue(withIdentifier: K.conversationsToChatSegue, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
            -> UISwipeActionsConfiguration? {
                var deleteTitle = "Remove"
                var alertTitle = "You're gonna remove yourself from the conversation"
                var alertMessage = "You will no longer get updates or be able to see the conversation. Are you sure?"
                var alertOption1 = "No, keep me on"
                var alertOption2 = "Yes, remove me"
                var alertFunc = removeFromConversation
                if conversations[indexPath.item].owner == userEmail {
                    deleteTitle = "Delete"
                    alertTitle = "You're gonna delete the conversation"
                    alertMessage = "You're the owner of the converasation so if you delete it its gone for everyone! Are you sure?"
                    alertOption1 = "No, keep it"
                    alertOption2 = "Yes delete it"
                    alertFunc = deleteConversation
                }
                    
                let deleteAction = UIContextualAction(style: .destructive, title: deleteTitle) { (_, _, completionHandler) in
                    let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: alertOption1, style: UIAlertAction.Style.default, handler: nil))
                    alert.addAction(UIAlertAction(title: alertOption2, style: UIAlertAction.Style.default, handler: { (uiAlertAction) in
                        alertFunc(indexPath)
                    }))
                    self.present(alert, animated: true, completion: nil)
                completionHandler(true)
            }
                
                deleteAction.backgroundColor = .systemRed
                let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
                return configuration
    }
    
}
