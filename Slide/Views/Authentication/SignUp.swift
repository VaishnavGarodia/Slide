//
//  Authentication.swift
//  Slide
//
//  Created by Ethan Harianto on 12/16/22.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage
import Contacts

struct ContactInfo : Identifiable{
    var id = UUID()
    var firstName: String
    var lastName: String
    var phoneNumber: CNPhoneNumber?
}

func fetchingContacts() -> [ContactInfo]{
    var contacts = [ContactInfo]()
    let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
    let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
    do {
        try CNContactStore().enumerateContacts(with: request, usingBlock: { (contact, stopPointer) in
            contacts.append(ContactInfo(firstName: contact.givenName, lastName: contact.familyName, phoneNumber: contact.phoneNumbers.first?.value))
        })
    } catch let error {
        print("Failed", error)
    }
    contacts = contacts.sorted {
        $0.firstName < $1.firstName
    }
    print(contacts)
    return contacts
}

struct SignUp: View {
    @State public var email = ""
    @State public var phoneNumber = ""
    @State public var password = ""
    @State public var confirmpass = ""
    @State public var errormessage = ""
    @State private var emailSwitch = false
    @State private var username = ""
    @State private var contactList = [ContactInfo]()
    
    var body: some View {
        
        if emailSwitch {            
            VStack {
                Image("logo")
                    .padding(.all, -120.0)

                Text("Please confirm your email.")
            }
            .padding()
            .transition(.slide)
        } else {
            
            VStack {
                Image("logo")
                    .padding(.all, -120.0)
                
                Text(errormessage)
                
                TextField("Username", text: $username)
                    .padding(12.0)
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(Color("OppositeColor")))
                
                TextField("Email", text: $email)
                    .padding(12.0)
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(Color("OppositeColor")))
                
                TextField("Phone Number", text: $phoneNumber)
                    .padding(12.0)
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(Color("OppositeColor")))
                
                SecureField("Password", text: $password)
                    .padding(12.0)
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(Color("OppositeColor")))
                
                SecureField("Confirm Password", text: $confirmpass)
                    .padding(12.0)
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(Color("OppositeColor")))
                
                HStack {
                    Button(action: {signup() }) {
                        Text("Sign up")
                        Image(systemName: "mappin")
                    }
                }
                .padding(12.0)
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(Color.cyan))
                
                NavigationLink(destination: LogIn()) {
                    Text("Have an account?")
                        .foregroundColor(.gray)
                }
            }
            .padding()
        }
    }
    
    func signup() {
        if password != confirmpass {
            errormessage = ("Passwords were not spelt the same.")
        } else {
            Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                if error != nil {
                    errormessage = (error?.localizedDescription ?? "")
                } else if let result = result{
                    let changeRequest = result.user.createProfileChangeRequest()
                    changeRequest.displayName = username
                    changeRequest.commitChanges { (error) in}
                    
                    let contactsGranted = requestContactsPermission()
                    if contactsGranted {
                        contactList = fetchingContacts()
                    }
                    addUser()
                }
            }
        }
    }
    
    // See above comments
    func requestContactsPermission() -> Bool {
        let store = CNContactStore()
        var allowed = true
        store.requestAccess(for: .contacts) { granted, error in
            if granted {
                print("Contacts access granted")
                allowed = true
            } else {
                print("Contacts access denied")
                allowed = false
            }
        }
        return allowed
    }
    
    func addContact(contact: ContactInfo) {
        let contactRef = db.collection("Contacts").document(username + "-" + contact.id.uuidString)
        contactRef.getDocument {(document, error) in
            if let document = document, document.exists {
                errormessage = ("BIG ISSUE: Somehow username + id exists")
            } else {
                contactRef.setData([
                    "ContactUsername": username,
                    "firstName": contact.firstName,
                    "id": contact.id.uuidString,
                    "lastName": contact.lastName,
                    "phoneNumber": contact.phoneNumber?.stringValue
                ])
                { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    } else {
                        print("Document successfully written.")
                    }
                }
            }
        }
    }
    
    func addAllContacts() {
        print("Started saving contacts")
        for contact in contactList {
            addContact(contact: contact)
        }
    }
    
    func addUser() {
        let usersRef = db.collection("Users").document(username)
        usersRef.getDocument {(document, error) in
            if let document = document, document.exists {
                errormessage = ("Username taken.")
            } else {
                addAllContacts()
                var contactIdList = []
                for contact in contactList {
                    contactIdList.append(username + "-" + contact.id.uuidString)
                }
                usersRef.setData([
                    "Email": email,
                    "Password": password,
                    "Username": username,
                    "Phone": phoneNumber,
                    "Concats": contactIdList
                    ])
                { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    } else {
                        print("Document successfully written.")
                        emailSwitch.toggle()
                    }
                }
            }
        }		    
    }
}
            

struct SignUp_Previews: PreviewProvider {
    static var previews: some View {
        SignUp()
    }
}
