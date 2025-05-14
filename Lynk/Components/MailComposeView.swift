//
//  MailComposeView.swift
//  Lynk
//
//  Created by Musoni nshuti Nicolas on 13/05/2025.
//

import MessageUI
import UIKit
import SwiftUI

typealias MailComposeViewCallback = (Result<MFMailComposeResult, Error>) -> Void

enum MailComposeModel: Equatable {
	case support
	case feedback
	
	var subject: String {
		switch self {
		case .support: return "Lynk Support Request"
		case .feedback: return "Lynk App Feedback"
		}
	}
	var email: String {
		// I do not plan on having multiple emails for this project
		// So this works for now
		AppConstants.supportEmail
	}
	
	var bodyTemplate: String {
		let body = """
	\n\n\n\n
	Application Name: Lynk
	iOS: \(UIDevice.current.systemVersion)
	Device Model: \(UIDevice.current.name)
	Appp Version: \(Bundle.main.appVersion ?? "-")
	App Build: \(Bundle.main.appBuild ?? "-")
	--------------------------------------
	"""
		return body
	}
	
	static let canSendMail: Bool = {
		MFMailComposeViewController.canSendMail()
	}()
	
	func sendEmail(openURL: OpenURLAction) {
		let urlString = "mailto:\(email)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")&body=\(bodyTemplate.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")"
		guard let url = URL(string: urlString) else { return }
		openURL(url)
	}
}

struct MailComposeView: UIViewControllerRepresentable {
	private let email: String
	private let subject: String
	private let message: String
	private let callback: MailComposeViewCallback?
	
	init(_ emailComposer: MailComposeModel, callback: MailComposeViewCallback? = nil) {
		self.email = emailComposer.email
		self.subject = emailComposer.subject
		self.message = emailComposer.bodyTemplate
		self.callback = callback
	}
	
	func makeUIViewController(context: Context) -> UIViewController {
		let mailComposer = MFMailComposeViewController()
		mailComposer.navigationBar.prefersLargeTitles = false
		mailComposer.mailComposeDelegate = context.coordinator
		
		mailComposer.setToRecipients([email])
		mailComposer.setSubject(subject)
		mailComposer.setMessageBody(message, isHTML: false)
		
		return mailComposer
	}
	
	func updateUIViewController(_ uiViewController: UIViewController, context: Context) { }
	
	func makeCoordinator() -> Coordinator { Coordinator(callback: callback) }
	
	class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
		private let callback: MailComposeViewCallback?
		
		init(callback: MailComposeViewCallback?) {
			self.callback = callback
		}
		
		func mailComposeController(_ controller: MFMailComposeViewController,
								   didFinishWith result: MFMailComposeResult,
								   error: Error?) {
			if let error = error {
				callback?(.failure(error))
			} else {
				callback?(.success(result))
			}
			controller.dismiss(animated: true)
		}
	}
}
