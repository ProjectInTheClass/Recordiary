//
//  CalendarViewModel.swift
//  Recordiary
//
//  Created by 김민아 on 12/3/24.
//

import SwiftUI

class CalendarViewModel: ObservableObject {
    @Published var entries: [DiaryEntry] = diaryDummyData  // 일기 더미 데이터
    @Published var selectedDiary: DiaryEntry? = nil  // 선택된 일기
    @Published var currentMonth: Date = Date()  // 현재 달

    init() {
        populateEntries()
    }
    // 현재 달의 일기만 필터링
    var filteredEntries: [DiaryEntry] {
        entries.filter {
            Calendar.current.isDate(
                $0.created_at, equalTo: currentMonth, toGranularity: .month)
        }
    }
    
    func populateEntries() {
        Task {
            let userId = BASE_USER_ID
            let client = APIClient()
            let result = await client.getCalendar(
                userId: userId, year: 2024, month: 12)
            let entries = try result.get()
            await MainActor.run {
                self.selectedDiary = nil
                self.entries = entries.map { e in
                    toDiaryEntry(calendarEntry: e)
                }
            }
        }
    }

    func addDiaryEntry(_ diary: DiaryEntry) {
        entries.append(diary)
    }

    // 날짜별 색상 결정
    func colorForDate(_ date: Date) -> Color {
        if let entry = entries.first(where: {
            Calendar.current.isDate($0.created_at, inSameDayAs: date)
        }) {
            return entry.emotion.color.opacity(0.3)
        }
        return Color.clear
    }

    // 감정 통계 계산
    func emotionStatistics() -> [(
        emotion: Emotion, count: Int, percentage: Double
    )] {
        let totalEntries = filteredEntries.count
        guard totalEntries > 0 else { return [] }

        return Emotion.allCases.map { emotion in
            let count = filteredEntries.filter { $0.emotion == emotion }.count
            let percentage = (Double(count) / Double(totalEntries)) * 100
            return (emotion: emotion, count: count, percentage: percentage)
        }
    }

    // 현재 달 업데이트
    func updateMonth(by offset: Int) {
        currentMonth =
            Calendar.current.date(
                byAdding: .month, value: offset, to: currentMonth)
            ?? currentMonth
    }
}
