//
//  EditGroupView.swift
//  GroupMail
//
//  Created by muhammad azher on 13/07/2023.
//

import SwiftUI

struct GroupDetailsView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel: MailGroupViewModel
    var group: GroupData

    @State private var groupName: String = ""
    @State private var selectedEmailIds: [String] = []
    @State private var newEmail: String = ""

    var body: some View {
        VStack {
            TextField("Group Name", text: $groupName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .onAppear {
                    groupName = group.name
                    selectedEmailIds = group.emailIds
                }

            GroupListView(selectedEmails: $selectedEmailIds, viewModel: viewModel)
                .padding()

            TextField("New Email", text: $newEmail)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: {
                if viewModel.isValidEmail(newEmail), !selectedEmailIds.contains(where: {$0 == newEmail}) {
                    selectedEmailIds.append(newEmail)
                }

                if viewModel.validateEmails(selectedEmailIds) && !viewModel.isDuplicate(selectedEmailIds) {
                    let updatedGroup = GroupData(id: group.id, name: groupName, emailIds: selectedEmailIds)
                    viewModel.updateGroup(updatedGroup)
                    
                    presentationMode.wrappedValue.dismiss()
                }
                else {
                    viewModel.showError(message: "Invalid or duplicate email address")
                }
            }) {
                Text("Save Changes")
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

