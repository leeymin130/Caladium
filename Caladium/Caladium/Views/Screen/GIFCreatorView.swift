//
//  GIFCreatorView.swift
//  Caladium
//
//  Created by 이종선 on 7/3/25.
//

import SwiftUI

struct GIFCreatorView: View {
    @State private var sampleImages: [UIImage] = []
    @State private var generatedGIFData: Data?
    @State private var isCreatingGIF = false
    @State private var gifDuration: Double = 2.0
    @State private var showAlert = false
    @State private var alertMessage = ""
    
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
                
                // GIF 설정
                VStack {
                    HStack {
                        Text("GIF 지속시간:")
                        Slider(value: $gifDuration, in: 0.5...5.0, step: 0.1)
                        Text("\(gifDuration, specifier: "%.1f")초")
                    }
                    .padding(.horizontal)
                }
                
                // 버튼들
                VStack(spacing: 15) {
                    Button("샘플 이미지 로드") {
                        loadSampleImages()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isCreatingGIF)
                    
                    Button("GIF 생성") {
                        createGIF()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(sampleImages.isEmpty || isCreatingGIF)
                    
                    if isCreatingGIF {
                        ProgressView("GIF 생성 중...")
                            .progressViewStyle(CircularProgressViewStyle())
                    }
                }
                
                // GIF 미리보기
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
                
                Spacer()
            }
            .padding()
            .navigationTitle("GIF 생성기")
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
        
        isCreatingGIF = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            let gifData = GIFCreator.createGIF(from: sampleImages, duration: gifDuration)
            
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
