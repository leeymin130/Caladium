//
//  RiveViewSample.swift
//  Caladium
//
//  Created by 이종선 on 7/22/25.
//

import SwiftUI
import RiveRuntime

struct RiveViewSample: View {
    var body: some View {
        RiveViewModel(fileName: "loading").view()
            
    }
}

#Preview {
    RiveViewSample()
}
