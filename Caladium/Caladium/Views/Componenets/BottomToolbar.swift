//
//  BottomToolbar.swift
//  Caladium
//
//  Created by yoomin on 7/20/25.
//

import SwiftUI

// MARK: - Bottom Toolbar Style
enum BottomToolbarStyle {
    case home
    case projectDetail
}

// MARK: - Custom Button with Pressed State
struct PressableButton: View {
    let normalImageName: String
    let pressedImageName: String
    let action: () -> Void
    let isDisabled: Bool
    
    @State private var isPressed = false
    
    init(
        normalImage: String,
        pressedImage: String? = nil,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.normalImageName = normalImage
        // pressed 이미지가 없으면 normal 이미지에서 -0을 -1로 변경
        self.pressedImageName = pressedImage ?? normalImage.replacingOccurrences(of: "-0", with: "-1")
        self.isDisabled = isDisabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Image(isPressed && !isDisabled ? pressedImageName : normalImageName)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isDisabled)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            if !isDisabled {
                isPressed = pressing
            }
        }, perform: {})
    }
}

struct BottomToolbar: View {
    let homeEditMode: HomeEditMode?
    let projectEditMode: ProjectEditMode?
    let style: BottomToolbarStyle
    let hasItems: Bool
    
    let onDeleteStart: () -> Void
    let onMoveStart: () -> Void
    let onCancel: () -> Void
    let onDeleteConfirm: () -> Void
    let onMoveConfirm: () -> Void
    let onVideoStart: (() -> Void)?
    let onVideoConfirm: (() -> Void)?
    
    init(
        homeEditMode: HomeEditMode? = nil,
        projectEditMode: ProjectEditMode? = nil,
        style: BottomToolbarStyle,
        hasItems: Bool,
        onDeleteStart: @escaping () -> Void,
        onMoveStart: @escaping () -> Void,
        onCancel: @escaping () -> Void,
        onDeleteConfirm: @escaping () -> Void,
        onMoveConfirm: @escaping () -> Void,
        onVideoStart: (() -> Void)? = nil,
        onVideoConfirm: (() -> Void)? = nil
    ) {
        self.homeEditMode = homeEditMode
        self.projectEditMode = projectEditMode
        self.style = style
        self.hasItems = hasItems
        self.onDeleteStart = onDeleteStart
        self.onMoveStart = onMoveStart
        self.onCancel = onCancel
        self.onDeleteConfirm = onDeleteConfirm
        self.onMoveConfirm = onMoveConfirm
        self.onVideoStart = onVideoStart
        self.onVideoConfirm = onVideoConfirm
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.green500)
                .frame(height: 5)
                .frame(maxWidth: .infinity)
            
            HStack {
                if let homeEditMode = homeEditMode {
                    homeToolbarContent(editMode: homeEditMode)
                } else if let projectEditMode = projectEditMode {
                    projectToolbarContent(editMode: projectEditMode)
                }
            }
            .background(Color.gray0)
        }
    }
    
    // MARK: - Home Toolbar Content
    @ViewBuilder
    private func homeToolbarContent(editMode: HomeEditMode) -> some View {
        switch editMode {
        case .normal:
            homeNormalModeButtons
        case .delete(let selectedProjects):
            homeEditModeButtons(
                selectedCount: selectedProjects.count,
                confirmAction: onDeleteConfirm
            )
        case .move(let selectedProjects):
            homeEditModeButtons(
                selectedCount: selectedProjects.count,
                confirmAction: onMoveConfirm
            )
        }
    }
    
    // MARK: - Project Toolbar Content
    @ViewBuilder
    private func projectToolbarContent(editMode: ProjectEditMode) -> some View {
        switch editMode {
        case .normal:
            projectNormalModeButtons
        case .delete(let selectedPhotos):
            projectEditModeButtons(
                selectedCount: selectedPhotos.count,
                confirmAction: onDeleteConfirm
            )
        case .makeVideo(let selectedPhotos):
            projectEditModeButtons(
                selectedCount: selectedPhotos.count,
                confirmAction: onVideoConfirm ?? {}
            )
        }
    }
    
    // MARK: - Home Normal Mode Buttons
    private var homeNormalModeButtons: some View {
        HStack {
            PressableButton(
                normalImage: "btn-delete-0",
                isDisabled: !hasItems,
                action: onDeleteStart
            )
            
            Spacer()
            
            PressableButton(
                normalImage: "btn-move-0",
                isDisabled: !hasItems,
                action: onMoveStart
            )
        }
    }
    
    // MARK: - Project Normal Mode Buttons
    private var projectNormalModeButtons: some View {
        HStack {
            PressableButton(
                normalImage: "btn-delete-0",
                isDisabled: !hasItems,
                action: onDeleteStart
            )
            
            Spacer()
            
            PressableButton(
                normalImage: "btn-makevideo-0",
                isDisabled: !hasItems,
                action: onVideoStart ?? {}
            )
        }
    }
    
    // MARK: - Home Edit Mode Buttons
    private func homeEditModeButtons(selectedCount: Int, confirmAction: @escaping () -> Void) -> some View {
        HStack {
            PressableButton(
                normalImage: "btn-cancel-0",
                action: onCancel
            )
            
            Spacer()
            
            if selectedCount > 0 {
                Text("\(selectedCount)개의 식물 선택")
                    .customFont(.categoryButtonBody)
                    .foregroundColor(.gray800)
            }
            
            Spacer()
            
            PressableButton(
                normalImage: "btn-select-0",
                isDisabled: selectedCount == 0,
                action: confirmAction
            )
        }
    }
    
    // MARK: - Project Edit Mode Buttons
    private func projectEditModeButtons(selectedCount: Int, confirmAction: @escaping () -> Void) -> some View {
        HStack {
            PressableButton(
                normalImage: "btn-cancel-0",
                action: onCancel
            )
            
            Spacer()
            
            if selectedCount > 0 {
                Text("\(selectedCount)개의 식물 선택")
                    .customFont(.categoryButtonBody)
                    .foregroundColor(.gray800)
            }
            
            Spacer()
            
            PressableButton(
                normalImage: "btn-select-0",
                isDisabled: selectedCount == 0,
                action: confirmAction
            )
        }
    }
}

// MARK: - View Extension for Conditional Modifier
extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        // Home style - Normal mode
        BottomToolbar(
            homeEditMode: .normal,
            style: .home,
            hasItems: true,
            onDeleteStart: {},
            onMoveStart: {},
            onCancel: {},
            onDeleteConfirm: {},
            onMoveConfirm: {}
        )
        
        // Home style - Delete mode
        BottomToolbar(
            homeEditMode: .delete(selectedProject: Set<Project>()),
            style: .home,
            hasItems: true,
            onDeleteStart: {},
            onMoveStart: {},
            onCancel: {},
            onDeleteConfirm: {},
            onMoveConfirm: {}
        )
        
        // ProjectDetail style - Normal mode
        BottomToolbar(
            projectEditMode: .normal,
            style: .projectDetail,
            hasItems: true,
            onDeleteStart: {},
            onMoveStart: {},
            onCancel: {},
            onDeleteConfirm: {},
            onMoveConfirm: {},
            onVideoStart: {},
            onVideoConfirm: {}
        )
        
        // ProjectDetail style - Video mode
        BottomToolbar(
            projectEditMode: .makeVideo(selectedPhoto: Set<Photo>()),
            style: .projectDetail,
            hasItems: true,
            onDeleteStart: {},
            onMoveStart: {},
            onCancel: {},
            onDeleteConfirm: {},
            onMoveConfirm: {},
            onVideoStart: {},
            onVideoConfirm: {}
        )
    }
    .background(Color.gray.opacity(0.1))
}
