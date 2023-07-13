//
//  AddGroupView.swift
//  GroupMail
//
//  Created by muhammad azher on 13/07/2023.
//

import SwiftUI

struct NewGroupView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel: MailGroupViewModel
    
    @State private var groupName: String = ""
    @State private var selectedEmails: [String] = []
    @State private var newEmail: String = ""
    
    var body: some View {
        VStack {
            TextField("Group Name", text: $groupName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            GroupListView(selectedEmails: $selectedEmails, viewModel: viewModel)
                .padding()
            
            TextField("New Email", text: $newEmail)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: {
                let emailIds = viewModel.getEmailIds(selectedEmails: selectedEmails, newEmail: newEmail)
                if viewModel.validateEmails(emailIds) && !viewModel.isDuplicate(emailIds) {
                    viewModel.createGroup(name: groupName, emailIds: emailIds)
                    presentationMode.wrappedValue.dismiss()
                } else {
                    viewModel.showError(message: "Invalid or duplicate email address")
                }
            }) {
                Text("Save Group")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            .alert(isPresented: $viewModel.showError) {
                Alert(
                    title: Text("Error"),
                    message: Text(viewModel.errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}



struct GroupListView: View {
    @Binding var selectedEmails: [String]
    let viewModel: MailGroupViewModel
    
    var body: some View {
        List(viewModel.allEmails(), id: \.count) { email in
            Button(action: {
                if selectedEmails.contains(email) {
                    selectedEmails.removeAll(where: {$0 == email})
                } else {
                    selectedEmails.insert(email, at: 0)
                }
            }) {
                HStack {
                    Text(email)
                    Spacer()
                    if selectedEmails.contains(email) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
    }
}
