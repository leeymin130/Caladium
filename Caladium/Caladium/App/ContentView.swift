//
//  ContentView.swift
//  Caladium
//
//  Created by yoomin on 6/3/25.
//

import SwiftUI
import CoreData


struct ContentView: View {
    @StateObject private var coordinator: AppCoordinator
    @Environment(\.dependencies) private var dependencies
    
    init(coordinator: AppCoordinator){
        self._coordinator = StateObject(wrappedValue: coordinator)
    }
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            rootView
                .navigationDestination(for: AppRoute.self) { route in
                    routeView(for: route)
                }
        }
        .sheet(item: $coordinator.presentedSheet) { route in
            routeView(for: route)
        }
        .fullScreenCover(item: $coordinator.presentedFullScreen) { route in
            routeView(for: route)
        }
        .tint(.green500)
    }
    
    @ViewBuilder
    private var rootView: some View {
        if coordinator.isOnboardingComplete {
            HomeView(vm: dependencies.makeHomeViewModel())
        } else {
            OnboardingContainerView(coordinator: coordinator)
        }
    }
    
    @ViewBuilder
    private func routeView(for route: AppRoute) -> some View {
        switch route {
        case .home:
            HomeView(vm:dependencies.makeHomeViewModel())
            
        case .projectDetail(let project):
            ProjectDetailView(vm: dependencies.makeProjectDetailViewModel(), project: project)
            
        case .photoDetail(let photo, let project):
            PhotoDetailView(photo: photo)
            
        case .camera(let context):
            CameraView(vm: CameraViewModel(coordinator: coordinator), context: context)
            
        case .photoConfirm(let image, let context):
            PhotoConfirmView(image: image, context: context)
            
        case .videoPhotoSelection(let project):
            VideoPhotoSelectionView(project: project)
            
        case .videoGeneration(let photos):
            VideoGenerationView(photos: photos)
        }
    }
    
}

// MARK: - Photo Confirm View
struct PhotoConfirmView: View {
    let image: UIImage
    let context: CameraContext
    @EnvironmentObject var coordinator: AppCoordinator
    
    var body: some View {
        VStack(spacing: 20) {
            Text("📸 사진 확인")
                .font(.title2)
                .bold()
            
            // 촬영된 이미지 (임시)
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.3))
                .aspectRatio(4/3, contentMode: .fit)
                .overlay {
                    VStack {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        Text("촬영 완료!")
                    }
                }
            
            Text(contextDescription)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            // 액션 버튼들
            VStack(spacing: 12) {
                Button {
                    coordinator.confirmPhoto(image, context: context)
                } label: {
                    Text("사용하기")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                
                Button {
                    coordinator.retakePhoto()
                } label: {
                    Text("다시 찍기")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .navigationBarHidden(true)
    }
    
    private var contextDescription: String {
        switch context {
        case .newProject:
            return "이 사진으로 새 프로젝트를 시작하시겠습니까?"
        case .existingProject:
            return "이 사진을 프로젝트에 추가하시겠습니까?"
        }
    }
}

// MARK: - Video Photo Selection View
struct VideoPhotoSelectionView: View {
    let project: Project
    @EnvironmentObject var coordinator: AppCoordinator
    @State private var selectedPhotos: Set<Photo> = []
    
    @FetchRequest private var photos: FetchedResults<Photo>
    
    init(project: Project) {
        self.project = project
        self._photos = FetchRequest(
            entity: Photo.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Photo.capturedDate, ascending: true)],
            predicate: NSPredicate(format: "project == %@", project)
        )
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(spacing: 10) {
                    Text("🎬 영상 제작")
                        .font(.title2)
                        .bold()
                    
                    Text("영상에 포함할 사진들을 선택해주세요\n(최소 2장 이상)")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                Text("선택된 사진: \(selectedPhotos.count)장")
                    .font(.headline)
                
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 10) {
                        ForEach(photos, id: \.id) { photo in
                            Button {
                                toggleSelection(photo)
                            } label: {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.3))
                                    .aspectRatio(1, contentMode: .fit)
                                    .overlay {
                                        VStack {
                                            Image(systemName: selectedPhotos.contains(photo) ? "checkmark.circle.fill" : "photo")
                                                .font(.title2)
                                                .foregroundColor(selectedPhotos.contains(photo) ? .blue : .gray)
                                            
                                            Text(photo.capturedDate?.formatted(date: .abbreviated, time: .omitted) ?? "")
                                                .font(.caption2)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .overlay {
                                        if selectedPhotos.contains(photo) {
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.blue, lineWidth: 2)
                                        }
                                    }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
                
                Button {
                    coordinator.createVideoWithPhotos(Array(selectedPhotos))
                } label: {
                    Text("영상 만들기")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(selectedPhotos.count < 2)
            }
            .padding()
            .navigationTitle("사진 선택")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        coordinator.dismissSheet()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("전체 선택") {
                        if selectedPhotos.count == photos.count {
                            selectedPhotos.removeAll()
                        } else {
                            selectedPhotos = Set(photos)
                        }
                    }
                }
            }
        }
    }
    
    private func toggleSelection(_ photo: Photo) {
        if selectedPhotos.contains(photo) {
            selectedPhotos.remove(photo)
        } else {
            selectedPhotos.insert(photo)
        }
    }
}

// MARK: - Video Generation View
struct VideoGenerationView: View {
    let photos: [Photo]
    @EnvironmentObject var coordinator: AppCoordinator
    @State private var isGenerating = false
    @State private var progress: Double = 0.0
    @State private var isCompleted = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                VStack(spacing: 15) {
                    Text("🎬 영상 생성 중...")
                        .font(.title2)
                        .bold()
                    
                    Text("\(photos.count)장의 사진으로 타임랩스를 만들고 있습니다")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // 프로그레스
                VStack(spacing: 10) {
                    ProgressView(value: progress, total: 1.0)
                        .progressViewStyle(.linear)
                    
                    Text("\(Int(progress * 100))% 완료")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // 미리보기 영역
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.3))
                    .aspectRatio(16/9, contentMode: .fit)
                    .overlay {
                        if isCompleted {
                            VStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.green)
                                Text("영상 생성 완료!")
                                    .font(.headline)
                            }
                        } else {
                            VStack {
                                ProgressView()
                                    .scaleEffect(1.5)
                                Text("영상 처리 중...")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                
                Spacer()
                
                if isCompleted {
                    VStack(spacing: 12) {
                        Button {
                            // 영상 저장 로직
                            print("영상 저장됨")
                        } label: {
                            Label("사진앱에 저장", systemImage: "square.and.arrow.down")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button {
                            // 영상 공유 로직
                            print("영상 공유")
                        } label: {
                            Label("공유하기", systemImage: "square.and.arrow.up")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        
                        Button("완료") {
                            coordinator.completeVideoGeneration()
                        }
                        .buttonStyle(.bordered)
                    }
                } else {
                    Button("취소") {
                        coordinator.dismissSheet()
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
            .navigationTitle("영상 생성")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
        }
        .onAppear {
            startVideoGeneration()
        }
    }
    
    private func startVideoGeneration() {
        isGenerating = true
        
        // 가짜 진행률 시뮬레이션
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            progress += 0.02
            
            if progress >= 1.0 {
                progress = 1.0
                isGenerating = false
                isCompleted = true
                timer.invalidate()
            }
        }
    }
}
