//
//  Managers.swift
//  Swedisher
//
//  Created by EVYATAR DAYAN on 2026-01-28.
//

import Foundation
import SwiftUI
import Combine
import UserNotifications

// MARK: - Wrong Answers Manager
class WrongAnswersManager: ObservableObject {
    static let shared = WrongAnswersManager()
    
    private init() {}
    
    func clearAllWrongAnswers() {
        // Clear wrong answers implementation
        UserDefaults.standard.removeObject(forKey: "wrongAnswers")
    }
    
    func addWrongAnswer(swedish: String, english: String) {
        // Add wrong answer implementation
    }
    
    func removeWrongAnswer(swedish: String, english: String) {
        // Remove wrong answer implementation
    }
    
    func recordCorrectAnswer(swedish: String, english: String) {
        // Record correct answer implementation
    }
}

// MARK: - Word State Manager
class WordStateManager: ObservableObject {
    static let shared = WordStateManager()
    
    private init() {}
    
    func clearAllWordStates() {
        // Clear word states implementation
        UserDefaults.standard.removeObject(forKey: "wordStates")
    }
    
    func getWordState(swedish: String, english: String) -> WordState {
        // Get word state implementation
        return .new
    }
    
    func markWordAsSeen(swedish: String, english: String) {
        // Mark word as seen implementation
    }
    
    func recordAnswer(swedish: String, english: String, isCorrect: Bool) {
        // Record answer implementation
    }
    
    func getWordsByState(_ state: WordState) -> [WordStateData] {
        // Get words by state implementation
        return []
    }
    
    func getAllWordStates() -> [WordStateData] {
        // Get all word states implementation
        return []
    }
}

enum WordState {
    case new
    case weak
    case learning
    case review
    case mastered
}

struct WordStateData {
    let swedish: String
    let english: String
    let state: WordState
    let lastSeen: Date?
}

// MARK: - Test History Manager
class TestHistoryManager: ObservableObject {
    static let shared = TestHistoryManager()
    
    private init() {}
    
    func clearAllHistory() {
        // Clear test history implementation
        UserDefaults.standard.removeObject(forKey: "testHistory")
    }
    
    var historyItems: [TestHistoryItem] {
        // Return test history items
        return []
    }
    
    func addHistoryItem(_ item: TestHistoryItem) {
        // Add history item implementation
    }
}

struct TestHistoryItem {
    let dateTaken: Date
    let questions: Int
    let correct: Int
    let wrong: Int
    let successPercentage: Int
}

// MARK: - Practice History Manager
class PracticeHistoryManager: ObservableObject {
    static let shared = PracticeHistoryManager()
    
    private let historyKey = "practiceHistory"
    
    private init() {}
    
    func clearAllHistory() {
        UserDefaults.standard.removeObject(forKey: historyKey)
    }
    
    var historyItems: [PracticeHistoryItem] {
        guard let data = UserDefaults.standard.data(forKey: historyKey) else {
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode([PracticeHistoryItem].self, from: data)
        } catch {
            print("❌ Error loading practice history: \(error)")
            return []
        }
    }
    
    func addHistoryItem(_ item: PracticeHistoryItem) {
        var items = historyItems
        items.append(item)
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(items)
            UserDefaults.standard.set(data, forKey: historyKey)
        } catch {
            print("❌ Error saving practice history: \(error)")
        }
    }
}

enum PracticeType: String, Codable {
    case adjective
    case compare
    case antonym
}

struct PracticeHistoryItem: Codable {
    let dateTaken: Date
    let questions: Int
    let correct: Int
    let wrong: Int
    let successPercentage: Int
    let practiceType: PracticeType?
    
    enum CodingKeys: String, CodingKey {
        case dateTaken, questions, correct, wrong, successPercentage, practiceType
    }
    
    init(dateTaken: Date, questions: Int, correct: Int, wrong: Int, successPercentage: Int, practiceType: PracticeType? = nil) {
        self.dateTaken = dateTaken
        self.questions = questions
        self.correct = correct
        self.wrong = wrong
        self.successPercentage = successPercentage
        self.practiceType = practiceType
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        dateTaken = try container.decode(Date.self, forKey: .dateTaken)
        questions = try container.decode(Int.self, forKey: .questions)
        correct = try container.decode(Int.self, forKey: .correct)
        wrong = try container.decode(Int.self, forKey: .wrong)
        successPercentage = try container.decode(Int.self, forKey: .successPercentage)
        practiceType = try container.decodeIfPresent(PracticeType.self, forKey: .practiceType)
    }
}

// MARK: - Notification Manager
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    private let notificationsEnabledKey = "notificationsEnabled"
    private let notificationTimeKey = "notificationTime"
    private let dailyReminderIdentifier = "dailyPracticeReminder"
    
    @Published var notificationsEnabled: Bool = false {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: notificationsEnabledKey)
            if notificationsEnabled {
                scheduleDailyNotification()
            } else {
                cancelAllNotifications()
            }
        }
    }
    
    @Published var notificationTime: Date = Date() {
        didSet {
            UserDefaults.standard.set(notificationTime, forKey: notificationTimeKey)
            if notificationsEnabled {
                scheduleDailyNotification()
            }
        }
    }
    
    private init() {
        notificationsEnabled = UserDefaults.standard.bool(forKey: notificationsEnabledKey)
        if let savedTime = UserDefaults.standard.object(forKey: notificationTimeKey) as? Date {
            notificationTime = savedTime
        } else {
            // Default to 19:00 (7 PM)
            var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            components.hour = 19
            components.minute = 0
            notificationTime = Calendar.current.date(from: components) ?? Date()
        }
    }
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    func scheduleDailyNotification() {
        cancelAllNotifications()
        
        let content = UNMutableNotificationContent()
        content.title = "Time to practice!"
        content.body = "Don't forget to practice your Swedish today. Lycka till!"
        content.sound = .default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: notificationTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: dailyReminderIdentifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule notification: \(error)")
            }
        }
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [dailyReminderIdentifier])
    }
}
