//
//  ViewController.swift
//  Flash Chat
//
//  Created by Angela Yu on 29/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,
        UITextFieldDelegate {
    
    // Declare instance variables here

    var msgArray : [Message] = [Message]()
    // We've pre-linked the IBOutlets
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    let myMessage : Message =  Message()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: Set yourself as the delegate and datasource here:
        messageTableView.delegate = self
        messageTableView.dataSource = self
        //TODO: Set yourself as the delegate of the text field here:
        messageTextfield.delegate =  self
        
        
        //TODO: Set the tapGesture here:
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))

        messageTableView.addGestureRecognizer(tapGesture)
        //TODO: Register your MessageCell.xib file here:

        messageTableView.register(UINib(nibName: "MessageCell",bundle: nil), forCellReuseIdentifier: "customMessageCell")
        configureTableView()
        retrieveMsg()
        
        messageTableView.separatorStyle = .none
    }

    ///////////////////////////////////////////
    
    //MARK: - TableView DataSource Methods
    
    
    
    //TODO: Declare cellForRowAtIndexPath here:
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell",
                                                 for: indexPath) as! CustomMessageCell
        
      
        cell.messageBody.text =  msgArray[indexPath.row].msgBody
        cell.senderUsername.text = msgArray[indexPath.row].msgSender
        cell.avatarImageView.image = UIImage(named: "egg")
        
        
        if cell.senderUsername.text == Auth.auth().currentUser?.email {
            cell.avatarImageView.backgroundColor = UIColor.flatMint()
            cell.messageBackground.backgroundColor = UIColor.flatSkyBlue()
            
        }else {
            cell.avatarImageView.backgroundColor = UIColor.flatWatermelon()
            cell.messageBackground.backgroundColor = UIColor.flatGray()
            
        }
        return cell
    }
    
    //TODO: Declare numberOfRowsInSection here:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return msgArray.count
    }
    
    
    //TODO: Declare tableViewTapped here:
    @objc func tableViewTapped(){
        
        messageTextfield.endEditing(true)
    }
    
    
    
    //TODO: Declare configureTableView here:
    
    func configureTableView(){
        messageTableView.rowHeight = UITableView.automaticDimension
        messageTableView.estimatedRowHeight = 120.0
    }
    
    ///////////////////////////////////////////
    
    //MARK:- TextField Delegate Methods
    
    

    
    //TODO: Declare textFieldDidBeginEditing here:
    func textFieldDidBeginEditing(_ textField: UITextField) {
    
       
        
        
        UIView.animate(withDuration: 0.5){
            self.heightConstraint.constant = 308;
            self.view.layoutIfNeeded()
        }
    }
    
    //TODO: Declare textFieldDidEndEditing here:
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5){
            self.heightConstraint.constant = 50;
            self.view.layoutIfNeeded()
        }
    }

    
    ///////////////////////////////////////////
    
    
    //MARK: - Send & Recieve from Firebase
    
    
    
    
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        
        messageTextfield.endEditing(true)
        //TODO: Send the message to Firebase and save it in our database
        
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        
        let messageDb = Database.database().reference().child("Messages")
        
        let msgDict = ["Sender" : Auth.auth().currentUser?.email, "MessageBody" : messageTextfield.text! ]
        
        messageDb.childByAutoId().setValue(msgDict){
            (error, reference) in
            if error != nil {
                print(error as Any)
                
            }else {
                
                print("Message Was a Success")
                self.messageTextfield.isEnabled = true
                self.sendButton.isEnabled = true
                self.messageTextfield.text = ""
            }
        }
    }
    
    //TODO: Create the retrieveMessages method here:
    func retrieveMsg(){
        
        let messageDB = Database.database().reference().child("Messages")
        
        messageDB.observe(.childAdded){ (dataSnapshot) in
            let snapShotData = dataSnapshot.value as! Dictionary<String , String>
            let text = snapShotData["MessageBody"]!
            let sender = snapShotData["Sender"]!
            
            self.myMessage.msgBody = text
            self.myMessage.msgSender = sender
            
            self.msgArray.append(self.myMessage)
            self.configureTableView()
            self.messageTableView.reloadData()
            
            
            //print(text, sender as Any)
        }
    }
    

    
    
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        //TODO: Log out the user and send them back to WelcomeViewController
        do{
           try  Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
            
        }
        
        catch{
            print("Error")
        }
        
    }
    


}
