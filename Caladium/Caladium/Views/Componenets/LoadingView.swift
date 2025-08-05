//
//  LoadingView.swift
//  Caladium
//
//  Created by yoomin on 6/9/25.
//

import SwiftUI
import RiveRuntime

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.gray0
                .ignoresSafeArea()
            RiveViewModel(fileName: "loading_jegeo").view()
        }
    }
}

#Preview {
    LoadingView()
}
