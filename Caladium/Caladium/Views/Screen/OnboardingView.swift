//
//  OnboardingView.swift
//  Caladium
//
//  Created by 이종선 on 6/22/25.
//

import SwiftUI

// MARK: - Onboarding Views
struct OnboardingContainerView: View {
    private var coordinator: AppCoordinator
    @State private var currentStep: OnboardingStep = .welcome
    
    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
        
    }
    
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

