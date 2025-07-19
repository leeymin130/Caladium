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
    
    var body: some View {
        ZStack {
            
            Color.green50.ignoresSafeArea()
            
            VStack(spacing: 30) {
                // 미리보기 영역
                previewSection
                    .padding(.top)
                
                Spacer()
                
                bottomToolbar
                
            }

        }

    }
    
    private var bottomToolbar: some View {
        HStack {
            Spacer()
            
            Button {
            } label: {
                VStack {
                    Image(systemName: "square.and.arrow.up")
                        .font(.title2)
                    
                    Text("공유하기")
                        .font(.caption)
                }
            }
            
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: -1)
        
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
                                .font(.system(size: 15))
                                .fontWeight(.semibold)
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
                                .font(.system(size: 15))
                                .fontWeight(.semibold)
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
                            VStack(spacing: 12) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.largeTitle)
                                    .foregroundColor(.red)
                                Text("생성 실패")
                                    .font(.headline)
                                    .foregroundColor(.red)
                                Text("다시 시도해주세요")
                                    .font(.caption)
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
        formatter.dateStyle = .medium
        
        let startString = formatter.string(from: start)
        let endString = formatter.string(from: end)
        
        // 같은 날이면 하나만 표시
        if Calendar.current.isDate(start, equalTo: end, toGranularity: .day) {
            return startString
        } else {
            return "\(startString) ~ \(endString)"
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                exportAnimation()
            } label: {
                Label("사진앱에 저장", systemImage: "square.and.arrow.down")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(data == nil && url == nil)
            
            Button {
                shareAnimation()
            } label: {
                Label("공유하기", systemImage: "square.and.arrow.up")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(data == nil && url == nil)
        }
    }
    
    private func exportAnimation() {
        switch format {
        case .gif:
            if let data = data {
                // GIF를 사진앱에 저장
                saveGIFToPhotos(data: data)
            }
        case .mov:
            if let url = url {
                // 비디오를 사진앱에 저장
                saveMOVToPhotos(url: url)
            }
        }
    }
    
    private func shareAnimation() {
        // 공유 시트 표시
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
        
        if !itemsToShare.isEmpty {
            let activityVC = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.present(activityVC, animated: true)
            }
        }
    }
    
    private func saveGIFToPhotos(data: Data) {
        // GIF를 사진앱에 저장하는 로직
        print("GIF 저장: \(data.count) bytes")
        // 실제 구현에서는 PHPhotoLibrary 사용
    }
    
    private func saveMOVToPhotos(url: URL) {
        // 비디오를 사진앱에 저장하는 로직
        print("비디오 저장: \(url.path)")
        // 실제 구현에서는 PHPhotoLibrary 사용
    }
    
    private func createTempGIFFile(data: Data) -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let tempURL = tempDir.appendingPathComponent("shared_animation.gif")
        try? data.write(to: tempURL)
        return tempURL
    }
}

#Preview {
    AnimationResultView(data: nil, url: nil, format: .gif, startDate: nil, endDate: nil)
}
