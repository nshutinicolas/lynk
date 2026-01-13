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
	case negativeReview
	
	var subject: String {
		switch self {
		case .support: return String(localized: L10n.MailCompose.Model.Subject.support)
		case .feedback: return String(localized: L10n.MailCompose.Model.Subject.feedback)
		case .negativeReview: return String(localized: L10n.MailCompose.Model.Subject.negativeReview)
		}
	}
	var email: String {
		// I do not plan on having multiple emails for this project
		// So this works for now
		AppConstants.supportEmail
	}
	
	private enum TemplateKeys {
		static let appName = String(localized: L10n.MailCompose.Model.BodyTemplate.appName)
		static let deviceModel = String(localized: L10n.MailCompose.Model.BodyTemplate.deviceModel)
		static let appVersion = String(localized: L10n.MailCompose.Model.BodyTemplate.appVersion)
		static let appBuild = String(localized: L10n.MailCompose.Model.BodyTemplate.appBuild)
	}
	
	var bodyTemplate: String {
		let body = """
	\n\n\n\n
	\(TemplateKeys.appName): Lynk
	iOS: \(UIDevice.current.systemVersion)
	\(TemplateKeys.deviceModel): \(UIDevice.current.name)
	\(TemplateKeys.appVersion): \(Bundle.main.appVersion ?? "-")
	\(TemplateKeys.appBuild): \(Bundle.main.appBuild ?? "-")
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
