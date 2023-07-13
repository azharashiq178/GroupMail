//
//  MailGroupViewModel.swift
//  GroupMail
//
//  Created by muhammad azher on 13/07/2023.
//

import SwiftUI
import SQLite

// MARK: - Enum for the Group Result which will either return a group or an error
enum GroupResult {
    case success(GroupData)
    case failure(Error)
}

protocol GroupsRepository {
    func fetchGroups() -> [GroupData]
    func createGroup(name: String, emailIds: [String]) -> GroupResult
    func updateGroup(_ group: GroupData) -> GroupResult
    func getAllEmails() -> [String]
    func isValidEmail(_ email: String) -> Bool
    func validateEmails(_ emailIds: [String]) -> Bool
    func isDuplicate(_ emailIds: [String]) -> Bool
    func getEmailIds(selectedEmails: [String], newEmail: String) -> [String]
}


class MailGroupViewModel: ObservableObject {
    @Published var groups: [GroupData] = []
    @Published var selectedGroup: GroupData?
    @Published var showDetailsView = false
    @Published var showMailComposer = false
    @Published var errorMessage = ""
    @Published var showError = false
    
    private let groupsRepository: GroupsRepository
    
    init(groupsRepository: GroupsRepository) {
        self.groupsRepository = groupsRepository
    }
    
    // MARK: - Function to fetch groups from the repository
    func fetchGroups() {
        groups = groupsRepository.fetchGroups()
    }
    
    private func checkIfUserHasEnteredEmptyInfo(name: String, emailIds: [String]) -> Bool {
        if name.isEmpty {
            showError(message: "Group Name can't be empty")
            return false
        }
        if emailIds.count == 0 {
            showError(message: "There should be atleast one email id for the group.")
            return false
        }
        return true
    }
    
    // MARK: - Function to create a new group
    func createGroup(name: String, emailIds: [String]) {
        if !checkIfUserHasEnteredEmptyInfo(name: name, emailIds: emailIds) {
            return
        }
        let result = groupsRepository.createGroup(name: name, emailIds: emailIds)
        
        switch result {
        case .success(let newGroup):
            groups.append(newGroup)
        case .failure(let error):
            showError(message: error.localizedDescription)
        }
    }
    
    // MARK: - Function to update an existing group
    func updateGroup(_ group: GroupData) {
        if !checkIfUserHasEnteredEmptyInfo(name: group.name, emailIds: group.emailIds) {
            return
        }
        let result = groupsRepository.updateGroup(group)
        
        switch result {
        case .success:
            if let index = groups.firstIndex(where: { $0.id == group.id }) {
                groups[index] = group
            }
        case .failure(let error):
            showError(message: error.localizedDescription)
        }
    }
    
    // MARK: - Function to select a group for editing
    func selectGroup(_ group: GroupData) {
        selectedGroup = group
    }
    
    // MARK: - Function to deselect a group
    func deselectGroup() {
        selectedGroup = nil
    }
    // MARK: - Function to get all emails available in DB
    func allEmails() -> [String] {
        return groupsRepository.getAllEmails()
    }
    // MARK: - Check if an email is valid or not.
    func isValidEmail(_ email: String) -> Bool {
        return groupsRepository.isValidEmail(email)
    }
    // MARK: - Will validate if provided emails are valid or not
    func validateEmails(_ emailIds: [String]) -> Bool {
        return groupsRepository.validateEmails(emailIds)
    }
    // MARK: - Will check if emails have any duplicate email
    func isDuplicate(_ emailIds: [String]) -> Bool {
        return groupsRepository.isDuplicate(emailIds)
    }
    
    // MARK: - It will add new email in selected Emails if its not present in it and will return the new array.
    func getEmailIds(selectedEmails: [String], newEmail: String) -> [String] {
        return groupsRepository.getEmailIds(selectedEmails: selectedEmails, newEmail: newEmail)
    }
    // MARK: - Function will show error message
    func showError(message: String) {
        errorMessage = message
        showError = true
    }
}


class SQLiteGroupsRepository: GroupsRepository {
    private let groupsTable = Table("groups")
    private let idColumn = Expression<Int>("id")
    private let nameColumn = Expression<String>("name")
    private let emailIdsColumn = Expression<String>("emailIds")
    
    private var connection: Connection?
    
    init() {
        if let connection = getDBConnection() {
            self.connection = connection
            createTable(in: self.connection!)
        }
    }
    
    // MARK: -  Fetch groups from the SQLite database
    func fetchGroups() -> [GroupData] {
        guard let connection = connection else {
            return []
        }
        let query = groupsTable.select(idColumn, nameColumn, emailIdsColumn)
        guard let groups = try? connection.prepare(query) else { return [] }
        var fetchedGroups: [GroupData] = []

        for group in groups {
            let emailIdsArray = group[emailIdsColumn].split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) }

            let fetchedGroup = GroupData(id: group[idColumn], name: group[nameColumn], emailIds: emailIdsArray)
            fetchedGroups.append(fetchedGroup)
        }
        return fetchedGroups
    }
    
    // MARK: -  Create a new Group in DB
    func createGroup(name: String, emailIds: [String]) -> GroupResult {
        
        let validEmails = emailIds.filter { isValidEmail($0) }
        let uniqueEmails = Array(Set(validEmails))

        guard uniqueEmails.count == validEmails.count else {
            print("Error: Duplicate emails found.")
            return .failure(NSError(domain: "RepositoryError", code: 0))
        }

        let emailIdsString = emailIds.joined(separator: ",")
        guard let conenction = connection else { return .failure(NSError(domain: "RepositoryError", code: 0)) }
        let insert = groupsTable.insert(nameColumn <- name, emailIdsColumn <- emailIdsString)
        guard let insertedId = try? conenction.run(insert) else {
            print("Error while running query")
            return .failure(NSError(domain: "RepositoryError", code: 0))
        }

        let newGroup = GroupData(id: Int(insertedId), name: name, emailIds: emailIds)
        return .success(newGroup)
    }
    
    // MARK: - Update the group in the SQLite database
    func updateGroup(_ group: GroupData) -> GroupResult {
        
        let updatedEmailIdsString = group.emailIds.joined(separator: ",")
        guard let connection = connection else { return .failure(NSError(domain: "RepositoryError", code: 0)) }
        let targetGroup = groupsTable.filter(idColumn == group.id)
        let update = targetGroup.update(nameColumn <- group.name, emailIdsColumn <- updatedEmailIdsString)
        guard let result = try? connection.run(update), result > 0 else { return .failure(NSError(domain: "RepositoryError", code: 0)) }
        return .success(group)
    }
    
    func getAllEmails() -> [String] {
        guard let connection = connection else { return [] }
        let query = groupsTable.select(emailIdsColumn)
        guard let emails = (try? connection.prepare(query).compactMap { $0[emailIdsColumn] }) else { return [] }
        
        return Array(Set(Array(emails.joined(separator: ",").split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) })))
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    func validateEmails(_ emailIds: [String]) -> Bool {
        for email in emailIds {
            if !isValidEmail(email) {
                return false
            }
        }
        return true
    }
    
    func isDuplicate(_ emailIds: [String]) -> Bool {
        let uniqueEmails = Set(emailIds)
        return emailIds.count != uniqueEmails.count
    }
    
    func getEmailIds(selectedEmails: [String], newEmail: String) -> [String] {
        var emailIds = Array(selectedEmails)
        if !newEmail.isEmpty {
            emailIds.append(newEmail)
        }
        return emailIds
    }
    
    private func getDBConnection() -> Connection? {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        guard let dbConnection = try? Connection("\(url.absoluteString)/db.sqlite3") else {
            return nil
        }
        return dbConnection
    }
    // MARK: -  Will create new table in DB
    private func createTable(in connection: Connection) {
        do {
            try connection.run(groupsTable.create(ifNotExists: true) { table in
                table.column(idColumn, primaryKey: true)
                table.column(nameColumn)
                table.column(emailIdsColumn)
            })
        }
        catch {
            print("Error while creating table")
        }
        
    }
}
