import SwiftUI

struct TutorialOverlay: View {
    @Binding var isShowing: Bool
    let onComplete: () -> Void
    @State private var currentStep = 0
    @State private var offset = CGSize.zero
    @State private var opacity = 0.0
    @GestureState private var dragOffset = CGSize.zero
    
    let steps = [
        (title: "Welcome to TaskFlow! 👋", message: "Let's get you started with smart task management", icon: "wand.and.stars"),
        (title: "AI-Powered Magic ✨", message: "Watch as TaskFlow intelligently categorizes and prioritizes your tasks", icon: "brain"),
        (title: "Voice Commands 🎤", message: "Try adding tasks hands-free with voice commands", icon: "waveform"),
        (title: "Smart Organization 📊", message: "Your tasks are automatically sorted into beautiful categories", icon: "folder.fill"),
        (title: "You're Ready! 🚀", message: "Start organizing your tasks like a pro", icon: "checkmark.circle.fill")
    ]
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.75)
                .ignoresSafeArea()
                .transition(.opacity)
            
            VStack(spacing: 20) {
                Image(systemName: steps[currentStep].icon)
                    .font(.system(size: 50, weight: .bold))
                    .foregroundStyle(.linearGradient(
                        colors: [.blue, .blue.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .padding()
                    .transition(.scale.combined(with: .opacity))
                
                Text(steps[currentStep].title)
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .transition(.slide)
                    .multilineTextAlignment(.center)
                
                Text(steps[currentStep].message)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.horizontal)
                    .transition(.move(edge: .trailing))
                
                // Progress Indicators
                HStack(spacing: 8) {
                    ForEach(0..<steps.count, id: \.self) { index in
                        Circle()
                            .fill(currentStep == index ? Color.white : Color.white.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .scaleEffect(currentStep == index ? 1.2 : 1.0)
                            .animation(.spring(response: 0.3), value: currentStep)
                    }
                }
                .padding(.top)
                
                // Navigation Buttons
                HStack(spacing: 20) {
                    if currentStep > 0 {
                        Button(action: {
                            withAnimation(.spring()) {
                                currentStep -= 1
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title3)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.white.opacity(0.2))
                                .clipShape(Circle())
                        }
                    }
                    
                    Button(action: {
                        withAnimation(.spring()) {
                            if currentStep < steps.count - 1 {
                                currentStep += 1
                            } else {
                                isShowing = false
                                onComplete()
                            }
                        }
                    }) {
                        Text(currentStep < steps.count - 1 ? "Next" : "Get Started")
                            .font(.headline)
                            .padding()
                            .frame(width: 200)
                            .background(
                                LinearGradient(
                                    colors: [.blue, .blue.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                    }
                }
                .padding(.top)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground).opacity(0.1))
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            )
            .padding()
            .offset(x: offset.width + dragOffset.width, y: offset.height + dragOffset.height)
            .opacity(opacity)
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        state = value.translation
                    }
                    .onEnded { value in
                        let threshold: CGFloat = 50
                        if value.translation.width > threshold {
                            if currentStep > 0 {
                                withAnimation(.spring()) {
                                    currentStep -= 1
                                }
                            }
                        } else if value.translation.width < -threshold {
                            if currentStep < steps.count - 1 {
                                withAnimation(.spring()) {
                                    currentStep += 1
                                }
                            }
                        }
                    }
            )
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    opacity = 1.0
                    offset = .zero
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    TutorialOverlay(isShowing: .constant(true), onComplete: {})
}
