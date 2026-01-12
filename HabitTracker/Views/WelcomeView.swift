//
//  WelcomeView.swift
//  HabitTracker
//
//  Created by Luis Amrein
//

import SwiftUI

struct WelcomeView: View {
    @AppStorage("userName") private var userName = ""
    @AppStorage("hasCompletedWelcome") private var hasCompletedWelcome = false

    @State private var displayedText = ""
    @State private var currentIndex = 0
    @State private var showCursor = false
    @State private var isTypingComplete = false
    @FocusState private var isTextFieldFocused: Bool

    private let fullText = "Hello handsome, welcome to Habbit. How would you like to be called?"

    var body: some View {
        ZStack {
            Color.backgroundCream
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // Animated text
                ZStack(alignment: .leading) {
                    Text(displayedText)
                        .font(.custom("PTSans-Regular", size: 24))
                        .foregroundColor(.primaryText)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)

                    // Blinking cursor (only after typing is complete)
                    if isTypingComplete && showCursor {
                        Rectangle()
                            .fill(Color.primaryText)
                            .frame(width: 2, height: 30)
                            .offset(x: calculateCursorOffset())
                            .opacity(showCursor ? 1 : 0)
                            .animation(.easeInOut(duration: 0.8).repeatForever(), value: showCursor)
                    }
                }
                .frame(height: 100)

                // Name input field (appears after typing completes)
                if isTypingComplete {
                    VStack(spacing: 16) {
                        TextField("", text: $userName)
                            .font(.custom("PTSans-Regular", size: 20))
                            .multilineTextAlignment(.center)
                            .focused($isTextFieldFocused)
                            .padding(.vertical, 16)
                            .padding(.horizontal, 24)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemGray6).opacity(0.8))
                            )
                            .frame(maxWidth: 280)

                        Button {
                            if !userName.trimmingCharacters(in: .whitespaces).isEmpty {
                                hasCompletedWelcome = true
                            }
                        } label: {
                            Text("Continue")
                                .font(.custom("PTSans-Regular", size: 18))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    userName.trimmingCharacters(in: .whitespaces).isEmpty ?
                                        Color.neutralGray :
                                        Color.successGreen
                                )
                                .clipShape(Capsule())
                        }
                        .disabled(userName.trimmingCharacters(in: .whitespaces).isEmpty)
                        .frame(maxWidth: 200)
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 40)
        }
        .onAppear {
            startTypewriterEffect()
        }
        .onChange(of: isTypingComplete) { _, newValue in
            if newValue {
                // Start blinking cursor and focus text field
                showCursor = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isTextFieldFocused = true
                }
            }
        }
    }

    private func startTypewriterEffect() {
        displayedText = ""
        currentIndex = 0

        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            if currentIndex < fullText.count {
                let index = fullText.index(fullText.startIndex, offsetBy: currentIndex)
                displayedText.append(fullText[index])
                currentIndex += 1
            } else {
                timer.invalidate()
                isTypingComplete = true
            }
        }
    }

    private func calculateCursorOffset() -> CGFloat {
        let font = UIFont(name: "PTSans-Regular", size: 24) ?? UIFont.systemFont(ofSize: 24)
        let textWidth = (displayedText as NSString).size(withAttributes: [.font: font]).width
        return textWidth + 4 // Small offset from text
    }
}

// MARK: - Preview

#Preview {
    WelcomeView()
}
