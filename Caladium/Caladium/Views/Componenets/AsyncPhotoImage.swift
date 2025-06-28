//
//  AsyncPhotoImage.swift
//  Caladium
//
//  Created by 이종선 on 6/28/25.
//

import SwiftUI

// MARK: - Environment Key for CoreDataService
struct CoreDataServiceKey: EnvironmentKey {
    static let defaultValue = CoreDataService()
}

extension EnvironmentValues {
    var coreDataService: CoreDataService {
        get { self[CoreDataServiceKey.self] }
        set { self[CoreDataServiceKey.self] = newValue }
    }
}

// MARK: - AsyncImage Component
struct AsyncPhotoImage: View {
    let photo: Photo
    @State private var image: UIImage?
    @State private var isLoading = true
    
    @Environment(\.coreDataService) private var coreDataService
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if isLoading {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .overlay(
                        ProgressView()
                            .scaleEffect(0.5)
                    )
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
        }
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        guard let fileName = photo.fileName else {
            isLoading = false
            return
        }
        
        Task {
            let loadedImage = await withCheckedContinuation { continuation in
                DispatchQueue.global(qos: .userInitiated).async {
                    let image = coreDataService.loadImageFromFile(fileName: fileName)
                    continuation.resume(returning: image)
                }
            }
            
            await MainActor.run {
                self.image = loadedImage
                self.isLoading = false
            }
        }
    }
}
