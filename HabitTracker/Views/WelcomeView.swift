//
//  WelcomeView.swift
//  HabitTracker
//
//  Created by Luis Amrein
//

import SwiftUI

struct WelcomeView: View {
    @AppStorage("userName") private var storedUserName = ""
    @AppStorage("hasCompletedWelcome") private var hasCompletedWelcome = false

    @State private var displayedText = ""
    @State private var currentIndex = 0
    @State private var showCursor = false
    @State private var cursorOpacity: Double = 1.0
    @State private var isTypingComplete = false
    @State private var enteredName = ""
    @State private var textFieldVisible = false
    @FocusState private var isTextFieldFocused: Bool

    private let fullText = "Hello handsome, welcome to Habbit. How would you like to be called?"
    
    // Pause points: after "Hello handsome," and after "welcome to Habbit."
    private let pausePoints: [Int] = [15, 34] // Indices where pauses should occur (after comma and period)

    var body: some View {
        ZStack {
            Color.backgroundCream
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // Animated text with fixed width container
                ZStack(alignment: .leading) {
                    // Fixed width container to prevent text jumping
                    VStack(spacing: 0) {
                        Text(displayedText)
                            .font(.custom("PTSans-Regular", size: 24))
                            .foregroundColor(.primaryText)
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: 320, alignment: .leading)
                    }
                    .frame(width: 320, alignment: .leading)

                    // Blinking cursor for typewriter text (shows after typing completes)
                    if isTypingComplete && showCursor {
                        Rectangle()
                            .fill(Color.successGreen)
                            .frame(width: 2, height: 30)
                            .offset(x: calculateCursorOffset())
                            .opacity(cursorOpacity)
                    }
                }
                .frame(height: 100)

                // Name input field (appears after typing completes)
                if textFieldVisible {
                    VStack(spacing: 16) {
                        TextField("", text: $enteredName)
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
                            .tint(.clear) // Hide TextField's native cursor completely

                        Button {
                            if !enteredName.trimmingCharacters(in: .whitespaces).isEmpty {
                                storedUserName = enteredName.trimmingCharacters(in: .whitespaces)
                                hasCompletedWelcome = true
                            }
                        } label: {
                            Text("Continue")
                                .font(.custom("PTSans-Regular", size: 18))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    enteredName.trimmingCharacters(in: .whitespaces).isEmpty ?
                                        Color.neutralGray :
                                        Color.successGreen
                                )
                                .clipShape(Capsule())
                        }
                        .disabled(enteredName.trimmingCharacters(in: .whitespaces).isEmpty)
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
                // Start blinking cursor immediately
                showCursor = true
                startCursorBlink()
                // Show text field after cursor has blinked for a while
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    textFieldVisible = true
                    isTextFieldFocused = true
                    // Hide cursor when text field appears
                    showCursor = false
                }
            }
        }
    }

    private func startTypewriterEffect() {
        displayedText = ""
        currentIndex = 0
        
        typeNextCharacter()
    }
    
    private func typeNextCharacter() {
        guard currentIndex < fullText.count else {
            isTypingComplete = true
            return
        }
        
        let index = fullText.index(fullText.startIndex, offsetBy: currentIndex)
        displayedText.append(fullText[index])
        currentIndex += 1
        
        // Check if we just typed a character at a pause point (pause AFTER typing it)
        let delay: TimeInterval = pausePoints.contains(currentIndex - 1) ? 0.6 : 0.08
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            typeNextCharacter()
        }
    }

    private func startCursorBlink() {
        cursorOpacity = 1.0
        Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { timer in
            guard self.showCursor else {
                timer.invalidate()
                return
            }
            withAnimation(.easeInOut(duration: 0.4)) {
                self.cursorOpacity = self.cursorOpacity == 1.0 ? 0.0 : 1.0
            }
        }
    }
    
    private func calculateCursorOffset() -> CGFloat {
        let font = UIFont(name: "PTSans-Regular", size: 24) ?? UIFont.systemFont(ofSize: 24)
        let textWidth = (displayedText as NSString).size(withAttributes: [.font: font]).width
        return min(textWidth + 4, 316) // Small offset from text, max width of container
    }
}

// MARK: - Preview

#Preview {
    WelcomeView()
}
