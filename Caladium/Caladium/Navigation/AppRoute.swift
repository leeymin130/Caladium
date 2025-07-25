//
//  AppRoute.swift
//  Caladium
//
//  Created by 이종선 on 6/15/25.
//

import Foundation
import UIKit

enum AppRoute: Hashable, Identifiable {
    // 메인 앱 플로우
    case home
    case projectDetail(Project)
    case photoDetail(Photo, Project)
    
    // 촬영 플로우
    case camera(CameraContext,  Photo?)
    case photoConfirm(UIImage, CameraContext)
    case saveNewProject(UIImage)
    
    // 영상 완료 플로우
    case animationResult(
        data: Data?,
        url: URL?,
        format: AnimationFormat,
        startDate: Date?,
        endDate: Date?
    )
    
    // Identifiable 구현
    var id: String {
        switch self {
        case .home:
            return "home"
        case .projectDetail(let project):
            return "project_\(project.id ?? UUID())"
        case .photoDetail(let photo, _):
            return "photo_\(photo.id ?? UUID())"
        case .camera(let context, _):
            return "camera_\(context.id)"
        case .photoConfirm(_, let context):
            return "photo_confirm_\(context.id)"
        case .saveNewProject(let image):
            return "save_new_project_\(image.hashValue)"
        case .animationResult(_, _, let format, _, _):
            return "animation_result_\(format.rawValue)"
        }
    }
}

enum OnboardingStep: Int, CaseIterable {
    case welcome = 0
    case features = 1
    case permissions = 2
    case complete = 3
    
    var next: OnboardingStep? {
        guard let nextCase = OnboardingStep(rawValue: self.rawValue + 1) else {
            return nil
        }
        return nextCase
    }
    
    var previous: OnboardingStep? {
        guard self.rawValue > 0,
              let prevCase = OnboardingStep(rawValue: self.rawValue - 1) else {
            return nil
        }
        return prevCase
    }
}

enum CameraContext: Hashable {
    case newProject // 새 식물 추가
    case existingProject(Project) // 기존 프로젝트에 사진 추가
    
    var id: String {
        switch self {
        case .newProject:
            return "new_project"
        case .existingProject(let project):
            return "existing_\(project.id ?? UUID())"
        }
    }
}

enum HomeEditMode : Hashable{
    case normal
    case delete(selectedProject: Set<Project>)
    case move(selectedProject: Set<Project>)
}

enum ProjectEditMode : Hashable{
    case normal
    case delete(selectedPhoto: Set<Photo>)
    case makeVideo(selectedPhoto: Set<Photo>)
}
