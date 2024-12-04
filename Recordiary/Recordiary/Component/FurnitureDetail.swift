//
//  FurnitureDetail.swift
//  Recordiary
//
//  Created by 김민아 on 11/20/24.
//

import SwiftUI

struct FurnitureDetailContent: View {
    let detailedFurniture: DiaryConnectedFurniture // 가구 정보
    @State private var isPlaying = false // 재생 상태 저장

    var body: some View {
        ScrollView { // 스크롤 가능한 영역
            VStack(alignment: .leading, spacing: 16) { // 전체 왼쪽 정렬
                // 가구 이미지와 정보
                HStack(spacing: 16) {
                    RoundedRectangle(cornerRadius: 21)
                        .fill(Color(hex: "#E0E0E0"))
                        .frame(width: 100, height: 100)
                        .overlay(
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.gray)
                                .padding(8)
                        )

                    VStack(alignment: .leading, spacing: 4) {
                        Text(detailedFurniture.furniture.name)
                            .font(.system(size: 18, weight: .semibold))
                        Text(detailedFurniture.diary.local_date)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    // 재생 버튼
                    Button(action: {
                        isPlaying.toggle() // 재생 상태 토글
                    }) {
                        ZStack {
                            Circle() // 동그란 버튼
                                .fill(Color(hex: "#6DAFCF"))
                                .frame(width: 56, height: 56)
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill") // 상태에 따라 아이콘 변경
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                        }
                    }
                }

                // 섹션
                SectionView(title: "감정 추출 결과", content: detailedFurniture.diary.emotion.rawValue, hasContentBox: false, contentBoxStyle: .highlighted)
                SectionView(title: "키워드 요약", content: detailedFurniture.diary.keyWord, hasContentBox: true, contentBoxStyle: .regular)
                SectionView(title: "텍스트", content: detailedFurniture.diary.transcribedText, hasContentBox: true, contentBoxStyle: .regular)
            }
            .padding(16) // 모달 내 여백 추가
        }
    }
}

struct DiaryDetailContent: View {
    let detailedDiary: DiaryEntry // 가구 정보
    @State private var isPlaying = false // 재생 상태 저장

    var body: some View {
        ScrollView { // 스크롤 가능한 영역
            VStack(alignment: .leading, spacing: 16) { // 전체 왼쪽 정렬
                // 가구 이미지와 정보
                HStack(spacing: 16) {
                    Text(detailedDiary.local_date)
                        .font(.system(size: 18, weight: .semibold))

                    Spacer()
                    Button(action: {
                        isPlaying.toggle() // 재생 상태 토글
                    }) {
                        ZStack {
                            Circle() // 동그란 버튼
                                .fill(Color(hex: "#6DAFCF"))
                                .frame(width: 56, height: 56)
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill") // 상태에 따라 아이콘 변경
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                        }
                    }
                }

                // 섹션
                SectionView(title: "감정 추출 결과", content: detailedDiary.emotion.rawValue, hasContentBox: false, contentBoxStyle: .highlighted)
                SectionView(title: "키워드 요약", content: detailedDiary.keyWord, hasContentBox: true, contentBoxStyle: .regular)
                SectionView(title: "텍스트", content: detailedDiary.transcribedText, hasContentBox: true, contentBoxStyle: .regular)
            }
            .padding(16) // 모달 내 여백 추가
        }
    }
}


struct SectionView: View {
    let title: String
    let content: String // 감정의 rawValue 또는 기타 텍스트
    let hasContentBox: Bool // 내용 박스 유무
    let contentBoxStyle: ContentBoxStyle // 내용 스타일

    enum ContentBoxStyle {
        case regular      // 일반 텍스트
        case highlighted  // 강조된 스타일
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 제목 박스
            VStack(alignment: .leading) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(hex: "#6DAFCF"))
                    .frame(maxWidth: .infinity, alignment: .leading) // 왼쪽 상단 정렬
            }
            .frame(height: 30) // 제목 박스 높이
            .background(
                Rectangle()
                    .fill(Color.clear) // 투명 배경
                    .frame(height: 30) // 구분선 높이
                    .overlay(
                        Rectangle()
                            .fill(Color(hex: "#6DAFCF")) // 구분선 색상
                            .frame(height: 0.33),
                        alignment: .bottom // 하단에만 구분선 추가
                    )
            )

            // 내용 텍스트
            switch contentBoxStyle {
            case .regular:
                if hasContentBox {
                    Text(content)
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .padding() // 내용의 내부 여백
                        .background(
                            Rectangle() // 각진 네모 박스
                                .fill(Color.white) // 흰색 배경
                        )
                } else {
                    Text(content)
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                }

            case .highlighted:
                Text(content)
                    .font(.system(size: 16, weight: .bold)) // 강조된 텍스트
                    .foregroundColor(.white) // 흰색 텍스트
                    .frame(width: 67, height: 34) // 고정 크기
                    .background(
                        RoundedRectangle(cornerRadius: 40) // 곡률 40
                            .fill(colorForEmotion(content)) // 감정에 따른 색상 적용
                    )
                    .frame(maxWidth: .infinity, alignment: .leading) // 왼쪽 정렬
            }
        }
    }

    // 감정에 따른 색상 결정
    private func colorForEmotion(_ emotionRawValue: String) -> Color {
        switch emotionRawValue {
        case Emotion.anger.rawValue: return Emotion.anger.color
        case Emotion.sadness.rawValue: return Emotion.sadness.color
        case Emotion.happiness.rawValue: return Emotion.happiness.color
        case Emotion.neutral.rawValue: return Emotion.neutral.color
        default: return Color(hex: "#FFA726") // 기본 색상
        }
    }
}


func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.locale = Locale(identifier: "ko_KR")
    return formatter.string(from: date)
}
