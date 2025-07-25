//
//  OnboardingView.swift
//  Caladium
//
//  Created by 이종선 on 6/22/25.
//

import SwiftUI
import RiveRuntime

// MARK: - Onboarding Views
struct OnboardingContainerView: View {
    private var coordinator: AppCoordinator
    @State private var currentStep: OnboardingStep = .welcome
    
    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
        
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Text("온보딩 - \(currentStep.rawValue + 1)/\(OnboardingStep.allCases.count)")
                .font(.title2)
                .bold()
            
            switch currentStep {
            case .welcome:
                VStack(spacing: 0) {
                    RiveViewModel(fileName: "onborading1").view()

                    Image("onboarding1")
                        .padding(.bottom, 31)
                    Text("사진으로 만드는 식물 기록 영상")
                        .customFont(.navigationBarTitle)
                        .padding(.bottom, 16)
                    Text("긴 촬영 없이도 식물 타임랩스를 만들 수 있어요.")
                        .customFont(.categoryButtonBody)
                        .foregroundStyle(.gray600)
                        .padding(.bottom, 221)
                    
                }
                
                
            case .features:
                VStack(spacing: 0) {
                    RiveViewModel(fileName: "onboarding2").view()
      
                    Image("onboarding2")
                        .padding(.bottom, 31)
                    Text("같은 자리에서 찍을 수 있도록")
                        .customFont(.navigationBarTitle)
                        .padding(.bottom, 16)
                    Text("최근 사진 필터를 통해\n비슷한 구도로 쉽게 찍을 수 있어요.")
                        .customFont(.categoryButtonBody)
                        .foregroundStyle(.gray600)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 204)
                }
                
            case .permissions:
                VStack(spacing: 0) {
                    RiveViewModel(fileName: "onboarding4").view()
               
                    Image("onboarding3")
                    Text("버튼 한 번이면 영상 완성")
                        .customFont(.navigationBarTitle)
                    Text("원하는 사진들을 선택해 영상을 만들고,\n저장하거나 공유할 수 있어요.")
                        .customFont(.categoryButtonBody)
                        .foregroundStyle(.gray600)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 70)
                    
                    Button {
                        // 다음 화면으로 이동
                        currentStep = .complete
                    } label: {
                        Text("칼라디움 시작하기")
                            .customFont(.categoryButtonTitle)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 12)
                            .foregroundColor(.gray0)
                            .background(Color.green500)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(.green700, lineWidth: 1)
                            )
                    }
                    
                }
                
            case .complete:
                ZStack(alignment: .leading) {
                    Image("bg-picture")
                        .resizable()
                        .scaledToFit()
                        .ignoresSafeArea()
                    VStack(spacing: 0) {
                        Text("지금 바로 식물을 찍어볼까요?")
                            .customFont(.navigationBarTitle)
                            .foregroundStyle(.gray900)
                        Text("가볍게 식물 타임랩스 만들기를 시작해보세요.")
                            .customFont(.categoryButtonBody)
                            .foregroundStyle(.gray600)
                        Button {
                            // 촬영화면 이동
                            currentStep = .complete
                        } label: {
                            Text("사진 찍기")
                                .customFont(.categoryButtonTitle)
                                .padding(.horizontal, 32)
                                .padding(.vertical, 12)
                                .foregroundColor(.gray0)
                                .background(Color.green500)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(.green700, lineWidth: 1)
                                )
                        }
                        .padding(.bottom, 95)
                    }
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

#Preview {
    OnboardingContainerView(coordinator: AppCoordinator())
}

