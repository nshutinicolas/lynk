//
//  AppView.swift
//  Lynk
//
//  Created by Musoni nshuti Nicolas on 09/04/2025.
//

import StoreKit
import SwiftUI

enum SortingPill: Equatable, CaseIterable, Identifiable {
	case scheduled
	case all
	case text
	case web
	
	var id: String {
		switch self {
		case .scheduled: return "scheduled"
		case .all: return "all"
		case .text: return "text"
		case .web: return "web"
		}
	}
	
	var title: String {
		switch self {
		case .scheduled:
			return String(localized: L10n.AppView.Sorting.scheduled)
		case .all:
			return String(localized: L10n.AppView.Sorting.all)
		case .text:
			return String(localized: L10n.AppView.Sorting.text)
		case .web:
			return String(localized: L10n.AppView.Sorting.websites)
		}
	}
	
	var iconName: String {
		switch self {
		case .scheduled: return "clock"
		case .all: return "list.bullet"
		case .text: return "textformat"
		case .web: return "safari"
		}
	}
}

struct AppView: View {
	@EnvironmentObject private var coordinator: AppCoordinator
	@EnvironmentObject private var sharedStorage: BookmarkStorage
	@EnvironmentObject private var notificationContainer: NotificationContainer
	@Environment(\.managedObjectContext) private var localStorage
	@Environment(\.openURL) private var openURL
	
	// Top Bar
	@State private var searchText: String = ""
	@State private var showSearchBar: Bool = false
	@State private var rotateSettingsIcon: Bool = false
	@Namespace private var searchBarAnimation
	@State private var showSettings = false
	@FocusState private var searchFieldIsFocused: Bool
	@State private var showAppReview = false
	@State private var showEmailCompose = false
	@State private var addLinkManually = false
	@State private var showDeepLinkAlert: Bool = false
	// Learning
	@State private var showLearningView: Bool = false
	
	@State private var displayMode: DisplayMode = .list
	@State private var deviceOrientation: DeviceOrientation = .portrait
	@State private var showCollectionContent = false
	@State private var isCopiedToClipboard = false
	@State private var isReminderSet = false
	
	@Cached<Int>(.appVisits) private var appVisitCount
	
	private var isPad: Bool {
		UIDevice.current.userInterfaceIdiom == .pad
	}
	private var columnLayout: [GridItem] {
		let phoneCount = deviceOrientation == .landscape ? 4 : 3
		return Array(
			repeating: GridItem(.flexible()),
			count: isPad ? 6 : phoneCount
		)
	}
	
	private var bookmarkCollection: [BookmarkCollection] {
		var domainDictionary = [String: [Bookmark]]()
		for bookmark in bookmarksFetch {
			switch bookmark.createItemCellViewModel()?.category {
			case .text:
				break
			case .url(let url, _):
				let domain = extractDomainName(from: url)
				guard let domain else { break }
				if domainDictionary[domain] == nil {
					domainDictionary[domain] = [bookmark]
				} else {
					domainDictionary[domain]?.append(bookmark)
				}
			case .webPage(_, let url, _):
				let domain = extractDomainName(from: url)
				guard let domain else { break }
				if domainDictionary[domain] == nil {
					domainDictionary[domain] = [bookmark]
				} else {
					domainDictionary[domain]?.append(bookmark)
				}
			default:
				break
			}
		}
		return domainDictionary.map { domain, bookmarks in
			let icon = bookmarks.first?.category?.imageUrl
			return BookmarkCollection(title: domain, icon: icon, bookmarks: bookmarks)
		}
		.sorted {
			let newestDate1 = $0.bookmarks.compactMap { $0.date }.max() ?? Date.distantPast
			let newestDate2 = $1.bookmarks.compactMap { $0.date }.max() ?? Date.distantPast
			return newestDate1 > newestDate2
		}
	}
	// Reminder
	private let notificationManager = NotificationManager.shared
	@State private var selectedDate = Date()
	@State private var selectedTime = Date()
	@State private var selectedBookmarkForReminder: BookmarkModel?
	@State private var showReminderSelector = false
	@State private var showEnableNotificationsAlert = false
	
	// Filtered by the search text, see `updateSearchPredicate`
	@FetchRequest(fetchRequest: Bookmark.listFetchRequest) var bookmarksFetch: FetchedResults<Bookmark>
	
	var body: some View {
		NavigationStack(path: $coordinator.path) {
			VStack {
				// Header
				HStack {
					Text(L10n.appTitle)
						.font(.title2)
						.fontDesign(.serif)
						.fontWeight(.semibold)
				}
				.frame(maxWidth: .infinity, alignment: .leading)
				.overlay(alignment: .trailing) {
					HStack {
						ZStack {
							if showSearchBar {
								HStack {
									HStack {
										TextField(String(localized: L10n.AppView.SearchTextField.placeholder), text: $searchText)
											.focused($searchFieldIsFocused)
											.textInputAutocapitalization(.never)
											.autocorrectionDisabled()
											.padding(.vertical, 10)
											.padding(.horizontal, 8)
										Button {
											searchText = ""
										} label: {
											Image(systemName: "xmark")
												.font(.footnote)
												.padding(8)
												.background(Color.gray.opacity(0.2))
												.clipShape(.circle)
												.padding(4)
										}
										.buttonStyle(.plain)
									}
									.roundedBorder(color: .gray.opacity(0.8), lineWidth: 1)
									Image(systemName: "xmark")
										.font(.title3)
										.padding(10)
										.onTapGesture {
											withAnimation {
												showSearchBar = false
											}
										}
										.roundedBorder(color: .gray.opacity(0.8), lineWidth: 1)
								}
								.matchedGeometryEffect(id: "SEARCH_BAR", in: searchBarAnimation)
							} else {
								if bookmarksFetch.isEmpty == false || searchText.isEmpty == false {
									navIcon("magnifyingglass") {
										withAnimation {
											showSearchBar = true
										}
									}
									.matchedGeometryEffect(id: "SEARCH_BAR", in: searchBarAnimation)
								}
							}
						}
						if showSearchBar == false {
							// TODO: Make it beautiful and appealing
							#if DEBUG
							navIcon(displayMode == .list ? "list.bullet" : "square.grid.2x2") {
								displayMode = displayMode.toggle
							}
							.animation(.spring, value: displayMode)
							#endif
							navIcon("gearshape") {
								rotateSettingsIcon.toggle()
								showSettings = true
							}
						}
					}
				}
				.padding([.horizontal, .top])
				
				if bookmarksFetch.isEmpty {
					emptyView
				} else {
					VStack(spacing: 0) {
						List {
							Section {
								switch displayMode {
								case .grid:
									LazyVGrid(columns: columnLayout) {
										ForEach(bookmarkCollection) { collection in
											bookmarkCollectionView(collection)
										}
									}
								case .list:
									ForEach(bookmarksFetch, id: \.self) { bookmark in
										// TODO: Change to shareable after implementing the share sheet
										if let model = bookmark.createItemCellViewModel(shareable: false) {
											ItemCellView(model: model)
												.shareIconTapped { item in
													shareBookmark(item)
												}
												.padding(8)
												.background()
												.clipShape(.rect(cornerRadius: 8))
												.shadow(color: Color(uiColor: .tertiarySystemFill), radius: 2, x: 2, y:2)
												.onTapGesture {
													bookmarkTapped(model)
												}
												.contextMenu {
													Button {
														copyToClipboard(model.category)
													} label: {
														Label(L10n.Button.copy, systemImage: "document.on.document")
													}
													Button {
														updateStatus(for: model, opened: model.opened == false)
													} label: {
														if model.opened {
															Label(L10n.Button.markAsUnread, systemImage: "envelope.badge")
														} else {
															Label(L10n.Button.markAsRead, systemImage: "envelope.open")
														}
													}
													Button {
														selectedBookmarkForReminder = model
													} label: {
														Label("Schedule a reminder", systemImage: "calendar.badge.clock")
													}
													// TODO: Implement these actions
													#if DEBUG
													Button {
														
													} label: {
														Label(L10n.Button.edit, systemImage: "pencil.and.list.clipboard")
													}
													#endif
													Button {
														deleteBookmark(bookmark)
													} label: {
														Label(L10n.Button.delete, systemImage: "trash")
															.tint(Color.red)
													}
												}
										}
									}
									.onDelete(perform: deleteBookmarks)
								}
							}
							.listRowSeparator(.hidden)
							.listRowInsets(.init(edge: 8))
						}
						.listStyle(.plain)
					}
				}
			}
		}
		.onAppear {
			// Increment app view count
			if let visits = appVisitCount {
				appVisitCount = visits + 1
			} else {
				appVisitCount = 1
			}
			
			// Check for Review alert eligibility
			requestReviewEligible()
		}
		.overlay(alignment: .bottomTrailing) {
			Button {
				addLinkManually = true
			} label: {
				Image(systemName: "plus")
					.font(.title2)
					.fontWeight(.semibold)
					.padding()
					.background()
					.roundedBorder(for: .circle, color: .gray.opacity(0.5))
					.shadow(color: .gray.opacity(0.2), radius: 10)
			}
			.padding()
		}
		// Toast like indicator for copy to clipboard
		// Create a component out of this view
		.overlay(alignment: .bottom) {
			Group {
				if isCopiedToClipboard {
					HStack {
						Group {
							Image(systemName: "document.on.document")
								.font(.caption)
							Text(L10n.AppView.Alert.CopyToClipboard.text)
						}
						.foregroundStyle(Color(uiColor: .systemBackground))
					}
					.padding()
					.padding(.horizontal, 24)
					.background(Color(uiColor: .label))
					.clipShape(.capsule)
					.frame(maxWidth: .infinity, alignment: .center)
					.padding(.bottom, 24)
					.transition(
						.asymmetric(
							insertion: .move(edge: .bottom),
							removal: .move(edge: .bottom)
						)
					)
				}
			}
		}
		// Toast like indicator for set reminder done
		.overlay(alignment: .bottom) {
			Group {
				if isReminderSet {
					HStack {
						Group {
							Image(systemName: "calendar.badge.clock")
								.font(.caption)
							Text(L10n.AppView.Alert.SetReminder.text)
						}
						.foregroundStyle(Color(uiColor: .systemBackground))
					}
					.padding()
					.padding(.horizontal, 24)
					.background(Color(uiColor: .label))
					.clipShape(.capsule)
					.frame(maxWidth: .infinity, alignment: .center)
					.padding(.bottom, 24)
					.transition(
						.asymmetric(
							insertion: .move(edge: .bottom),
							removal: .move(edge: .bottom)
						)
					)
				}
			}
		}
		.addLinkManually($addLinkManually) {
			addLinkManually = false
		}
		.fullScreenCover(isPresented: $showSettings) {
			SettingsView()
		}
		.sheet(isPresented: $showReminderSelector) {
			VStack {
				HStack {
					Button {
						showReminderSelector = false
					} label: {
						Image(systemName: "xmark")
							.resizable()
							.scaledToFit()
							.frame(width: 16, height: 16)
							.padding(12)
							.background(Color.gray.opacity(0.2))
							.roundedBorder(for: .circle)
					}
					.buttonStyle(.plain)
				}
				.frame(maxWidth: .infinity, alignment: .trailing)
				.padding()
				ScrollView(showsIndicators: false) {
					VStack {
						if let selectedBookmarkForReminder {
							ItemCellView(model: selectedBookmarkForReminder)
							Group {
								VStack(alignment: .leading) {
									Text("\(String(localized: L10n.ReminderView.Button.date)):")
										.font(.caption)
									DateTimePopover(
										display: .date,
										selected: $selectedDate,
										in: .partial(Date.now...)
									)
								}
								VStack(alignment: .leading) {
									Text("\(String(localized: L10n.ReminderView.Button.time)):")
										.font(.caption)
									DateTimePopover(
										display: .hourAndMinute,
										selected: $selectedTime,
										in: .partial(Date.now...)
									)
								}
							}
						} else {
							VStack(alignment: .center) {
								Image(systemName: "xmark.shield.fill")
									.font(.largeTitle)
								Text(L10n.AppView.ReminderSelector.emptySelectionText)
							}
							.frame(maxWidth: .infinity, alignment: .center)
						}
					}
					.padding()
				}
				if isReminderDateValid, let selectedBookmarkForReminder {
					PrimaryButton(String(localized: L10n.AppView.ReminderSelector.setReminderButtonText)) {
						setReminder(
							for: selectedBookmarkForReminder,
							date: selectedDate,
							time: selectedTime
						)
						showReminderSelector = false
						// When the reminder is set, show a toast that lasts 3 secs
						withAnimation(.easeInOut(duration: 0.25)) {
							isReminderSet = true
							Task {
								try? await Task.sleep(for: .seconds(3))
								isReminderSet = false
							}
						}
					}
					.padding(.horizontal)
				}
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
			.background()
			.presentationDetents([.large])
		}
		.onChange(of: showSearchBar) { value in
			searchFieldIsFocused = value
		}
		.task(id: searchText) {
			await updateSearchPredicate()
		}
		.onAppear {
			@Cached<String>(.layout) var layout
			guard let layout, let displayMode = DisplayMode(rawValue: layout) else { return }
			self.displayMode = displayMode
		}
		.onChange(of: displayMode) { newValue in
			@Cached<String>(.layout) var layout
			layout = newValue.rawValue
		}
		.onChange(of: notificationContainer.pendingDeeplinkNotification) { value in
			presentPendingDeeplink(value)
		}
		.onAppear {
			// The notification may have been tapped before this view existed (cold launch, app lock, onboarding)
			presentPendingDeeplink(notificationContainer.pendingDeeplinkNotification)
		}
		.onChange(of: selectedBookmarkForReminder) { bookmark in
			guard bookmark != nil else { return }
			Task {
				let notificationStatus = await notificationManager.notificationPermissionStatus()
				switch notificationStatus {
				case .authorized:
					// Show the reminder selector
					showReminderSelector = true
				default:
					// Show an alert to request for notification
					break
				}
			}
		}
		// Determine device orientation
		.onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
			let orientation = UIDevice.current.orientation
			switch orientation {
			case .landscapeLeft, .landscapeRight:
				deviceOrientation = .landscape
			default:
				deviceOrientation = .portrait
			}
		}
		.alert(
			L10n.AppView.Alert.Notification.title,
			isPresented: $showDeepLinkAlert,
			actions: {
				Button(L10n.Button.open) {
					guard let stringUrl = notificationContainer.pendingDeeplinkNotification,
						  let url = URL(string: stringUrl.url) else {
						return
					}
					openURL(url)
					markDeeplinkBookmarkAsOpened(stringUrl)
					// Clear Notification
					notificationContainer.clearPendingDeeplinkNotification()
				}
				Button(L10n.Button.notNow, role: .cancel) {
					// Try and see if user is eligible for the review
					requestReviewEligible()
					// Clear Notification
					notificationContainer.clearPendingDeeplinkNotification()
				}
			}, message: {
				if let stringUrl = notificationContainer.pendingDeeplinkNotification {
					Text("\(stringUrl.title ?? "") \((stringUrl.title != nil) ? "-" : "") \(stringUrl.url)")
						.lineLimit(4)
				} else {
					EmptyView()
				}
			}
		)
		.alert(L10n.AppView.Alert.Feedback.title, isPresented: $showAppReview, actions: {
			Button(L10n.AppView.Alert.Feedback.Button.yesTitle) {
				requestReview()
			}
			Button(L10n.AppView.Alert.Feedback.Button.noTitle) {
				showEmailCompose = true
			}
			Button(L10n.Button.dismiss) { }
		}, message: {
			Text(L10n.AppView.Alert.Feedback.message)
		})
		.sheet(isPresented: $showEmailCompose) {
			MailComposeView(.negativeReview) { _ in }
		}
		.alert(L10n.AppView.Alert.Notification.EnableNotification.title, isPresented: $showEnableNotificationsAlert) {
			Button(L10n.Button.enable) {
				Task {
					let status = await notificationManager.notificationPermissionStatus()
					switch status {
					case .denied:
						guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
						openURL(settingsUrl)
					case .authorized:
						// No check is needed for this state
						break
					default:
						_ = try? await notificationManager.requestNotificationPermission()
					}
					showEnableNotificationsAlert = false
				}
			}
			Button(L10n.Button.dismiss) {
				showEnableNotificationsAlert = false
			}
		} message: {
			Text(L10n.AppView.Alert.Notification.EnableNotification.message)
		}
		.sheet(isPresented: $showLearningView) {
			ShareSheetHelpView {
				showLearningView = false
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.background()
			.presentationDetents([.large])
		}
	}
	
	/// Let CoreData do the filtering, debounced to avoid a fetch on every keystroke
	private func updateSearchPredicate() async {
		let predicate = Bookmark.searchPredicate(for: searchText)
		if predicate != nil {
			try? await Task.sleep(for: .milliseconds(250))
			guard Task.isCancelled == false else { return }
		}
		guard bookmarksFetch.nsPredicate != predicate else { return }
		bookmarksFetch.nsPredicate = predicate
	}
	
	private func deleteBookmark(_ bookmark: Bookmark) {
		localStorage.delete(bookmark)
		do {
			try localStorage.save()
		} catch {
			print("Failed to delete bookmarks: \(error.localizedDescription)")
		}
	}
	
	private func deleteBookmarks(_ indexSet: IndexSet) {
		for index in indexSet {
			let bookmark = bookmarksFetch[index]
			localStorage.delete(bookmark)
		}
		do {
			try localStorage.save()
		} catch {
			print("Failed to delete bookmarks: \(error.localizedDescription)")
		}
	}
	
	private func shareBookmark(_ bookmark: BookmarkModel) {
		// TODO: Implement the share logic
		switch bookmark.category {
		case .text(let text):
			ShareSheetHelper.present(items: [text])
		case .url(let stringUrl, let title):
			if let url = URL(string: stringUrl) {
				ShareSheetHelper.present(items: [url])
			} else {
				ShareSheetHelper.present(items: [stringUrl, title ?? "No title"])
			}
		case .webPage(let title, let url, _):
			ShareSheetHelper.present(items: [title, url])
		}
	}
	
	private func bookmarkTapped(_ bookmark: BookmarkModel) {
		switch bookmark.category {
		case .text(let string):
			print(string)
			// TODO: Implement a bottom sheet that will show this text
			break
		case .url(let urlString, _):
			guard let url = URL(string: urlString) else { return }
			openURL(url)
		case .webPage(_, let urlString, _):
			guard let url = URL(string: urlString) else { return }
			openURL(url)
		}
		updateStatus(for: bookmark)
	}
	
	private func updateStatus(for model: BookmarkModel, opened: Bool = true) {
		var bookmarkModel = model
		bookmarkModel.updateOpenedState(to: opened)
		// Save the updated model
		sharedStorage.updateBookmarkStatus(for: bookmarkModel)
	}
	
	private func presentPendingDeeplink(_ value: NotificationContainer.AlertInfo?) {
		guard value != nil else { return }
		Task {
			// Give the app time to finish coming to the foreground before presenting the alert
			try await Task.sleep(for: .seconds(1))
			guard notificationContainer.pendingDeeplinkNotification != nil else { return }
			showDeepLinkAlert = true
		}
	}
	
	/// Mark the bookmark behind a notification as opened, by id when available or by its link for older notifications
	private func markDeeplinkBookmarkAsOpened(_ info: NotificationContainer.AlertInfo) {
		// Not using `bookmarksFetch` since it may be filtered by the search text
		let model = sharedStorage.fetchStoredBookmarks().first { model in
			if let bookmarkId = info.bookmarkId {
				return model.id == bookmarkId
			}
			switch model.category {
			case .url(let url, _), .webPage(_, let url, _):
				return url == info.url
			case .text:
				return false
			}
		}
		guard let model else { return }
		updateStatus(for: model)
	}
	
	@ViewBuilder
	private func navIcon(_ icon: String, action: @escaping () -> Void) -> some View {
		Button {
			action()
		} label: {
			Image(systemName: icon)
				.resizable()
				.frame(width: 20, height: 20)
				.padding(12)
				.roundedBorder(color: .gray.opacity(0.8))
		}
		.buttonStyle(.plain)
		.shadow(color: Color.gray.opacity(0.2), radius: 4)
	}
	
	@ViewBuilder
	private func bookmarkCollectionView(_ collection: BookmarkCollection) -> some View {
		VStack {
			Group {
				if let icon = collection.icon {
					RemoteImage(url: icon)
						.setErrorView {
							Image(systemName: "globe")
								.resizable()
						}
						.scaledToFit()
				} else {
					Image(systemName: "globe")
						.resizable()
						.scaledToFit()
				}
			}
			.frame(maxWidth: .infinity)
			.frame(height: isPad ? 120 : 80)
			.padding(8)
			.background()
			.clipShape(.rect(cornerRadius: 8))
			.shadow(color: Color(uiColor: .tertiarySystemFill), radius: 2, x: 2, y:2)
			Text(collection.title)
				.lineLimit(2, reservesSpace: true)
		}
		.frame(maxWidth: .infinity)
	}
	
	@ViewBuilder
	private var emptyView: some View {
		VStack {
			Image(systemName: "paperclip.badge.ellipsis")
				.font(.largeTitle)
				.foregroundStyle(Color.pink.gradient)
				.padding()
				.overlay {
					Circle()
						.stroke(lineWidth: 2)
						.fill(Color.green.opacity(0.7).gradient)
				}
				.padding(28)
				.overlay {
					Circle()
						.stroke(lineWidth: 2)
						.fill(Color.blue.opacity(0.4).gradient)
				}
			Text(L10n.AppView.EmptyView.noFoundText)
				.font(.title3)
			
			Button(L10n.AppView.EmptyView.Button.leanHowText) {
				showLearningView = true
			}
			.padding()
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
	}
	
	private func extractDomainName(from url: String) -> String? {
		guard let url = URL(string: url), let host = url.host() else { return nil }
		let domain = host.replacingOccurrences(of: "www.", with: "")
		return domain
	}
	
	private struct BookmarkCollection: Identifiable, Hashable {
		let id: String = UUID().uuidString
		let title: String
		let icon: String?
		let bookmarks: [Bookmark]
	}
	
	/// Check if session is eligible for the app review and then set `showAppReview` to true
	private func requestReviewEligible() {
		guard AppReviewRequest.requestAppReviewEligible() else { return }
		Task {
			try await Task.sleep(for: .seconds(2))
			// Consider using defer incase the above throws an error
			showAppReview = true
		}
	}
	
	/// Send a request to show the app review alert and update review values
	private func requestReview() {
		guard let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else { return }
		AppStore.requestReview(in: scene)
		// Update review values
		AppReviewRequest.updateReviewValues()
	}
	
	private func copyToClipboard(_ item: BookmarkModel.Category) {
		switch item {
		case .text(let text):
			UIPasteboard.general.string = text
		case .url(url: let url, _):
			UIPasteboard.general.string = url
		case .webPage(_, let url, _):
			UIPasteboard.general.string = url
		}
		// Present the toast and dismiss
		withAnimation(.easeInOut(duration: 0.25)) {
			isCopiedToClipboard = true
			Task {
				try? await Task.sleep(for: .seconds(3))
				isCopiedToClipboard = false
			}
		}
	}
	// TODO: Centralize this logic
	// I've used this logic in 3 places and need a refactor. Find the best common location
	private var isReminderDateValid: Bool {
		guard selectedDate.is(.greaterOrEqual, to: Date.now, for: [.day, .month, .year]) else { return false }
		
		if selectedDate.is(.equal, to: Date.now, for: [.day, .month, .year]) {
			return selectedTime.is(.greaterThan, to: selectedDate, for: [.hour, .minute])
		}
		return true
	}
	
	private func setReminder(for model: BookmarkModel, date: Date, time: Date) {
		notificationManager.scheduleNotification(
			for: model,
			date: date,
			time: time
		)
	}
}

extension AppView {
	enum DisplayMode: String {
		case list
		case grid
		
		var toggle: Self {
			switch self {
			case .list: return .grid
			case .grid: return .list
			}
		}
	}
	
	enum DeviceOrientation {
		case portrait, landscape
	}
}

#Preview {
	let context = BookmarkStorage(inMemory: true).container.viewContext
	AppView()
		.environmentObject(AppCoordinator())
		.environment(\.managedObjectContext, context)
		.environmentObject(NotificationContainer.shared)
}

// TODO: Revisit this when implementing the share icon action
struct ShareSheetHelper {
	static func present(items: [Any]) {
		let keyWindow = UIApplication.shared.connectedScenes
			.filter({$0.activationState == .foregroundActive})
			.map({$0 as? UIWindowScene})
			.compactMap({$0})
			.first?.windows
			.filter({$0.isKeyWindow}).first
		
		if let rootViewController = keyWindow?.rootViewController {
			let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
			rootViewController.present(activityViewController, animated: true)
		}
	}
}
