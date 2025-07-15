//
//  PhotoConfirmationView.swift
//  Caladium
//
//  Created by yoomin on 7/16/25.
//

import SwiftUI

struct PhotoConfirmationView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    let image: UIImage
    let context: CameraContext
    
    var body: some View {
        VStack {
            
            Button {
                coordinator.retakePhoto()
            } label: {
                Text("재촬영")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.8))
                    .cornerRadius(10)
            }
            
            Button {
                coordinator.confirmPhoto(image, context: context)
            } label: {
                Text("확인")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green500)
                    .cornerRadius(10)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .navigationBarHidden(true)
    }
}

#Preview {
    let dummyImage = UIImage(systemName: "photo") ?? UIImage()
    return PhotoConfirmationView(image: dummyImage, context: .newProject) // 미리보기 이름 변경
        .environmentObject(AppCoordinator())
}
