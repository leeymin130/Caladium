//
//  CustomAlert.swift
//  Caladium
//
//  Created by 이종선 on 6/21/25.
//

import SwiftUI


struct ExampleContentView: View {
    @State private var showAlert = false
    
    var body: some View {
        NavigationStack{
            List {
                Button("Show Alert"){
                    showAlert.toggle( )
                }
                .alert(isPresented: $showAlert) {
                    /// ALERT CONTENT
                    CustomDialong(
                        title: "Folder Name",
                        content: "Enter a file Name",
                        image: .init(content: "folder.fill.badge.plus", tint: .blue, foreground: .white),
                        button1: .init(content: "Save Folder", tint: .green, foreground: .white, action: { folder in
                            print(folder)
                            showAlert = false
                        }),
                        button2: .init(content: "Cancel", tint: .red, foreground: .white),
                        addsTextField: true,
                        textFieldHint: "Personal Documents"
                        )
                    /// Since it's using "if" conditions to add view you can use SwiftUI Trasaction here!
                        .transition(.blurReplace.combined(with: .push(from: .bottom)))
                } background: {
                    /// BACKGROUND
                    Rectangle()
                        .fill(.primary.opacity(0.35))
                }

            }
            .navigationTitle("Custom Alert")
            
        }
    }
}

#Preview {
    ExampleContentView()
}

struct CustomDialong: View {
    var title: String
    var content: String?
    var image: Config
    var button1: Config
    var button2: Config?
    var addsTextField: Bool = false
    var textFieldHint: String = ""
    
    @State private var text: String = ""
    
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: image.content)
                .font(.title)
                .foregroundStyle(image.foreground)
                .frame(width: 65, height: 65)
                .background(image.tint.gradient, in: .circle)
                .background{
                    Circle()
                        .stroke(.background, lineWidth: 8)
                }
            Text(title)
                .font(.title.bold())
            
            if let content {
                Text(content)
                    .font(.system(size:14))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .foregroundStyle(.secondary)
            }
            
            if addsTextField {
                TextField(textFieldHint, text: $text)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 12)
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.secondary.opacity(0.2))
                    }
                    .padding(.bottom, 5)
            }
            
            ButtonView(button1)
            
            if let button2{
                ButtonView(button2)
                    .padding(.top, -5)
            }
        }
        .padding([.horizontal, .bottom] , 15)
        .background{
            RoundedRectangle(cornerRadius: 15)
                .fill(.background)
                .padding(.top, 30)
        }
        .frame(maxWidth: 310)
        .compositingGroup()
    }
    
    @ViewBuilder
    private func ButtonView(_ config: Config) -> some View {
        Button {
            config.action(addsTextField ? text : "")
        } label: {
            Text(config.content)
                .fontWeight(.bold)
                .foregroundStyle(config.foreground)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(config.tint.gradient, in: .rect(cornerRadius: 8))
        }

    }
    
    struct Config {
        var content: String
        var tint: Color
        var foreground: Color
        var action: (String) -> () = { _ in }
    }
}



extension View {
    @ViewBuilder
    func alert<Content: View, Background: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder background: @escaping () -> Background
    ) -> some View {
        self
            .modifier(
                CustomAlertModifier(
                    isPresented: isPresented,
                    alertContent: content,
                    background: background)
            )
    }
}

/// Helpr Modifier
fileprivate struct CustomAlertModifier<AlertContent: View, Background: View>: ViewModifier {
    @Binding var isPresented: Bool
    @ViewBuilder var alertContent: AlertContent
    @ViewBuilder var background: Background
    // View Properties
    @State private var showFullScreenCover: Bool = false
    @State private var animatedValue: Bool = false
    /// To ensure that the animation is completed properly, let's disable user interaction with our custom alert view
    /// until the initial animation is finished. Additionally, we should write the code to dismiss the custom alert
    @State private var allowsInteraction: Bool = false
    
    func body(content: Content) -> some View {
        content
            /// Using Full Screen Cover to show alert content on top of the current context
            /// We can elimate the full-screen-cover animation by utilizing SwiftUI Transactions.
            /// Thus, let's modifiy the code to present and dismiss the full-screen-cover without it's default animation.
            .fullScreenCover(isPresented: $showFullScreenCover) {
                ZStack {
                    if animatedValue {
                        alertContent
                            .allowsHitTesting(allowsInteraction)
                    }
                }
                .presentationBackground{
                    background
                        .opacity(animatedValue ? 1 : 0)
                        .allowsHitTesting(allowsInteraction)
                }
                .task {
                    try? await Task.sleep(for: .seconds(0.05))
                    withAnimation(.easeOut(duration:0.3)){
                        animatedValue = true
                    }
                    try? await Task.sleep(for: .seconds(0.2))
                    allowsInteraction = true
                }
            }
            .onChange(of: isPresented){ oldValue, newValue in
                var transaction = Transaction()
                transaction.disablesAnimations = true
                
                if newValue {
                    withTransaction(transaction) {
                        showFullScreenCover = true
                    }
                } else {
                    allowsInteraction = false
                    withAnimation(.easeInOut(duration: 0.3), completionCriteria: .removed) {
                        animatedValue = false
                    } completion: {
                        /// Removing full-screen-cover without animation
                        withTransaction(transaction) {
                            showFullScreenCover = false
                        }
                    }

                }
            }
    }
}
