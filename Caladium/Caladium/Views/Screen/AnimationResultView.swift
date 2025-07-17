//
//  AnimationResultView.swift
//  Caladium
//
//  Created by 이종선 on 7/17/25.
//

import SwiftUI

struct AnimationResultView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    
    var body: some View {
        VStack(spacing: 30) {
            Text("🎉 완성!")
                .font(.largeTitle)
            
            Text("애니메이션이 완성되었습니다")
                .font(.title2)
            
            // 미리보기 영역
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.3))
                .aspectRatio(16/9, contentMode: .fit)
                .overlay {
                    Text("애니메이션 미리보기")
                        .font(.headline)
                }
            
            Spacer()
            
            VStack(spacing: 12) {
                Button {
                    // 저장 로직
                } label: {
                    Text("사진앱에 저장")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                
                Button {
                    // 공유 로직
                } label: {
                    Text("공유하기")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .navigationTitle("완성!")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    AnimationResultView()
        .environmentObject(AppCoordinator())
}
