//
//  NewChatViewController.swift
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class NewChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var addRowButton: UIButton!
    
    var db: Firestore!
    var newWatchers: [NewWatcher] = [NewWatcher(email: "")]
    var finalWatchers: [String] = []
    var conversation: Conversation = Conversation(owner: "", watchers: [""], chatLogID: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        tableView.delegate  = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: K.NewWatcher.cellNibName, bundle: nil), forCellReuseIdentifier: K.NewWatcher.cellIdentifier)
        

    }
    
    
    @IBAction func addWatcherRow(_ sender: Any) {
        let newWatcher = NewWatcher(email: "")
        newWatchers.append(newWatcher)
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.newConvoToChat {
            let ChatVC  = segue.destination as! ChatViewController
            ChatVC.conversation = conversation
            
        }
    }
    
    @IBAction func sendPressed(_ sender: Any) {
        if let user = Auth.auth().currentUser?.email {
            for watcher in newWatchers {
                let validEmail = Helper.isValidEmail(email: watcher.email)
                if watcher.email != user && watcher.email != "" && validEmail {
                    finalWatchers.append(watcher.email)
                }
            }
        }
        
        if finalWatchers.isEmpty {
            let alert = UIAlertController(title: "Can't create the conversation", message: "Please re-check your information ^-^", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Close", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            createConversation()
        }
        
    }
    
    func createConversation(){
        if let user = Auth.auth().currentUser?.email {
            finalWatchers.append(user)
        
            let chatLogID = db.collection(K.FStore.conversationsCollectionName).addDocument(data: [
                K.Conversations.watchersField: finalWatchers,
                K.Conversations.ownerField: user,
                K.Conversations.statusField: K.Conversations.Statuses.requested
            ]).documentID
            conversation = Conversation(owner: user, watchers: finalWatchers, chatLogID: chatLogID)
            
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: K.newConvoToChat, sender: self)
            }
        }
    }
}

//MARK: - Tableview Datasource

extension NewChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newWatchers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.NewWatcher.cellIdentifier, for: indexPath) as! NewWatcherCell
        cell.NewWatcherTextField.delegate = self
        cell.NewWatcherTextField.tag = indexPath.item
        cell.NewWatcherTextField.text! = newWatchers[indexPath.item].email
        return cell
    }

}

extension NewChatViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let user = Auth.auth().currentUser?.email {
            let validEmail = Helper.isValidEmail(email: textField.text!)
            if textField.text! == user || !validEmail {
                textField.attributedText = NSAttributedString(string: textField.text!, attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            }
            textField.text = textField.text?.lowercased()
            newWatchers[textField.tag].email = textField.text!
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.attributedText = NSAttributedString(string: textField.text!, attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
    }
    
}


extension NewChatViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
            -> UISwipeActionsConfiguration? {
            let deleteAction = UIContextualAction(style: .destructive, title: nil) { (_, _, completionHandler) in
                let cell = tableView.cellForRow(at: indexPath) as! NewWatcherCell
                cell.NewWatcherTextField.text = ""
                self.newWatchers.remove(at: indexPath.item)
                tableView.reloadData()
                completionHandler(true)
            }
            deleteAction.image = UIImage(systemName: "trash")
            deleteAction.backgroundColor = .systemRed
            let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
            return configuration
    }

}
