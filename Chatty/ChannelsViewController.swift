//
//  ChatsViewController.swift
//  Chatty
//
//  Created by Relorie on 11/23/17.
//  Copyright © 2017 Relorie. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

fileprivate enum Section: Int {
    case createNewChannelSection = 0
    case currentChannelsSection
}

class ChannelsViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var channelsTableView: UITableView!
    
    // MARK: Vars
    
    var ref = Database.database().reference()
    var channelsRef = Database.database().reference().child("channels")
    private var channelRefHandle: DatabaseHandle?
    var username: String?
    var newChannelTextField: UITextField?
    private var channels: [Channel] = []
    
    // MARK: View lifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        channelsTableView.delegate = self
        channelsTableView.dataSource = self
        configureNavController()
        if username == nil {
            loadUsername()
        }
        observeChannels()
    }
    
    // MARK: Actions
    
    @IBAction func createChannelPressed(_ sender: Any) {
        if let name = newChannelTextField?.text {
            let newChannelRef = channelsRef.childByAutoId()
            let channelItem = [
                "name": name
            ]
            newChannelRef.setValue(channelItem)
        }
    }
    
    // MARK: Methods
    
    private func configureNavController() {
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.topItem?.title = "Channels"
        let logOutButton = UIBarButtonItem(title: "Log Out",
                                         style: UIBarButtonItemStyle.done,
                                         target: self,
                                         action: #selector(logOutAction))
        navigationItem.setLeftBarButton(logOutButton, animated: false)
        logOutButton.tintColor = .red
    }
    
    @objc func logOutAction() {
        do {
            try Auth.auth().signOut()
        } catch let signOutError {
            print(signOutError)
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let signInVC = storyboard.instantiateViewController(withIdentifier: "SignInViewController")
        self.present(signInVC, animated: true, completion: nil)
    }
    
    private func loadUsername() {
        let curUserId = Auth.auth().currentUser!.uid
        ref.child("users").child(curUserId).observeSingleEvent(of: DataEventType.value) { (snapshot) in
            if let userDetails = snapshot.value as? NSDictionary {
                self.username = userDetails["name"] as? String
            }
        }
    }
    
    private func observeChannels() {
        channelRefHandle = channelsRef.observe(.childAdded, with: { (snapshot) -> Void in
            let channelData = snapshot.value as! NSDictionary
            let id = snapshot.key
            if let name = channelData["name"] as! String!, name.characters.count > 0 {
                self.channels.append(Channel(name: name, id: id))
                self.channelsTableView.reloadData()
            } else {
                print("Error! Could not decode channel data")
            }
        })
        
    }
    
    // MARK: Initializers
    
    deinit {
        if let refHandle = channelRefHandle {
            channelsRef.removeObserver(withHandle: refHandle)
        }
    }
    
}

extension ChannelsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == Section.currentChannelsSection.rawValue {
            let channel = channels[indexPath.row]
            let chatVc = ChatViewController()
            chatVc.channel = channel
            chatVc.channelRef = channelsRef.child(channel.id)
            chatVc.username = username
            let navController = UINavigationController(rootViewController: chatVc)
            present(navController, animated: true, completion: nil)
        }
    }
}

extension ChannelsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let currentSection: Section = Section(rawValue: section) {
            switch currentSection {
            case .createNewChannelSection:
                return 1
            case .currentChannelsSection:
                return channels.count
            }
        } else {
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = indexPath.section == Section.createNewChannelSection.rawValue ? "NewChannel" : "ExistingChannel"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        
        if indexPath.section == Section.createNewChannelSection.rawValue {
            if let createNewChannelCell = cell as? CreateChannelCell {
                newChannelTextField = createNewChannelCell.newChannelNameField
            }
        } else if indexPath.section == Section.currentChannelsSection.rawValue {
            cell.textLabel?.text = channels[indexPath.row].name
        }
        
        return cell
    }
    
    
}
