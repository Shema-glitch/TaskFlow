import SwiftUI

struct CategoryCard: View {
    let category: TaskCategory
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: category.icon)
                    .font(.system(size: 28))
                    .foregroundColor(Color(hex: category.color))
                    .padding(16)
                    .background(Color(hex: category.color)?.opacity(0.1))
                    .clipShape(Circle())
                Text(category.name)
                    .font(.headline)
                Text("\(category.taskCount) Tasks")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                ProgressView(value: Float(category.completedCount) / Float(max(category.taskCount, 1)))
                    .accentColor(Color(hex: category.color))
                    .frame(height: 6)
                    .padding(.top, 4)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.ultraThickMaterial)
            .cornerRadius(18)
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
        }
    }
}
