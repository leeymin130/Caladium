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
    @State private var currentStep: OnboardingStep = .intro
    @State private var showCameraView: Bool = false
    
    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
        
    }
    
    var body: some View {
        if showCameraView {
            CameraOnboardingView(coordinator: coordinator)
        } else {
            TabView(selection: $currentStep) {
                //        case .intro:
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        RiveViewModel(fileName: "onborading1").view()
                            .padding(.top, 58)
                    }
                    .frame(maxHeight: .infinity, alignment: .center)
                    
                    VStack(spacing: 0) {
                        Image("onboarding1")
                            .padding(.bottom, 29)
                        
                        Text("사진으로 만드는 식물 기록 영상")
                            .customFont(.navigationBarTitle)
                            .padding(.bottom, 16)
                        
                        Text("긴 촬영 없이도 식물 타임랩스를 만들 수 있어요.")
                            .customFont(.categoryButtonBody)
                            .foregroundStyle(.gray600)
                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                }
                .tag(OnboardingStep.intro)
                
                //        case .guide:
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        RiveViewModel(fileName: "onboarding2").view()
                            .padding(.top, 58)
                    }
                    .frame(maxHeight: .infinity, alignment: .center)
                    
                    VStack(spacing: 0) {
                        Image("onboarding2")
                            .padding(.bottom, 29)
                        
                        Text("같은 자리에서 찍을 수 있도록")
                            .customFont(.navigationBarTitle)
                            .padding(.bottom, 16)
                        
                        Text("최근 사진 필터를 통해\n비슷한 구도로 쉽게 찍을 수 있어요.")
                            .customFont(.categoryButtonBody)
                            .foregroundStyle(.gray600)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                }
                .tag(OnboardingStep.guide)
                
                //        case .start:
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        RiveViewModel(fileName: "onboarding4").view()
                            .padding(.top, 58)
                    }
                    .frame(maxHeight: .infinity, alignment: .center)
                    
                    VStack(spacing: 0) {
                        Image("onboarding3")
                            .padding(.bottom, 29)
                        
                        Text("버튼 한 번이면 영상 완성")
                            .customFont(.navigationBarTitle)
                            .padding(.bottom, 16)
                        
                        Text("원하는 사진들을 선택해 영상을 만들고,\n저장하거나 공유할 수 있어요.")
                            .customFont(.categoryButtonBody)
                            .foregroundStyle(.gray600)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .padding(.bottom, 70)
                        
                        Button {
                            showCameraView = true
                            currentStep = .camera // 인디케이터 업데이트
                            
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
                    .frame(maxHeight: .infinity, alignment: .top)
                }
                .tag(OnboardingStep.start)
                
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.3), value: currentStep)
        }
        
    }
    
}

// MARK: - Camera 온보딩 화면 (별도 컴포넌트)
struct CameraOnboardingView: View {
    let coordinator: AppCoordinator
    @State private var currentStep: OnboardingStep = .camera
    
    var body: some View {
        //        case .camera:
        ZStack(alignment: .center) {
            Image("bg-picture")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 344, height: 233)
                .background(.gray0)
                .cornerRadius(14)
                .shadow(color: .gray900.opacity(0.25), radius: 1.5, x: 0, y: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .inset(by: 0.5)
                        .stroke(.gray400, lineWidth: 1)
                )
            
            VStack(spacing: 0) {
                Text("바로 사진을 찍어볼까요?")
                    .customFont(.navigationBarTitle)
                    .foregroundStyle(.gray900)
                    .padding(.bottom, 12)
                
                Text("사진을 촬영하고 저장하면,\n나만의 식물 프로젝트를 만들 수 있어요.")
                    .customFont(.categoryButtonBody)
                    .foregroundStyle(.gray600)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.bottom, 37)
                
                Button {
                    // 촬영화면 이동
                    coordinator.presentFullScreen(.camera(.newProject, nil))
                    coordinator.completeOnboarding()
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
                
            }
        }
    }
    
}



#Preview {
    OnboardingContainerView(coordinator: AppCoordinator())
}

