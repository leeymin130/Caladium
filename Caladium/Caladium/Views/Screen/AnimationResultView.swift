//
//  AnimationResultView.swift
//  Caladium
//
//  Created by 이종선 on 7/17/25.
//

import SwiftUI

// MARK: - 애니메이션 결과 뷰 (실제 미리보기 포함)
struct AnimationResultView: View {
    let data: Data?
    let url: URL?
    let format: AnimationFormat
    let startDate: Date?
    let endDate: Date?
    @EnvironmentObject var coordinator: AppCoordinator
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var isButtonPressed = false
    
    var body: some View {
        ZStack {
            Image("bg-growing")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 상단 툴바 영역
                HStack {
                    Button {
                        // 햅틱 피드백 추가
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                        
                        // 뒤로가기
                        dismiss()
                    } label: {
                        Image("arrow-back-green700")
                            .padding(.horizontal, 24)
                    }
                    
                    Spacer()
                }
                .frame(height: 68)
                .padding(.top, 54)
//                .padding(.bottom, 10)
                
                Text("영상이 완성되었습니다!")
                    .customFont(.navigationBarTitle)
                    .foregroundColor(.gray900)
                
                // 미리보기 영역
                previewSection
                
                Spacer()
                
                bottomToolbar
                    .padding(.bottom, 14)
                
            }
            .navigationBarHidden(true)
            
        }
        
    }
    
    private var bottomToolbar: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.green500)
                .frame(height: 5)
                .frame(maxWidth: .infinity)
            
            HStack {
                Spacer()
                
                Button {
                    shareAnimation()
                } label: {
                    Image(isButtonPressed ? "btn-export-1" : "btn-export-0")
                }
                .buttonStyle(PlainButtonStyle())
                .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                    isButtonPressed = pressing
                }, perform: {})
                
            }
            .background(Color.gray0)
            
        }
        
    }
    
    private var previewSection: some View {
        VStack(spacing: 16) {
            // 실제 애니메이션 미리보기
            Group {
                if format == .gif, let gifData = data {
                    
                    VStack(alignment: .leading, spacing: 8){
                        GIFPreviewView(gifData: gifData)
                            .cornerRadius(5)
                        
                        if let start = startDate, let end = endDate {
                            Text(dateRangeText(start: start, end: end))
                                .customFont(.photoDate)
                                .foregroundStyle(.gray900)
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 18)
                    .padding(.bottom, 48)
                    .background(.gray0)
                    .cornerRadius(14)
                    .shadow(color: .gray900.opacity(0.25), radius: 2, x: 0, y: 3)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .inset(by: 0.5)
                            .stroke(Color.gray400, lineWidth: 1)
                    )
                    
                    
                } else if format == .mov, let videoURL = url {
                    
                    
                    VStack(alignment: .leading, spacing: 8){
                        MOVPreviewView(videoURL: videoURL)
                            .cornerRadius(5)
                        
                        if let start = startDate, let end = endDate {
                            Text(dateRangeText(start: start, end: end))
                                .customFont(.photoDate)
                                .foregroundStyle(.gray900)
                        }
                        
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 18)
                    .padding(.bottom, 48)
                    .background(.gray0)
                    .cornerRadius(14)
                    .shadow(color: .gray900.opacity(0.25), radius: 2, x: 0, y: 3)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .inset(by: 0.5)
                            .stroke(Color.gray400, lineWidth: 1)
                    )
                    
                } else {
                    // 실패한 경우
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.3))
                        .cornerRadius(5)
                        .frame(maxWidth: 320, maxHeight: 420)
                        .overlay {
                            VStack(spacing: 5) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.largeTitle)
                                    .foregroundColor(.red)
                                Text("생성 실패")
                                    .customFont(.categoryTitle)
                                    .foregroundColor(.red)
                                Text("다시 시도해주세요")
                                    .customFont(.categoryButtonBody)
                                    .foregroundColor(.secondary)
                            }
                        }
                }
            }
            
        }
        .frame(maxWidth: 350, maxHeight: 520)
        .padding(.top)
        
    }
    
    private func dateRangeText(start: Date, end: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "ko_KR")
        
        let startString = formatter.string(from: start)
        let endString = formatter.string(from: end)
        
        // 같은 날이면 하나만 표시
        if Calendar.current.isDate(start, equalTo: end, toGranularity: .day) {
            return startString
        } else {
            return "\(startString) ~ \(endString)"
        }
    }
    
    private func createTempGIFFile(data: Data) -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let tempURL = tempDir.appendingPathComponent("shared_animation.gif")
        try? data.write(to: tempURL)
        return tempURL
    }
    
    private func shareAnimation() {
        // 공유할 아이템 준비
        var itemsToShare: [Any] = []
        
        switch format {
        case .gif:
            if let data = data {
                // GIF 데이터를 임시 파일로 저장해서 공유
                let tempURL = createTempGIFFile(data: data)
                itemsToShare.append(tempURL)
            }
        case .mov:
            if let url = url {
                itemsToShare.append(url)
            }
        }
        
        // 공유 텍스트 추가 (선택사항)
        if let start = startDate, let end = endDate {
            let dateText = dateRangeText(start: start, end: end)
            let shareText = "📸 \(dateText) 기간의 성장 기록 애니메이션"
            itemsToShare.append(shareText)
        }
        
        guard !itemsToShare.isEmpty else { return }
        
        // UIActivityViewController 표시
        presentActivityController(with: itemsToShare)
    }
    
    private func presentActivityController(with items: [Any]) {
        let activityVC = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        
        // 특정 액티비티 제외 (필요에 따라)
        activityVC.excludedActivityTypes = [
            .assignToContact,
            .addToReadingList,
            .openInIBooks
        ]
        
        // 완료 핸들러
        activityVC.completionWithItemsHandler = { activityType, completed, returnedItems, error in
            if completed {
                print("공유 완료: \(activityType?.rawValue ?? "unknown")")
            }
            if let error = error {
                print("공유 에러: \(error.localizedDescription)")
            }
        }
        
        // 현재 뷰 컨트롤러에서 표시
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootViewController = window.rootViewController {
            
            // 가장 위의 뷰 컨트롤러 찾기
            var topViewController = rootViewController
            while let presentedViewController = topViewController.presentedViewController {
                topViewController = presentedViewController
            }
            
            topViewController.present(activityVC, animated: true)
        }
    }
}

#Preview {
    AnimationResultView(data: nil, url: nil, format: .gif, startDate: nil, endDate: nil)
}
