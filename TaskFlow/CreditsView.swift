
import SwiftUI

struct CreditsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // App Logo and Info
                VStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.blue)
                    
                    Text("To-Do App")
                        .font(.title)
                        .bold()
                    
                    Text("Version 1.0.0")
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                // Developer Info
                DeveloperSection()
                
                // Technologies Used
                TechnologiesSection()
                
                // Open Source Credits
                OpenSourceSection()
                
                // Special Thanks
                SpecialThanksSection()
                
                // Footer
                Text("© 2025 Shema Charmant. All rights reserved.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 20)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct DeveloperSection: View {
    var body: some View {
        VStack(spacing: 8) {
            SectionTitle(text: "Development Team")
            
            ProfileCard(
                imageName: "person.circle.fill",
                name: "Shema Charmant",
                role: "Main Developer"
            )
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

private struct TechnologiesSection: View {
    let technologies = [
        ("Swift", "swift"),
        ("SwiftUI", "square.stack.3d.up.fill"),
        ("Core Data", "cylinder.split.1x2"),
        ("CloudKit", "cloud.fill")
    ]
    
    var body: some View {
        VStack(spacing: 8) {
            SectionTitle(text: "Built With")
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(technologies, id: \.0) { tech in
                    TechnologyCard(name: tech.0, iconName: tech.1)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

private struct OpenSourceSection: View {
    var body: some View {
        VStack(spacing: 8) {
            SectionTitle(text: "Open Source Libraries")
            
            VStack(alignment: .leading, spacing: 12) {
                LibraryCard(name: "Swift Collections", description: "Advanced data structures")
                LibraryCard(name: "SwiftDate", description: "Date management")
                LibraryCard(name: "KeychainAccess", description: "Secure storage")
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

private struct SpecialThanksSection: View {
    var body: some View {
        VStack(spacing: 8) {
            SectionTitle(text: "Special Thanks")
            
            Text("To our amazing beta testers and the SwiftUI community for their invaluable feedback and support.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

private struct SectionTitle: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.headline)
            .padding(.bottom, 4)
    }
}

private struct ProfileCard: View {
    let imageName: String
    let name: String
    let role: String
    
    var body: some View {
        HStack {
            Image(systemName: imageName)
                .font(.title)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading) {
                Text(name)
                    .font(.headline)
                Text(role)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

private struct TechnologyCard: View {
    let name: String
    let iconName: String
    
    var body: some View {
        VStack {
            Image(systemName: iconName)
                .font(.title2)
                .foregroundColor(.blue)
            Text(name)
                .font(.caption)
                .bold()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

private struct LibraryCard: View {
    let name: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(name)
                .font(.subheadline)
                .bold()
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}
