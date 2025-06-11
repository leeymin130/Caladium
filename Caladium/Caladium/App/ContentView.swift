//
//  ContentView.swift
//  Caladium
//
//  Created by yoomin on 6/3/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    // @Environment를 사용하여 Core Data 컨텍스트를 주입받습니다.
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var vm: TestViewModel
    
    init() {
        // 싱글턴을 통해 context 생성하고 주입 주입
        let context = CoreDataStack.shared.context
        _vm = StateObject(wrappedValue: TestViewModel(context: context))
    }
    
    var body: some View {
        NavigationView {
            List {
                // MARK: - Read (프로젝트 목록 표시)
                ForEach(vm.projects) { project in
                    VStack(alignment: .leading) {
                        Text(project.name ?? "이름 없음").font(.headline)
                        Text("카테고리: \(Category(rawValue: project.category ?? "")?.displayName ?? "알 수 없음")")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("생성일: \(project.createdDate ?? Date(), formatter: dateFormatter)")
                            .font(.caption)
                        Text("수정일: \(project.updatedDate ?? Date(), formatter: dateFormatter)")
                            .font(.caption)
                        
                        // MARK: - Add Photo (사진 추가)
                        Button("사진 추가") {
                            vm.addPhoto(to: project)
                        }
                        .font(.caption)
                        .padding(.vertical, 2)
                        
                        // 해당 프로젝트의 사진 목록
                        if let photos = project.photos as? Set<Photo>, !photos.isEmpty {
                            VStack(alignment: .leading) {
                                Text("📸 사진 목록:")
                                ForEach(Array(photos).sorted(by: { ($0.capturedDate ?? Date()) < ($1.capturedDate ?? Date()) }), id: \.id) { photo in
                                    HStack {
                                        Text(" - \(photo.fileName ?? "파일 없음")")
                                        Spacer()
                                        // MARK: - Delete Photo (사진 삭제)
                                        Button("삭제") {
                                            vm.deletePhoto(photo)
                                        }
                                        .font(.caption)
                                        .foregroundColor(.red)
                                    }
                                }
                            }
                            .padding(.leading, 10)
                        } else {
                            Text("등록된 사진 없음").font(.caption).foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 5)
                    .contextMenu { // 컨텍스트 메뉴를 통한 수정/삭제
                        // MARK: - Update (프로젝트 수정)
                        Button("이름 변경") {
                            vm.updateProjectName(project)
                        }
                        // MARK: - Delete (프로젝트 삭제)
                        Button("삭제") {
                            vm.deleteProject(project)
                        }
                        .foregroundColor(.red)
                    }
                }
                // 스와이프 삭제 (프로젝트)
                .onDelete { indexSet in
                    indexSet.map { vm.projects[$0] }.forEach(vm.deleteProject)
                }
            }
            .navigationTitle("내 프로젝트")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    // MARK: - Create (새 프로젝트 생성)
                    Button("새 프로젝트") {
                        vm.createProject()
                    }
                }
                // MARK: - 모든 데이터 삭제 버튼 추가
                ToolbarItem(placement: .navigationBarLeading) { // 왼쪽에 배치
                    Button("모든 데이터 삭제") {
                        vm.deleteAllProjects()
                    }
                    .foregroundColor(.red) // 삭제 버튼은 빨간색으로
                }
            }
        }
    }

    
    // 날짜 포맷터
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
}

// MARK: - Preview Provider (Xcode Canvas 미리보기용)
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // 프리뷰에서 Core Data 컨텍스트를 제공하기 위한 설정
        ContentView().environment(\.managedObjectContext, CoreDataStack.shared.context)
    }
}

//#Preview {
//    ContentView()
//}
