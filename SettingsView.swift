//
//  SettingsView.swift
//  SWAdjective
//
//  Created by EVYATAR DAYAN on 2026-01-28.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    @StateObject private var testHistoryManager = TestHistoryManager.shared
    @StateObject private var practiceHistoryManager = PracticeHistoryManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var showingClearHistoryAlert = false
    @State private var showingNotificationSettings = false
    @State private var showingLearningTips = false
    @State private var showingTermsPrivacy = false
    @State private var showingHelpSupport = false
    @State private var showingAbout = false
    
    private var notificationSubtitle: String {
        if notificationManager.notificationsEnabled {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            let timeString = formatter.string(from: notificationManager.notificationTime)
            return "Every day at \(timeString)"
        } else {
            return "Configure notification time"
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with title - matching TestView and PracticeView style
            ZStack {
                // Centered title
                HStack {
                    Spacer()
                    Text("Settings")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.blue)
                    Spacer()
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 5)
            .padding(.bottom, 20)
            
            // Content
            ScrollView {
                VStack(spacing: 0) {
                
                // MODE Section
                SettingsSection(header: "MODE") {
                    SettingsRow(
                        icon: "moon.fill",
                        iconColor: .purple,
                        title: "Dark Mode",
                        subtitle: "Enable/Disable dark mode",
                        accessory: .toggle(isOn: $darkModeEnabled)
                    )
                }
                
                // SCHEDULE Section
                SettingsSection(header: "SCHEDULE") {
                    SettingsRow(
                        icon: "clock",
                        iconColor: .orange,
                        title: "Schedule Notifications",
                        subtitle: notificationSubtitle,
                        accessory: .chevron(action: {
                            showingNotificationSettings = true
                        })
                    )
                }
                
                // LEARNING Section
                SettingsSection(header: "LEARNING") {
                    SettingsRow(
                        icon: "lightbulb.fill",
                        iconColor: .yellow,
                        title: "Learning Tips",
                        subtitle: "Effective learning strategies",
                        accessory: .chevron(action: {
                            showingLearningTips = true
                        })
                    )
                }
                
                // SUPPORT Section
                SettingsSection(header: "SUPPORT") {
                    SettingsRow(
                        icon: "questionmark.circle.fill",
                        iconColor: .blue,
                        title: "Help & Support",
                        subtitle: "Get help and contact support",
                        accessory: .chevron(action: {
                            showingHelpSupport = true
                        })
                    )
                    
                    SettingsRow(
                        icon: "doc.text.fill",
                        iconColor: .blue,
                        title: "Terms & Privacy",
                        subtitle: "View terms and privacy policy",
                        accessory: .chevron(action: {
                            showingTermsPrivacy = true
                        })
                    )
                    
                    SettingsRow(
                        icon: "info.circle.fill",
                        iconColor: .blue,
                        title: "About",
                        subtitle: "App version and information",
                        accessory: .chevron(action: {
                            showingAbout = true
                        })
                    )
                }
                
                // CACHE Section
                SettingsSection(header: "CACHE") {
                    SettingsRow(
                        icon: "clock.arrow.circlepath",
                        iconColor: .red,
                        title: "Clear History",
                        subtitle: "Delete all history records",
                        accessory: .button(
                            badge: nil,
                            action: {
                                showingClearHistoryAlert = true
                            }
                        )
                    )
                }
                
                    Spacer(minLength: 20)
                }
                .padding(.bottom, 55) // Add padding for menu
            }
        }
        .background(Color(.systemGroupedBackground))
        .clipped()
        .alert("Clear History", isPresented: $showingClearHistoryAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Clear", role: .destructive) {
                testHistoryManager.clearAllHistory()
                practiceHistoryManager.clearAllHistory()
            }
        } message: {
            Text("Are you sure? This will delete all history records.")
        }
        .sheet(isPresented: $showingNotificationSettings) {
            NotificationSettingsModal()
        }
        .sheet(isPresented: $showingLearningTips) {
            LearningTipsView()
        }
        .sheet(isPresented: $showingTermsPrivacy) {
            TermsPrivacyView()
        }
        .sheet(isPresented: $showingHelpSupport) {
            HelpSupportView()
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
    }
}

struct SettingsSection<Content: View>: View {
    let header: String
    let content: Content
    
    init(header: String, @ViewBuilder content: () -> Content) {
        self.header = header
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(header)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.secondary)
                .textCase(.uppercase)
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 8)
            
                VStack(spacing: 8) {
                content
            }
            .padding(.horizontal, 20)
        }
    }
}

enum SettingsRowAccessory {
    case toggle(isOn: Binding<Bool>)
    case chevron(action: (() -> Void)? = nil)
    case button(badge: String?, action: () -> Void)
}

struct SettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let accessory: SettingsRowAccessory
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon - simple style without circle
            Image(systemName: icon)
                .font(.system(size: 22, weight: .medium))
                .foregroundColor(iconColor)
                .frame(width: 30, height: 30)
            
            // Text content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Accessory
            switch accessory {
            case .toggle(let isOn):
                Toggle("", isOn: isOn)
                    .labelsHidden()
            case .chevron:
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
                    .opacity(0.7)
            case .button(let badge, _):
                HStack(spacing: 8) {
                    if let badge = badge, !badge.isEmpty {
                        Text(badge)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.red)
                            .cornerRadius(12)
                    }
                    Text("Clear")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .contentShape(Rectangle())
        .onTapGesture {
            switch accessory {
            case .chevron(let action):
                if let action = action {
                    action()
                }
            case .button(_, let action):
                action()
            case .toggle:
                break
            }
        }
    }
}

struct NotificationSettingsModal: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var notificationManager = NotificationManager.shared
    @Environment(\.colorScheme) var colorScheme
    
    private var dailyReminderBinding: Binding<Bool> {
        Binding(
            get: { notificationManager.notificationsEnabled },
            set: { newValue in
                if newValue {
                    notificationManager.requestAuthorization { granted in
                        notificationManager.notificationsEnabled = granted
                    }
                } else {
                    notificationManager.notificationsEnabled = false
                }
            }
        )
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Toggle("Daily reminder", isOn: dailyReminderBinding)
                } header: {
                    Text("Reminder")
                } footer: {
                    Text("Get a daily notification to practice Swedish")
                }
                
                if notificationManager.notificationsEnabled {
                    Section {
                        DatePicker("Time", selection: $notificationManager.notificationTime, displayedComponents: .hourAndMinute)
                    } header: {
                        Text("Notification time")
                    }
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct LearningTipsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Tip 1
                    TipSection(
                        number: "1",
                        title: "Learn words inside a sentence (not alone)",
                        description: "Your brain remembers meaning + situation, not lists.",
                        badExample: "äta = to eat",
                        goodExample: "Jag äter frukost.\n\"I eat breakfast.\"",
                        betterExample: "Even better:\nJag äter frukost varje morgon."
                    )
                    
                    // Tip 2
                    TipSection(
                        number: "2",
                        title: "Use active recall, not rereading",
                        description: "Reading feels productive, but testing yourself works better.",
                        simpleMethod: "Simple method:\n• Look at the word\n• Hide it\n• Ask yourself: \"What does this mean?\"\n• Check\n\n30 seconds per word is enough."
                    )
                    
                    // Tip 3
                    TipSection(
                        number: "3",
                        title: "Short, frequent sessions (5–10 min)",
                        description: "The brain forgets fast — and that's normal.",
                        bestSchedule: "Best schedule:\n• 5–10 minutes\n• 1–3 times per day\n• Stop before you feel tired\n\nConsistency > duration."
                    )
                    
                    // Tip 4
                    TipSection(
                        number: "4",
                        title: "Say it out loud (even quietly)",
                        description: "Speaking activates memory differently than reading.",
                        justDo: "Just:\n• Say the word\n• Say the sentence\n• Say the translation\n\nYes, even if your pronunciation isn't perfect."
                    )
                    
                    // Tip 5
                    TipSection(
                        number: "5",
                        title: "Connect the word to you",
                        description: "Personal relevance boosts memory.",
                        insteadOf: "Instead of:\nHan äter middag.",
                        tryThis: "Try:\nJag äter middag klockan sex.\n\nYour brain cares more when you are in the sentence."
                    )
                    
                    // Tip 6
                    TipSection(
                        number: "6",
                        title: "Use spaced repetition (but keep it simple)",
                        description: "You don't need fancy systems.",
                        justReview: "Just review:\n• same day\n• next day\n• 3 days later\n• 1 week later\n\nEven 10 words reviewed beats 50 new ones forgotten."
                    )
                    
                    // What NOT to do
                    VStack(alignment: .leading, spacing: 12) {
                        Text("What NOT to do")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("• Don't memorize long word lists")
                            Text("• Don't cram for an hour")
                            Text("• Don't rely only on passive reading")
                            Text("• Don't worry about perfection")
                        }
                        .font(.body)
                        .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(
                        colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground)
                    )
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    
                    // Simplest winning routine
                    VStack(alignment: .leading, spacing: 12) {
                        Text("The simplest winning routine (5 minutes)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("• Pick 5 words")
                            Text("• Read each in a sentence")
                            Text("• Say each out loud once")
                            Text("• Test yourself quickly")
                            Text("• Stop")
                        }
                        .font(.body)
                        .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(
                        colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground)
                    )
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
            .background(colorScheme == .dark ? Color.black : Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Learning Tips")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct TipSection: View {
    let number: String
    let title: String
    let description: String
    var badExample: String? = nil
    var goodExample: String? = nil
    var betterExample: String? = nil
    var simpleMethod: String? = nil
    var bestSchedule: String? = nil
    var justDo: String? = nil
    var insteadOf: String? = nil
    var tryThis: String? = nil
    var justReview: String? = nil
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
                
                if let badExample = badExample, let goodExample = goodExample {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .top, spacing: 8) {
                            Text("❌")
                                .font(.title3)
                            Text("Bad")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.red)
                        }
                        Text(badExample)
                            .font(.body)
                            .foregroundColor(.primary)
                        
                        HStack(alignment: .top, spacing: 8) {
                            Text("✅")
                                .font(.title3)
                            Text("Good")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                        }
                        Text(goodExample)
                            .font(.body)
                            .foregroundColor(.primary)
                        
                        if let betterExample = betterExample {
                            Text(betterExample)
                                .font(.body)
                                .foregroundColor(.primary)
                                .padding(.top, 4)
                        }
                    }
                    .padding(.top, 4)
                }
                
                if let simpleMethod = simpleMethod {
                    Text(simpleMethod)
                        .font(.body)
                        .foregroundColor(.primary)
                        .padding(.top, 4)
                }
                
                if let bestSchedule = bestSchedule {
                    Text(bestSchedule)
                        .font(.body)
                        .foregroundColor(.primary)
                        .padding(.top, 4)
                }
                
                if let justDo = justDo {
                    Text(justDo)
                        .font(.body)
                        .foregroundColor(.primary)
                        .padding(.top, 4)
                }
                
                if let insteadOf = insteadOf, let tryThis = tryThis {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(insteadOf)
                            .font(.body)
                            .foregroundColor(.primary)
                        
                        Text(tryThis)
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                    .padding(.top, 4)
                }
                
                if let justReview = justReview {
                    Text(justReview)
                        .font(.body)
                        .foregroundColor(.primary)
                        .padding(.top, 4)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground)
        )
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct TermsPrivacyView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Segmented Control
                Picker("Section", selection: $selectedTab) {
                    Text("Terms").tag(0)
                    Text("Privacy").tag(1)
                    Text("Disclaimer").tag(2)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(contentText)
                            .font(.body)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Terms & Privacy")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var contentText: String {
        switch selectedTab {
        case 0:
            return termsContent
        case 1:
            return privacyContent
        default:
            return disclaimerContent
        }
    }
    
    private let termsContent = """
    TERMS OF USE
    
    Last Updated: January 26, 2026
    
    Welcome to SWAdjective. These Terms of Use ("Terms") govern your access to and use of the SWAdjective mobile application ("App"). By using the App, you agree to be bound by these Terms.
    
    1. ACCEPTANCE OF TERMS
    By downloading, installing, or using SWAdjective, you acknowledge that you have read, understood, and agree to be bound by these Terms and our Privacy Policy.
    
    2. DESCRIPTION OF SERVICE
    SWAdjective is a mobile application designed to help you practice Swedish adjectives. The App allows you to:
    - Practice adjective agreement (En, Ett, and Plural forms)
    - Practice adjective comparison (positive, comparative, superlative — e.g. better, bigger, best)
    - Practice antonyms (opposite words)
    - Complete practice sessions with multiple-choice questions
    - Track your progress through session summaries and history
    - Use optional text-to-speech for pronunciation
    - Set daily reminders for practice
    
    3. USER ACCOUNTS
    You may use the App without creating an account. All data is stored locally on your device.
    
    4. ACCEPTABLE USE
    You agree to use the App only for lawful purposes and in accordance with these Terms. You agree not to:
    - Use the App for any illegal or unauthorized purpose
    - Attempt to gain unauthorized access to any part of the App
    - Interfere with or disrupt the App's functionality
    - Use automated systems to access the App
    
    5. INTELLECTUAL PROPERTY
    The App and its content, including but not limited to text, graphics, logos, and software, are the property of SWAdjective and are protected by copyright and other intellectual property laws.
    
    6. LIMITATION OF LIABILITY
    SWAdjective is provided "as is" without warranties of any kind. We do not guarantee that the App will be error-free or uninterrupted. In no event shall SWAdjective be liable for any indirect, incidental, or consequential damages.
    
    7. MODIFICATIONS TO TERMS
    We reserve the right to modify these Terms at any time. Your continued use of the App after any changes constitutes acceptance of the modified Terms.
    
    8. CONTACT INFORMATION
    If you have any questions about these Terms, please contact us through the App's Help & Support section.
    """
    
    private let privacyContent = """
    PRIVACY POLICY
    
    Last Updated: January 26, 2026
    
    At SWAdjective, we are committed to protecting your privacy. This Privacy Policy explains how we handle your information when you use our mobile application.
    
    1. NO DATA COLLECTION
    SWAdjective does not collect, transmit, or store any of your personal information on external servers. We do not collect:
    - Usage analytics
    - Device information
    - Location data
    - Any other personal data
    
    All information you enter into the App remains on your device only.
    
    2. LOCAL DATA STORAGE
    All your data is stored exclusively on your device using secure local storage methods. This includes:
    - Practice history (Agreement, Comparison, Antonyms sessions)
    - Session progress and results
    - App settings and preferences (e.g. dark mode, notification time)
    
    Your data never leaves your device and is not transmitted to any external servers or third parties.
    
    3. DATA MANAGEMENT
    You have full control over your data:
    - Clear History: In Settings, you can use the "Clear History" option to remove all practice history. This action cannot be undone.
    These actions are permanent and cannot be reversed.
    
    4. NO DATA SHARING
    Since we do not collect any data, we do not and cannot share your information with anyone. Your privacy is fully protected because your data never leaves your device.
    
    5. DATA SECURITY
    Your data is protected by your device's built-in security features. We use secure local storage methods provided by iOS to ensure your information remains private and secure on your device.
    
    6. YOUR RIGHTS
    You have complete control over your data:
    - All data is stored locally on your device
    - You can clear all data at any time through Settings
    - No external parties have access to your information
    
    7. CHILDREN'S PRIVACY
    Our App is suitable for users of all ages. Since we do not collect any data, we do not collect personal information from anyone, including children.
    
    8. CHANGES TO THIS POLICY
    We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy in the App.
    
    9. CONTACT US
    If you have any questions about this Privacy Policy, please contact us through the App's Help & Support section.
    """
    
    private let disclaimerContent = """
    DISCLAIMER
    
    Last Updated: January 26, 2026
    
    1. NO WARRANTY
    SWAdjective is provided "as is" and "as available" without any warranties, express or implied. We do not guarantee that the App will be error-free, uninterrupted, or free from defects.
    
    2. ACCURACY OF CONTENT
    While we strive to ensure accurate Swedish adjective forms and translations, we cannot guarantee the accuracy of all content. Users are responsible for verifying information and should consult additional resources for comprehensive learning.
    
    3. LIMITATION OF LIABILITY
    To the fullest extent permitted by law, SWAdjective shall not be liable for any indirect, incidental, special, consequential, or punitive damages, including but not limited to loss of data or use, arising out of or in connection with the use of the App.
    
    4. USER RESPONSIBILITY
    Users are solely responsible for:
    - Verifying adjective forms and translations
    - Using the App as a supplementary learning tool
    - Maintaining the security of their device
    
    5. THIRD-PARTY SERVICES
    The App may integrate services such as text-to-speech for pronunciation. These are operated by third parties and are subject to their own terms of use and privacy policies.
    
    6. CHANGES TO THE APP
    We reserve the right to modify, suspend, or discontinue the App at any time without prior notice. We shall not be liable to you or any third party for any modification, suspension, or discontinuance.
    
    7. NO PROFESSIONAL ADVICE
    The App is for educational and learning purposes only. It does not constitute professional language instruction or certification. Users should consult with qualified language instructors for formal education.
    
    8. ACCEPTANCE
    By using SWAdjective, you acknowledge that you have read, understood, and agree to this Disclaimer.
    """
}

struct HelpSupportView: View {
    @Environment(\.dismiss) var dismiss
    @State private var fullName = ""
    @State private var email = ""
    @State private var subject = ""
    @State private var description = ""
    @State private var showForm = false
    @State private var showError = false
    @State private var showCallAlert = false
    @State private var alertType: AlertType = .none
    
    enum AlertType {
        case none
        case messageSent
        case callSupport
    }
    
    let supportPhone = "+46 123 456 789"
    
    var allFieldsFilled: Bool {
        !fullName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        !subject.trimmingCharacters(in: .whitespaces).isEmpty &&
        !description.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        NavigationView {
            Group {
                if showForm {
                    Form {
                        Section(header: Text("Your full name")) {
                            TextField("Full name", text: $fullName)
                        }
                        
                        Section(header: Text("Your Email")) {
                            TextField("Email", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                        }
                        
                        Section(header: Text("Subject")) {
                            TextField("", text: $subject)
                                .onChange(of: subject) { oldValue, newValue in
                                    if newValue.count > 100 {
                                        subject = String(newValue.prefix(100))
                                    }
                                }
                            HStack {
                                Spacer()
                                Text("\(subject.count)/100")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Section(header: Text("Description")) {
                            TextEditor(text: $description)
                                .frame(height: 120)
                                .onChange(of: description) { oldValue, newValue in
                                    if newValue.count > 400 {
                                        description = String(newValue.prefix(400))
                                    }
                                }
                            HStack {
                                Spacer()
                                Text("\(description.count)/400")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        if showError && !allFieldsFilled {
                            Section {
                                Text("All fields are required.")
                                    .foregroundColor(.red)
                                    .font(.subheadline)
                            }
                        }
                        
                        Section {
                            Button(action: {
                                if allFieldsFilled {
                                    alertType = .messageSent
                                    showError = false
                                } else {
                                    showError = true
                                }
                            }) {
                                Text("Send")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(allFieldsFilled ? Color.green : Color.gray)
                                    .cornerRadius(12)
                            }
                            .disabled(!allFieldsFilled)
                        }
                        .listRowBackground(Color.clear)
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text("Contact us")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                    }
                } else {
                    VStack {
                        Spacer(minLength: 0)
                        VStack(alignment: .center, spacing: 32) {
                            VStack(alignment: .center, spacing: 16) {
                                Text("We'd love to hear from you!")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                
                                Text("Whether you have questions about")
                                    .font(.body)
                                
                                Text("SWAdjective, feedback, or just want to say hi,")
                                    .font(.body)
                                
                                Text("feel free to reach out.")
                                    .font(.body)
                                
                                Divider()
                                    .padding(.vertical, 8)
                                    .padding(.top, 32)
                                    .padding(.bottom, 32)
                                
                                Text("Email: abashelariprod@gmail.com")
                                    .font(.subheadline)
                                
                                Text("Website: https://abashelariprod.wordpress.com")
                                    .font(.subheadline)
                                
                                Divider()
                                    .padding(.vertical, 8)
                                    .padding(.top, 32)
                            }
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 32)
                            
                            Text("OR")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                                .padding(.vertical, 8)
                            
                            Button(action: {
                                showForm = true
                            }) {
                                Text("Contact form")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color.green)
                                    .cornerRadius(12)
                                    .padding(.horizontal, 32)
                            }
                            
                            Text("We aim to respond within 24 hours.")
                                .font(.body)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                        }
                        Spacer()
                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                    .padding(.vertical, 32)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text("Help & Support")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if showForm {
                        Button("Cancel") {
                            showForm = false
                        }
                    } else {
                        Button("Close") {
                            dismiss()
                        }
                    }
                }
            }
            .alert(isPresented: Binding(
                get: { alertType != .none },
                set: { if !$0 { alertType = .none } }
            )) {
                switch alertType {
                case .messageSent:
                    return Alert(
                        title: Text("Message Sent"),
                        message: Text("Thanks for reaching out!"),
                        dismissButton: .default(Text("OK")) {
                            dismiss()
                        }
                    )
                case .callSupport:
                    return Alert(
                        title: Text("Call Support"),
                        message: Text("Do you want to call \(supportPhone)?"),
                        primaryButton: .default(Text("Yes")) {
                            if let url = URL(string: "tel://" + supportPhone.filter { $0.isNumber }) {
                                UIApplication.shared.open(url)
                            }
                        },
                        secondaryButton: .cancel(Text("No"))
                    )
                case .none:
                    return Alert(title: Text(""), message: Text(""), dismissButton: .default(Text("")))
                }
            }
        }
    }
}

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "Version \(version) (\(build))"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // App Version
                    VStack(alignment: .center, spacing: 8) {
                        Text(appVersion)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)
                    
                    Divider()
                        .padding(.vertical, 8)
                    
                    // About SWAdjective Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("About SWAdjective")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("SWAdjective is a Swedish adjective practice app designed to help you master Swedish adjectives with ease. Practice adjective agreement (En, Ett, and Plural forms), comparison (positive, comparative, superlative - e.g. better, bigger, best), and antonyms. Complete practice sessions with multiple-choice questions, track your progress through session summaries and history, and use optional text-to-speech for pronunciation. Set daily reminders to keep your practice consistent and build your Swedish adjective skills systematically.")
                            .font(.body)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Divider()
                        .padding(.vertical, 8)
                    
                    // About ABASHELARI Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("About ABASHELARI")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("At ABASHELARI, we believe in creating software that makes everyday life simpler, smarter, and more enjoyable. Our mission is to develop innovative digital solutions that blend creativity with technology, offering users tools that are intuitive, reliable, and engaging.")
                            .font(.body)
                            .multilineTextAlignment(.leading)
                        
                        Text("Whether it's educational apps, lifestyle tools, or entertainment experiences, ABASHELARI is dedicated to delivering high-quality products that inspire learning, spark curiosity, and bring value to people around the world.")
                            .font(.body)
                            .multilineTextAlignment(.leading)
                        
                        Text("Driven by passion and guided by innovation, ABASHELARI is committed to continuous improvement and to building software that connects people with what matters most.")
                            .font(.body)
                            .multilineTextAlignment(.leading)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("About")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
