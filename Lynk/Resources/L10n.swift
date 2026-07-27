//
//  L10n.swift
//  Lynk
//
//  Created by Musoni nshuti Nicolas on 13/01/2026.
//

import Foundation

struct L10n {
	
	init() { }
}

extension L10n {
	enum AuthView {
		static let welcomeTitle = LocalizedStringResource(stringLiteral: "AUTH_VIEW.WELCOME_TITLE")
		enum Button {
			static let authenticateTitle = LocalizedStringResource(stringLiteral: "AUTH_VIEW.BUTTON.AUTHENTICATE_TITLE")
		}
	}
	enum AppView {
		enum SearchTextField {
			static let placeholder = LocalizedStringResource(stringLiteral: "APP_VIEW.SEARCH_TEXT_FIELD.PLACEHOLDER")
		}
		
		enum Alert {
			enum Notification {
				static let title = LocalizedStringResource(stringLiteral: "APP_VIEW.ALERT.NOTIFICATION.TITLE")
				enum EnableNotification {
					static let title = LocalizedStringResource(stringLiteral: "APP_VIEW.ALERT.NOTIFICATION.ENABLE_NOTIFICATION.TITLE")
					static let message = LocalizedStringResource(stringLiteral: "APP_VIEW.ALERT.NOTIFICATION.ENABLE_NOTIFICATION.MESSAGE")
				}
			}
			
			enum Feedback {
				static let title = LocalizedStringResource(stringLiteral: "APP_VIEW.ALERT.FEEDBACK.TITLE")
				enum Button {
					static let yesTitle = LocalizedStringResource(stringLiteral: "APP_VIEW.ALERT.FEEDBACK.BUTTON.YES_TITLE")
					static let noTitle = LocalizedStringResource(stringLiteral: "APP_VIEW.ALERT.FEEDBACK.BUTTON.NO_TITLE")
				}
				static let message = LocalizedStringResource(stringLiteral: "APP_VIEW.ALERT.FEEDBACK.MESSAGE")
			}
			
			enum CopyToClipboard {
				static let text = LocalizedStringResource(stringLiteral: "APP_VIEW.ALERT.COPY_TO_CLIPBOARD.TEXT")
			}
			
			enum SetReminder {
				static let text = LocalizedStringResource(stringLiteral: "APP_VIEW.ALERT.SET_REMINDER.TEXT")
			}
		}
		
		enum EmptyView {
			static let noFoundText = LocalizedStringResource(stringLiteral: "APP_VIEW.EMPTY_VIEW.NO_FOUND_TEXT")
			enum Button {
				static let leanHowText = LocalizedStringResource(stringLiteral: "APP_VIEW.EMPTY_VIEW.BUTTON.LEAN_HOW_TEXT")
			}
		}
		
		enum Sorting {
			static let scheduled = LocalizedStringResource(stringLiteral: "APP_VIEW.SORTING.SCHEDULED")
			static let all = LocalizedStringResource(stringLiteral: "APP_VIEW.SORTING.ALL")
			static let text = LocalizedStringResource(stringLiteral: "APP_VIEW.SORTING.TEXT")
			static let websites = LocalizedStringResource(stringLiteral: "APP_VIEW.SORTING.WEBSITES")
		}
		
		enum ReminderSelector {
			static let emptySelectionText = LocalizedStringResource(stringLiteral: "APP_VIEW.REMINDER_SELECTOR.EMPTY_SELECTION_TEXT")
			static let setReminderButtonText = LocalizedStringResource(stringLiteral: "APP_VIEW.REMINDER_SELECTOR.SET_REMINDER_BUTTON_TEXT")
		}
	}
	
	enum MailCompose {
		enum Model {
			enum Subject {
				static let support = LocalizedStringResource(stringLiteral: "MAIL_COMPOSE.MODEL.SUBJECT.SUPPORT")
				static let feedback = LocalizedStringResource(stringLiteral: "MAIL_COMPOSE.MODEL.SUBJECT.FEEDBACK")
				static let negativeReview = LocalizedStringResource(stringLiteral: "MAIL_COMPOSE.MODEL.SUBJECT.NEGATIVE_REVIEW")
			}
			enum BodyTemplate {
				static let appName = LocalizedStringResource(stringLiteral: "MAIL_COMPOSE.MODEL.BODY_TEMPLATE.APP_NAME")
				static let deviceModel = LocalizedStringResource(stringLiteral: "MAIL_COMPOSE.MODEL.BODY_TEMPLATE.DEVICE_MODEL")
				static let appVersion = LocalizedStringResource(stringLiteral: "MAIL_COMPOSE.MODEL.BODY_TEMPLATE.APP_VERSION")
				static let appBuild = LocalizedStringResource(stringLiteral: "MAIL_COMPOSE.MODEL.BODY_TEMPLATE.APP_BUILD")
			}
		}
	}
	
	enum Welcome {
		enum Onboarding {
			enum Intro {
				static let title = LocalizedStringResource(stringLiteral: "WELCOME.ONBOARDING.INTRO.TITLE")
				static let description = LocalizedStringResource(stringLiteral: "WELCOME.ONBOARDING.INTRO.DESCRIPTION")
				
				enum Button {
					static let title = LocalizedStringResource(stringLiteral: "WELCOME.ONBOARDING.INTRO.BUTTON.TITLE")
				}
			}
			
			enum Notification {
				static let title = LocalizedStringResource(stringLiteral: "WELCOME.ONBOARDING.NOTIFICATION.TITLE")
				static let description = LocalizedStringResource(stringLiteral: "WELCOME.ONBOARDING.NOTIFICATION.DESCRIPTION")
				static let infoText = LocalizedStringResource(stringLiteral: "WELCOME.ONBOARDING.NOTIFICATION.INFO_TEXT")
				
				enum Button {
					static let enableTitle = LocalizedStringResource(stringLiteral: "WELCOME.ONBOARDING.NOTIFICATION.BUTTON.ENABLE_TITLE")
					static let skipTitle = LocalizedStringResource(stringLiteral: "WELCOME.ONBOARDING.NOTIFICATION.BUTTON.SKIP_TITLE")
				}
			}
			
			enum TwoWaysToSave {
				static let title = LocalizedStringResource(stringLiteral: "WELCOME.ONBOARDING.TWO_WAYS_TO_SAVE.TITLE")
				static let description = LocalizedStringResource(stringLiteral: "WELCOME.ONBOARDING.TWO_WAYS_TO_SAVE.DESCRIPTION")
				
				enum SaveMethod {
					static let shareSheetTitle = LocalizedStringResource(stringLiteral: "WELCOME.ONBOARDING.TWO_WAYS_TO_SAVE.SAVE_METHOD.SHARE_SHEET_TITLE")
					static let shareSheetDecription = LocalizedStringResource(stringLiteral: "WELCOME.ONBOARDING.TWO_WAYS_TO_SAVE.SAVE_METHOD.SHARE_SHEET_DECRIPTION")
					static let manualTitle = LocalizedStringResource(stringLiteral: "WELCOME.ONBOARDING.TWO_WAYS_TO_SAVE.SAVE_METHOD.MANUAL_TITLE")
					static let manualDescription = LocalizedStringResource(stringLiteral: "WELCOME.ONBOARDING.TWO_WAYS_TO_SAVE.SAVE_METHOD.MANUAL_DECRIPTION")
				}
				static let icloudSync = LocalizedStringResource(stringLiteral: "WELCOME.ONBOARDING.TWO_WAYS_TO_SAVE.ICLOUD_SYNC")
			}
			
			enum CompleteOnboarding {
				static let title = LocalizedStringResource(stringLiteral: "WELCOME.ONBOARDING.COMPLETE_ONBOARDING.TITLE")
				static let description = LocalizedStringResource(stringLiteral: "WELCOME.ONBOARDING.COMPLETE_ONBOARDING.DESCRIPTION")
			}
		}
	}
	
	enum SettingsView {
		static let title = LocalizedStringResource(stringLiteral: "SETTINGS.TITLE")
		enum Section {
			enum Appearance {
				static let title = LocalizedStringResource(stringLiteral: "SETTINGS.SECTION.APPEARANCE.TITLE")
				static let displayMode = LocalizedStringResource(stringLiteral: "SETTINGS.SECTION.APPEARANCE.DISPLAY_MODE")
			}
			
			enum Data {
				static let title = LocalizedStringResource(stringLiteral: "SETTINGS.SECTION.DATA.TITLE")
				static let icloudSync = LocalizedStringResource(stringLiteral: "SETTINGS.SECTION.DATA.ICLOUD_SYNC")
				static let icloudSyncDescription = LocalizedStringResource(stringLiteral: "SETTINGS.SECTION.DATA.ICLOUD_SYNC_DESCRIPTION")
				static let biometricLockout = LocalizedStringResource(stringLiteral: "SETTINGS.SECTION.DATA.BIOMETRIC_LOCKOUT")
				static let biometricLockoutDescription = LocalizedStringResource(stringLiteral: "SETTINGS.SECTION.DATA.BIOMETRIC_LOCKOUT_DESCRIPTION")
				static let deleteAllData = LocalizedStringResource(stringLiteral: "SETTINGS.SECTION.DATA.DELETE_ALL_DATA")
				static let deleteAllDataDescription = LocalizedStringResource(stringLiteral: "SETTINGS.SECTION.DATA.DELETE_ALL_DATA_DESCRIPTION")
			}
			
			enum App {
				static let title = LocalizedStringResource(stringLiteral: "SETTINGS.SECTION.APP.TITLE")
				static let reminderNotifications = LocalizedStringResource(stringLiteral: "SETTINGS.SECTION.APP.REMINDER_NOTIFICATIONS")
				static let reminderNotificationsDescription = LocalizedStringResource(stringLiteral: "SETTINGS.SECTION.APP.REMINDER_NOTIFICATIONS_DESCRIPTION")
				static let showPreview = LocalizedStringResource(stringLiteral: "SETTINGS.SECTION.APP.SHOW_PREVIEW")
				static let showPreviewDescription = LocalizedStringResource(stringLiteral: "SETTINGS.SECTION.APP.SHOW_PREVIEW_DESCRIPTION")
				static let rateApp = LocalizedStringResource(stringLiteral: "SETTINGS.SECTION.APP.RATE_APP")
				static let rateAppDescription = LocalizedStringResource(stringLiteral: "SETTINGS.SECTION.APP.RATE_APP_DESCRIPTION")
				static let shareApp = LocalizedStringResource(stringLiteral: "SETTINGS.SECTION.APP.SHARE_APP")
				static let shareAppDescription = LocalizedStringResource(stringLiteral: "SETTINGS.SECTION.APP.SHARE_APP_DESCRIPTION")
				static let leaveFeedback = LocalizedStringResource(stringLiteral: "SETTINGS.SECTION.APP.LEAVE_FEEDBACK")
				static let leaveFeedbackDescription = LocalizedStringResource(stringLiteral: "SETTINGS.SECTION.APP.LEAVE_FEEDBACK_DESCRIPTION")
			}
			
			enum Legal {
				static let title = LocalizedStringResource(stringLiteral: "SETTINGS.SECTION.LEGAL.TITLE")
				static let privacyPolicy = LocalizedStringResource(stringLiteral: "SETTINGS.SECTION.LEGAL.PRIVACY_POLICY")
				static let termsAndConditions = LocalizedStringResource(stringLiteral: "SETTINGS.SECTION.LEGAL.TERMS_AND_CONDITIONS")
			}
			
			enum HelpAndSupport {
				static let title = LocalizedStringResource(stringLiteral: "SETTINGS.SECTION.HELP_AND_SUPPORT.TITLE")
				static let about = LocalizedStringResource(stringLiteral: "SETTINGS.SECTION.HELP_AND_SUPPORT.ABOUT")
				static let aboutDescription = LocalizedStringResource(stringLiteral: "SETTINGS.SECTION.HELP_AND_SUPPORT.ABOUT_DESCRIPTION")
				static let contactSupport = LocalizedStringResource(stringLiteral: "SETTINGS.SECTION.HELP_AND_SUPPORT.CONTACT_SUPPORT")
				static let contactSupportDescription = LocalizedStringResource(stringLiteral: "SETTINGS.SECTION.HELP_AND_SUPPORT.CONTACT_SUPPORT_DESCRIPTION")
				static let howToUse = LocalizedStringResource(stringLiteral: "SETTINGS.SECTION.HELP_AND_SUPPORT.HOW_TO_USE")
				static let howToUseDescription = LocalizedStringResource(stringLiteral: "SETTINGS.SECTION.HELP_AND_SUPPORT.HOW_TO_USE_DESCRIPTION")
			}
		}
		static func appVersion(appVersion: String, appBuild: String) -> String {
			let resource = NSLocalizedString("SETTINGS.SECTION.VERSION.APP_VERSION", comment: "App version")
			return String(format: resource, appVersion, appBuild)
		}
		
		enum Alert {
			enum About {
				static let bodyMessage = LocalizedStringResource(stringLiteral: "SETTINGS.ALERT.ABOUT.BODY_MESSAGE")
				enum Button {
					static let viewOnGithub = LocalizedStringResource(stringLiteral: "SETTINGS.ALERT.ABOUT.BUTTON.VIEW_ON_GITHUB")
				}
			}
			
			enum DeleteAllData {
				static let title = LocalizedStringResource(stringLiteral: "SETTINGS.ALERT.DELETE_ALL_DATA.TITLE")
				static let message = LocalizedStringResource(stringLiteral: "SETTINGS.ALERT.DELETE_ALL_DATA.MESSAGE")
			}
			
			enum NotificationError {
				static let title = LocalizedStringResource(stringLiteral: "SETTINGS.ALERT.NOTIFICATION_ERROR.TITLE")
				static let message = LocalizedStringResource(stringLiteral: "SETTINGS.ALERT.NOTIFICATION_ERROR.MESSAGE")
			}
		}
	}
	
	enum ReminderView {
		enum Button {
			static let date = LocalizedStringResource(stringLiteral: "REMINDER_VIEW.BUTTON.DATE")
			static let time = LocalizedStringResource(stringLiteral: "REMINDER_VIEW.BUTTON.TIME")
		}
	}
	
	enum ExtensionShareView {
		enum Button {
			static let bookMarkTitle = LocalizedStringResource(stringLiteral: "EXTENSION_SHARE_VIEW.BUTTON.BOOKMARK_TITLE")
			static let setReminder = LocalizedStringResource(stringLiteral: "EXTENSION_SHARE_VIEW.BUTTON.SET_REMINDER")
		}
		
		enum TextField {
			static let placeholder = LocalizedStringResource(stringLiteral: "EXTENSION_SHARE_VIEW.TEXT_FIELD.PLACEHOLDER")
		}
	}
	
	enum AddLinkManuallyView {
		static let title = LocalizedStringResource(stringLiteral: "ADD_LINK_MANUALLY_VIEW.TITLE")
		
		enum TextField {
			static let linkTitle = LocalizedStringResource(stringLiteral: "ADD_LINK_MANUALLY_VIEW.TEXT_FIELD.LYNK_TITLE")
			static let linkPlaceholder = LocalizedStringResource(stringLiteral: "ADD_LINK_MANUALLY_VIEW.TEXT_FIELD.LINK_PLACEHOLDER")
			static let linkFieldError = LocalizedStringResource(stringLiteral: "ADD_LINK_MANUALLY_VIEW.TEXT_FIELD.LINK_FIELD_ERROR")
			static let titleText = LocalizedStringResource(stringLiteral: "ADD_LINK_MANUALLY_VIEW.TEXT_FIELD.TITLE_TEXT")
			static let titleTextPlaceholder = LocalizedStringResource(stringLiteral: "ADD_LINK_MANUALLY_VIEW.TEXT_FIELD.TITLE_TEXT_PLACEHOLDER")
			static let titleTextError = LocalizedStringResource(stringLiteral: "ADD_LINK_MANUALLY_VIEW.TEXT_FIELD.TITLE_TEXT_ERROR")
		}
		
		static let setReminderText = LocalizedStringResource(stringLiteral: "ADD_LINK_MANUALLY_VIEW.SET_REMINDER_TEXT")
		
		enum Button {
			static let title = LocalizedStringResource(stringLiteral: "ADD_LINK_MANUALLY_VIEW.BUTTON.TITLE")
		}
	}
	
	enum Button {
		static let edit = LocalizedStringResource(stringLiteral: "BUTTON.EDIT")
		static let delete = LocalizedStringResource(stringLiteral: "BUTTON.DELETE")
		static let cancel = LocalizedStringResource(stringLiteral: "BUTTON.CANCEL")
		static let settings = LocalizedStringResource(stringLiteral: "BUTTON.SETTINGS")
		static let copy = LocalizedStringResource(stringLiteral: "BUTTON.COPY")
		static let dismiss = LocalizedStringResource(stringLiteral: "BUTTON.DISMISS")
		static let confirm = LocalizedStringResource(stringLiteral: "BUTTON.CONFIRM")
		static let open = LocalizedStringResource(stringLiteral: "BUTTON.OPEN")
		static let notNow = LocalizedStringResource(stringLiteral: "BUTTON.NOT_NOW")
		static let save = LocalizedStringResource(stringLiteral: "BUTTON.SAVE")
		static let continueButton = LocalizedStringResource(stringLiteral: "BUTTON.CONTINUE")
		static let enable = LocalizedStringResource(stringLiteral: "BUTTON.ENABLE")
	}
	
	static let appTitle = LocalizedStringResource(stringLiteral: "APP_TITLE")
	
	// Mac
	enum MacHomeView {
		enum SearchTextField {
			static let placeholder = LocalizedStringResource(stringLiteral: "MAC_HOME_VIEW.SEARCH_TEXT_FIELD.PLACEHOLDER")
		}
		
		enum ArticleViewer {
			static let whatArticleToReadTitle = LocalizedStringResource(stringLiteral: "MAC_HOME_VIEW.ARTICLE_VIEWER.WHAT_ARTICLE_TO_READ_TITLE")
		}
		
		enum Header {
			static let settingsHoverText = LocalizedStringResource(stringLiteral: "MAC_HOME_VIEW.HEADER.SETTINGS_HOVER_TEXT")
			static let addLinkManuallyHoverText = LocalizedStringResource(stringLiteral: "MAC_HOME_VIEW.HEADER.ADD_LINK_MANUALLY_HOVER_TEXT")
			static let refreshContentHoverText = LocalizedStringResource(stringLiteral: "MAC_HOME_VIEW.HEADER.REFRESH_CONTENT_HOVER_TEXT")
		}
		
		enum Toolbar {
			static let copyToClipboardHoverText = LocalizedStringResource(stringLiteral: "MAC_HOME_VIEW.TOOLBAR.COPY_TO_CLIPBOARD_HOVER_TEXT")
			static let openInExternalBrowserHoverText = LocalizedStringResource(stringLiteral: "MAC_HOME_VIEW.TOOLBAR.OPEN_IN_EXTERNAL_BROWSER_HOVER_TEXT")
		}
	}
	
	enum ShareSheetHelpView {
		static let title = LocalizedStringResource(stringLiteral: "SHARE_SHEET_HELP_VIEW.TITLE")
		static let message = LocalizedStringResource(stringLiteral: "SHARE_SHEET_HELP_VIEW.MESSAGE")
		
		enum Explainer {
			enum Step1 {
				static let title = LocalizedStringResource(stringLiteral: "SHARE_SHEET_HELP_VIEW.EXPLANER.STEP_1.TITLE")
				static let description = LocalizedStringResource(stringLiteral: "SHARE_SHEET_HELP_VIEW.EXPLANER.STEP_1.DESCRIPTION")
				static let safariRef = LocalizedStringResource(stringLiteral: "SHARE_SHEET_HELP_VIEW.EXPLANER.STEP_1.SAFARI_REF")
			}
			
			enum Step2 {
				static let title = LocalizedStringResource(stringLiteral: "SHARE_SHEET_HELP_VIEW.EXPLANER.STEP_2.TITLE")
				static let description = LocalizedStringResource(stringLiteral: "SHARE_SHEET_HELP_VIEW.EXPLANER.STEP_2.DESCRIPTION")
				static let expectation = LocalizedStringResource(stringLiteral: "SHARE_SHEET_HELP_VIEW.EXPLANER.STEP_2.EXPECTATION")
				static let setReminderText = LocalizedStringResource(stringLiteral: "SHARE_SHEET_HELP_VIEW.EXPLANER.STEP_2.SET_REMINDER_TEXT")
				static let enableNotificationButton = LocalizedStringResource(stringLiteral: "SHARE_SHEET_HELP_VIEW.EXPLANER.STEP_2.ENABLE_NOTIFICATION_BUTTON")
			}
			
			enum Step3 {
				static let title = LocalizedStringResource(stringLiteral: "SHARE_SHEET_HELP_VIEW.EXPLANER.STEP_3.TITLE")
				static let description = LocalizedStringResource(stringLiteral: "SHARE_SHEET_HELP_VIEW.EXPLANER.STEP_3.DESCRIPTION")
				static let tapMoreText = LocalizedStringResource(stringLiteral: "SHARE_SHEET_HELP_VIEW.EXPLANER.STEP_3.TAP_MORE_TEXT")
				static let tapEditText = LocalizedStringResource(stringLiteral: "SHARE_SHEET_HELP_VIEW.EXPLANER.STEP_3.TAP_EDIT_TEXT")
				static let enableLynkText = LocalizedStringResource(stringLiteral: "SHARE_SHEET_HELP_VIEW.EXPLANER.STEP_3.ENABLE_LYNK_TEXT")
				static let goodToGoText = LocalizedStringResource(stringLiteral: "SHARE_SHEET_HELP_VIEW.EXPLANER.STEP_3.GOOD_TO_GO_TEXT")
			}
		}
	}
}
