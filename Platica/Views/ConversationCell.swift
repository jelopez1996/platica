//
//  ContactCell.swift
//

import UIKit

class ConversationCell: UITableViewCell {


    @IBOutlet weak var conversationInfo: UILabel!
    @IBOutlet weak var conversationImage: UIImageView!
    @IBOutlet weak var cellView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        cellView.layer.cornerRadius = K.cornerRadius
        cellView.layer.shadowColor = UIColor.black.cgColor
        cellView.layer.shadowOffset = CGSize(width: 1, height: 1)
        cellView.layer.shadowOpacity = K.shadowOpacity
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
