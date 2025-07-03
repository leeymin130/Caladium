//
//  GIFCreatorView.swift
//  Caladium
//
//  Created by 이종선 on 7/3/25.
//

import SwiftUI

// MARK: - Main View
struct GIFCreatorView: View {
    @State private var sampleImages: [UIImage] = []
    @State private var generatedGIFData: Data?
    @State private var generatedVideoURL: URL?
    @State private var isCreatingGIF = false
    @State private var isCreatingVideo = false
    @State private var animationDuration: Double = 2.0
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var selectedFormat: AnimationFormat = .gif
    
    enum AnimationFormat: String, CaseIterable {
        case gif = "GIF"
        case mov = "MOV"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 샘플 이미지 미리보기
                if !sampleImages.isEmpty {
                    VStack {
                        Text("샘플 이미지 (\(sampleImages.count)장)")
                            .font(.headline)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(0..<sampleImages.count, id: \.self) { index in
                                    Image(uiImage: sampleImages[index])
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 80, height: 80)
                                        .cornerRadius(8)
                                        .border(Color.gray, width: 1)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                } else {
                    VStack {
                        Text("샘플 이미지를 찾을 수 없습니다")
                            .foregroundColor(.red)
                        Text("Asset에 sample1 ~ sample6 이미지가 있는지 확인해주세요")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                // 애니메이션 형식 선택
                VStack {
                    Text("애니메이션 형식")
                        .font(.headline)
                    
                    Picker("형식 선택", selection: $selectedFormat) {
                        ForEach(AnimationFormat.allCases, id: \.self) { format in
                            Text(format.rawValue).tag(format)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                }
                
                // 애니메이션 설정
                VStack {
                    HStack {
                        Text("애니메이션 지속시간:")
                        Slider(value: $animationDuration, in: 0.5...5.0, step: 0.1)
                        Text("\(animationDuration, specifier: "%.1f")초")
                    }
                    .padding(.horizontal)
                }
                
                // 버튼들
                VStack(spacing: 15) {
                    Button("샘플 이미지 로드") {
                        loadSampleImages()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isCreatingGIF || isCreatingVideo)
                    
                    Button("\(selectedFormat.rawValue) 생성") {
                        if selectedFormat == .gif {
                            createGIF()
                        } else {
                            createVideo()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(sampleImages.isEmpty || isCreatingGIF || isCreatingVideo)
                    
                    if isCreatingGIF {
                        ProgressView("GIF 생성 중...")
                            .progressViewStyle(CircularProgressViewStyle())
                    }
                    
                    if isCreatingVideo {
                        ProgressView("MOV 생성 중...")
                            .progressViewStyle(CircularProgressViewStyle())
                    }
                }
                
                // 미리보기
                if let gifData = generatedGIFData {
                    VStack {
                        Text("GIF 미리보기")
                            .font(.headline)
                        
                        GIFPreviewView(gifData: gifData)
                            .frame(height: 250)
                            .border(Color.gray, width: 1)
                            .cornerRadius(8)
                        
                        Button("GIF 저장") {
                            saveGIF(data: gifData)
                        }
                        .buttonStyle(.bordered)
                    }
                }
                
                if let videoURL = generatedVideoURL {
                    VStack {
                        Text("MOV 미리보기")
                            .font(.headline)
                        
                        MOVPreviewView(videoURL: videoURL)
                            .frame(height: 250)
                            .border(Color.gray, width: 1)
                            .cornerRadius(8)
                        
                        Button("MOV 저장") {
                            saveMOV(url: videoURL)
                        }
                        .buttonStyle(.bordered)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("애니메이션 생성기")
        }
        .alert("알림", isPresented: $showAlert) {
            Button("확인") { }
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            loadSampleImages()
        }
    }
    
    private func loadSampleImages() {
        sampleImages = SampleImageLoader.loadSampleImages()
        
        if sampleImages.isEmpty {
            alertMessage = "Asset에서 샘플 이미지를 찾을 수 없습니다. sample1~sample6 이미지가 있는지 확인해주세요."
            showAlert = true
        }
    }
    
    private func createGIF() {
        guard !sampleImages.isEmpty else { return }
        
        // 이전 결과 초기화
        generatedVideoURL = nil
        
        isCreatingGIF = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            let gifData = GIFCreator.createGIF(from: sampleImages, duration: animationDuration)
            
            DispatchQueue.main.async {
                self.isCreatingGIF = false
                
                if let data = gifData {
                    self.generatedGIFData = data
                    self.alertMessage = "GIF가 성공적으로 생성되었습니다!"
                } else {
                    self.alertMessage = "GIF 생성에 실패했습니다."
                }
                
                self.showAlert = true
            }
        }
    }
    
    private func createVideo() {
        guard !sampleImages.isEmpty else { return }
        
        // 이전 결과 초기화
        generatedGIFData = nil
        
        isCreatingVideo = true
        
        // 임시 파일 경로 생성
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let outputURL = documentsPath.appendingPathComponent("temp_animation.mov")
        
        VideoCreator.createVideo(from: sampleImages, outputURL: outputURL, duration: animationDuration) { success in
            self.isCreatingVideo = false
            
            if success {
                self.generatedVideoURL = outputURL
                self.alertMessage = "MOV 파일이 성공적으로 생성되었습니다!"
            } else {
                self.alertMessage = "MOV 생성에 실패했습니다."
            }
            
            self.showAlert = true
        }
    }
    
    private func saveGIF(data: Data) {
        // 임시 파일로 저장
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let gifURL = documentsPath.appendingPathComponent("generated_animation.gif")
        
        do {
            try data.write(to: gifURL)
            alertMessage = "GIF가 문서 폴더에 저장되었습니다.\n경로: \(gifURL.path)"
        } catch {
            alertMessage = "GIF 저장에 실패했습니다: \(error.localizedDescription)"
        }
        
        showAlert = true
    }
    
    private func saveMOV(url: URL) {
        // 최종 저장 경로
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let finalURL = documentsPath.appendingPathComponent("generated_animation.mov")
        
        do {
            // 기존 파일이 있다면 삭제
            if FileManager.default.fileExists(atPath: finalURL.path) {
                try FileManager.default.removeItem(at: finalURL)
            }
            
            // 파일 복사
            try FileManager.default.copyItem(at: url, to: finalURL)
            alertMessage = "MOV 파일이 문서 폴더에 저장되었습니다.\n경로: \(finalURL.path)"
        } catch {
            alertMessage = "MOV 저장에 실패했습니다: \(error.localizedDescription)"
        }
        
        showAlert = true
    }
}

// MARK: - Preview
struct GIFCreatorView_Previews: PreviewProvider {
    static var previews: some View {
        GIFCreatorView()
    }
}

class SampleImageLoader {
    static func loadSampleImages() -> [UIImage] {
        var images: [UIImage] = []
        
        for i in 1...6 {
            if let image = UIImage(named: "sample\(i)") {
                images.append(image)
            } else {
                print("Warning: sample\(i) 이미지를 찾을 수 없습니다.")
            }
        }
        
        return images
    }
}
