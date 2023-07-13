//
//  GroupsListView.swift
//  GroupMail
//
//  Created by muhammad azher on 13/07/2023.
//

import SwiftUI
import MessageUI

struct AllGroupsView: View {
    @ObservedObject var viewModel: MailGroupViewModel
    
    var body: some View {
        NavigationView {
            List(viewModel.groups, id: \.id) { group in
                Section {
                    ForEach((0..<group.emailIds.count), id: \.self) { index in
                        Button {
                            viewModel.selectGroup(group)
                            viewModel.showDetailsView = true
                        } label: {
                            Text("\(group.emailIds[index])")
                        }
                    }
                } header: {
                    GroupHeaderView(group: group, viewModel: viewModel)
                }
            }
            .listStyle(.insetGrouped)
            .navigationBarTitle("Groups")
            .navigationBarItems(trailing: NavigationLink(destination: NewGroupView(viewModel: viewModel)) {
                Image(systemName: "plus")
            })
        }
        .onAppear {
            viewModel.fetchGroups()
        }
        .sheet(isPresented: $viewModel.showDetailsView) {
            if let group = self.viewModel.selectedGroup {
                GroupDetailsView(viewModel: viewModel, group: group)
            }
        }
        .sheet(isPresented: $viewModel.showMailComposer) {
            if let group = self.viewModel.selectedGroup {
                ComposeMailView(emailIds: group.emailIds)
            }
        }
        .alert(isPresented: $viewModel.showError) {
            Alert(
                title: Text("Error"),
                message: Text(viewModel.errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

struct GroupHeaderView: View {
    let group: GroupData
    let viewModel: MailGroupViewModel
    
    var body: some View {
        HStack {
            Text(group.name)
            Spacer()
            MailComposerButton(viewModel: viewModel, group: group)
            EditGroupButton(viewModel: viewModel, group: group)
        }
    }
}

struct MailComposerButton: View {
    let viewModel: MailGroupViewModel
    let group: GroupData
    
    var body: some View {
        Button(action: {
            viewModel.selectGroup(group)
            if MFMailComposeViewController.canSendMail() {
                viewModel.showMailComposer = true
            } else {
                viewModel.showError(message: "Mail Composer Not Found")
            }
        }) {
            Image(systemName: "square.and.pencil")
        }
    }
}

struct EditGroupButton: View {
    let viewModel: MailGroupViewModel
    let group: GroupData
    
    var body: some View {
        Button(action: {
            viewModel.selectGroup(group)
            viewModel.showDetailsView = true
        }) {
            Image(systemName: "pencil")
        }
    }
}
