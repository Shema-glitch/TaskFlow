import SwiftUI

struct RollingQuoteView: View {
    let quotes: [String]
    @State private var currentIndex = 0
    @State private var opacity = 1.0
    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()

    var body: some View {
        Text(quotes[currentIndex])
            .font(.title3)
            .fontWeight(.light)
            .foregroundColor(.secondary)
            .opacity(opacity)
            .animation(.easeInOut(duration: 0.5), value: opacity)
            .onReceive(timer) { _ in
                withAnimation {
                    opacity = 0
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        currentIndex = (currentIndex + 1) % quotes.count
                        withAnimation {
                            opacity = 1
                        }
                    }
                }
            }
    }
}
