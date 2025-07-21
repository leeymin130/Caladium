//
//  BottomToolbar.swift
//  Caladium
//
//  Created by yoomin on 7/20/25.
//

import SwiftUI

struct BottomToolbar: View {
    var body: some View {
        Color.black.ignoresSafeArea()
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.green500)
                .frame(height: 5)
                .frame(maxWidth: .infinity)
            HStack {
                 
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 16)
            .background(Color.gray0)
        }
    }
}

#Preview {
    BottomToolbar()
}
