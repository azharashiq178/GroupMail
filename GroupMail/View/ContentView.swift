//
//  ContentView.swift
//  GroupMail
//
//  Created by muhammad azher on 13/07/2023.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = MailGroupViewModel(groupsRepository: SQLiteGroupsRepository())
    var body: some View {
        AllGroupsView(viewModel: viewModel)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
