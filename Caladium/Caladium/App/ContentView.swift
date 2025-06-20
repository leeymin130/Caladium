//
//  ContentView.swift
//  Caladium
//
//  Created by yoomin on 6/3/25.
//

import SwiftUI
import CoreData


struct ContentView: View {
    @StateObject private var coordinator = AppCoordinator()
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            rootView
        }
        .navigationDestination(for: AppRoute.self) { route in
            routeView(for: route)
        }
        .sheet(item: $coordinator.presentedSheet) { route in
            routeView(for: route)
        }
        .fullScreenCover(item: $coordinator.presentedFullScreen) { route in
            routeView(for: route)
        }
        .alert(item: $coordinator.showingAlert) { alertType in
            switch alertType {
            case .cameraEnvironmentCheck(let onConfirm, let onCancel):
                return Alert(
                    title: Text("촬영 환경 확인"),
                    message: Text("주위 환경을 확인해주세요."),
                    primaryButton: .default(Text("확인"), action: onConfirm),
                    secondaryButton: .cancel(Text("취소"), action: onCancel)
                )
                
            case .confirmDelete(let count, let onConfirm):
                return Alert(
                    title: Text("삭제 확인"),
                    message: Text("\(count)개의 프로젝트를 정말 삭제하시겠습니까?"),
                    primaryButton: .destructive(Text("삭제"), action: onConfirm),
                    secondaryButton: .cancel()
                )
                
            case .selectMoveCategory(_, _):
                return Alert(title: Text("카테고리 선택"))
            }
        }
        .confirmationDialog(
            "카테고리 선택",
            isPresented: .constant(coordinator.showingAlert?.id == "select_category"),
            presenting: coordinator.showingAlert
        ) { alertType in
            if case .selectMoveCategory(_, let onSelect) = alertType {
                ForEach(Category.allCases, id: \.self) { category in
                    Button(category.rawValue) {
                        onSelect(category)
                        coordinator.dismissAlert()
                    }
                }
                Button("취소", role: .cancel) {
                    coordinator.dismissAlert()
                }
            }
        }
        .environmentObject(coordinator)
    }
    
    @ViewBuilder
    private var rootView: some View {
        if coordinator.isOnboardingComplete {
            HomeView(vm:HomeViewModel(coordinator: coordinator))
        } else {
            OnboardingContainerView()
        }
    }
    
    @ViewBuilder
    private func routeView(for route: AppRoute) -> some View {
        switch route {
        case .home:
            HomeView(vm:HomeViewModel(coordinator: coordinator))
        case .projectDetail(let project):
            ProjectDetailView(project: project)
            
        case .photoDetail(let photo, let project):
            PhotoDetailView(photo: photo, project: project)
            
        case .camera(let context):
            CameraView(context: context)
            
        case .photoConfirm(let image, let context):
            PhotoConfirmView(image: image, context: context)
            
        case .videoPhotoSelection(let project):
            VideoPhotoSelectionView(project: project)
            
        case .videoGeneration(let photos):
            VideoGenerationView(photos: photos)
        }
    }
    
}

// MARK: - Onboarding Views
struct OnboardingContainerView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @State private var currentStep: OnboardingStep = .welcome
    
    var body: some View {
        VStack(spacing: 20) {
            Text("온보딩 - \(currentStep.rawValue + 1)/\(OnboardingStep.allCases.count)")
                .font(.title2)
                .bold()
            
            switch currentStep {
            case .welcome:
                VStack(spacing: 15) {
                    Text("🌱 Caladium에 오신 것을 환영합니다!")
                        .font(.title)
                    Text("식물의 성장을 기록하고 타임랩스 영상을 만들어보세요")
                        .foregroundColor(.secondary)
                }
                
            case .features:
                VStack(spacing: 15) {
                    Text("✨ 주요 기능")
                        .font(.title)
                    VStack(alignment: .leading, spacing: 10) {
                        Text("📸 정기적인 사진 촬영")
                        Text("🎬 타임랩스 영상 제작")
                        Text("🗂 카테고리별 정리")
                        Text("📈 성장 과정 추적")
                    }
                }
                
            case .permissions:
                VStack(spacing: 15) {
                    Text("📷 권한 설정")
                        .font(.title)
                    Text("카메라 권한이 필요합니다")
                        .foregroundColor(.secondary)
                    Button("권한 허용하기") {
                        // 실제로는 권한 요청 로직
                        currentStep = .complete
                    }
                    .buttonStyle(.borderedProminent)
                }
                
            case .complete:
                VStack(spacing: 15) {
                    Text("🎉 설정 완료!")
                        .font(.title)
                    Text("이제 첫 번째 식물을 추가해보세요")
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            HStack {
                if currentStep != .welcome {
                    Button("이전") {
                        if let previous = currentStep.previous {
                            currentStep = previous
                        }
                    }
                }
                
                Spacer()
                
                if currentStep == .complete {
                    Button("시작하기") {
                        coordinator.completeOnboarding()
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Button("다음") {
                        if let next = currentStep.next {
                            currentStep = next
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .padding()
    }
}

// MARK: - Project Card View
struct ProjectCardView: View {
    let project: Project
    @EnvironmentObject var coordinator: AppCoordinator
    
    var body: some View {
        Button {
            if coordinator.homeEditMode == .normal {
                coordinator.navigate(to: .projectDetail(project))
            } else {
                toggleSelection()
            }
        } label: {
            VStack(spacing: 8) {
                // 썸네일 이미지 (임시)
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.3))
                    .aspectRatio(4/3, contentMode: .fit)
                    .overlay {
                        VStack {
                            Image(systemName: project.categoryEnum.icon)
                                .font(.title)
                            Text("\(project.photoCount)장")
                                .font(.caption)
                        }
                        .foregroundColor(.gray)
                    }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("프로젝트 #\(project.id?.uuidString.prefix(8) ?? "Unknown")")
                        .font(.caption)
                        .foregroundColor(.primary)
                    
                    Text(project.createdDate?.formatted(date: .abbreviated, time: .omitted) ?? "")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(12)
            .background(Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                if isSelected {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue, lineWidth: 2)
                }
            }
        }
        .buttonStyle(.plain)
    }
    
    private var isSelected: Bool {
        switch coordinator.homeEditMode {
        case .delete(let selected), .move(let selected):
            return selected.contains(project)
        case .normal:
            return false
        }
    }
    
    private func toggleSelection() {
        switch coordinator.homeEditMode {
        case .delete(var selected):
            if selected.contains(project) {
                selected.remove(project)
            } else {
                selected.insert(project)
            }
            coordinator.homeEditMode = .delete(selectedProject: selected)
            
        case .move(var selected):
            if selected.contains(project) {
                selected.remove(project)
            } else {
                selected.insert(project)
            }
            coordinator.homeEditMode = .move(selectedProject: selected)
            
        case .normal:
            break
        }
    }
}

// MARK: - Project Detail View
struct ProjectDetailView: View {
    let project: Project
    @EnvironmentObject var coordinator: AppCoordinator
    
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
        ScrollView {
            VStack(spacing: 20) {
                // 프로젝트 정보
                VStack(spacing: 10) {
                    Text("📊 프로젝트 정보")
                        .font(.title2)
                        .bold()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("카테고리: \(project.categoryEnum.displayName)")
                        Text("생성일: \(project.createdDate?.formatted() ?? "")")
                        Text("마지막 업데이트: \(project.updatedDate?.formatted() ?? "")")
                        Text("사진 수: \(photos.count)장")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // 액션 버튼들
                VStack(spacing: 12) {
                    Button {
                        coordinator.addPhotoToProject(project)
                    } label: {
                        Label("사진 추가", systemImage: "camera")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    if photos.count >= 2 {
                        Button {
                            coordinator.startVideoCreation(for: project)
                        } label: {
                            Label("영상 만들기", systemImage: "video")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                }
                
                // 사진 그리드
                if !photos.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("📷 사진들")
                            .font(.title2)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 10) {
                            ForEach(photos, id: \.id) { photo in
                                Button {
                                    coordinator.navigate(to: .photoDetail(photo, project))
                                } label: {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(0.3))
                                        .aspectRatio(1, contentMode: .fit)
                                        .overlay {
                                            VStack {
                                                Image(systemName: "photo")
                                                Text(photo.capturedDate?.formatted(date: .abbreviated, time: .omitted) ?? "")
                                                    .font(.caption2)
                                            }
                                            .foregroundColor(.gray)
                                        }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("프로젝트 상세")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Photo Detail View
struct PhotoDetailView: View {
    let photo: Photo
    let project: Project
    @EnvironmentObject var coordinator: AppCoordinator
    
    var body: some View {
        VStack(spacing: 20) {
            // 사진 표시 영역 (임시)
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.3))
                .aspectRatio(4/3, contentMode: .fit)
                .overlay {
                    VStack {
                        Image(systemName: "photo")
                            .font(.system(size: 60))
                        Text("사진: \(photo.fileName ?? "Unknown")")
                            .font(.caption)
                    }
                    .foregroundColor(.gray)
                }
            
            // 사진 정보
            VStack(alignment: .leading, spacing: 8) {
                Text("📊 사진 정보")
                    .font(.title2)
                    .bold()
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("파일명: \(photo.fileName ?? "Unknown")")
                    Text("촬영일: \(photo.capturedDate?.formatted() ?? "")")
                    Text("프로젝트: \(project.categoryEnum.displayName)")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            Spacer()
            
            // 액션 버튼
            Button("삭제", role: .destructive) {
                // 삭제 로직 구현
                coordinator.goBack()
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .navigationTitle("사진 상세")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Camera View
struct CameraView: View {
    let context: CameraContext
    @EnvironmentObject var coordinator: AppCoordinator
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 20) {
                Text("📷 카메라")
                    .font(.largeTitle)
                    .bold()
                
                Text(contextDescription)
                    .foregroundColor(.secondary)
                
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.3))
                    .aspectRatio(4/3, contentMode: .fit)
                    .overlay {
                        Text("카메라 뷰 영역")
                            .foregroundColor(.gray)
                    }
            }
            
            Spacer()
            
            // 촬영 버튼
            Button {
                // 임시 이미지로 다음 단계로
                let tempImage = UIImage(systemName: "photo") ?? UIImage()
                coordinator.navigate(to: .photoConfirm(tempImage, context))
            } label: {
                Circle()
                    .fill(Color.white)
                    .frame(width: 80, height: 80)
                    .overlay {
                        Circle()
                            .stroke(Color.black, lineWidth: 3)
                            .frame(width: 70, height: 70)
                    }
            }
            .padding(.bottom, 50)
        }
        .background(Color.black)
        .foregroundColor(.white)
        .navigationBarHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("취소") {
                    coordinator.dismissFullScreen()
                }
                .foregroundColor(.white)
            }
        }
    }
    
    private var contextDescription: String {
        switch context {
        case .newProject:
            return "새로운 식물의 첫 번째 사진을 찍어보세요"
        case .existingProject(let project):
            return "\(project.categoryEnum.displayName) 프로젝트에 사진을 추가합니다"
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
