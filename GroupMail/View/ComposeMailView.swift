//
//  WriteMailView.swift
//  GroupMail
//
//  Created by muhammad azher on 13/07/2023.
//

import SwiftUI
import MessageUI

struct ComposeMailView: UIViewControllerRepresentable {
    let emailIds: [String]

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.setToRecipients(emailIds)
        return mailComposeVC
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {
    }

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true)
        }
    }
}
