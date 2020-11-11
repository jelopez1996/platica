//
//  K.swift
//
//  Created by Jesus Lopez on 8/17/20.
//

import UIKit

struct K {
    static let appName = "Platica"
    static let conversationsToChatSegue = "ConversationsToChat"
    static let registerToConversationsSegue = "RegisterToConversations"
    static let loginToConversationsSegue = "LoginToConversations"
    static let conversationsToNewConversation = "ConversationsToNewConversation"
    static let newConvoToChat = "NewConversationToChat"
    static let newUser = "users"
    
    static let cornerRadius = CGFloat(15)
    static let shadowOpacity = Float(0.2)
    
    struct BrandColors {
        static let main = "MainTheme"
        static let purple = "BrandPurple"
        static let lightPurple = "BrandLightPurple"
        static let blue = "BrandBlue"
        static let lighBlue = "BrandLightBlue"
    }
    
    struct FStore {
        static let messagesCollectionName = "messages"
        static let conversationsCollectionName = "conversations"
        static let usersCollection = "users"
        static let profileImagesCollection = "profileImages"
    }
    
    struct Conversations {
        static let cellIdentifier = "ConversationCell"
        static let cellNibName = "ConversationCell"
        static let watchersField = "watchers"
        static let ownerField = "owner"
    }
    
    struct Messages {
        static let cellIdentifier = "MessageCell"
        static let cellNibName = "MessageCell"
        static let senderField = "sender"
        static let bodyField = "body"
        static let watchersField = "watchers"
        static let dateField = "date"
    }
    
    struct NewWatcher {
        static let cellIdentifier = "NewWatcherCell"
        static let cellNibName = "NewWatcherCell"
    }
}
