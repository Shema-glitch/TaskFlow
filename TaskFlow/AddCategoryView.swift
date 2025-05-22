import SwiftUI

struct AddCategoryView: View {
    @Binding var categories: [TaskCategory]
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name = ""
    @State private var selectedIcon = "folder.fill"
    @State private var selectedColor = Color.blue
    
    let icons = ["folder.fill", "briefcase.fill", "house.fill", "car.fill",
                 "book.fill", "gamecontroller.fill", "gift.fill", "heart.fill",
                 "star.fill", "moon.fill", "sun.max.fill", "cloud.fill"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Category Details")) {
                    TextField("Category Name", text: $name)
                    
                    ColorPicker("Choose Color", selection: $selectedColor)
                }
                
                Section(header: Text("Icon")) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 10) {
                        ForEach(icons, id: \.self) { icon in
                            Image(systemName: icon)
                                .font(.title2)
                                .frame(width: 44, height: 44)
                                .background(selectedIcon == icon ? selectedColor.opacity(0.2) : Color.clear)
                                .cornerRadius(8)
                                .onTapGesture {
                                    selectedIcon = icon
                                }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("New Category")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    let newCategory = TaskCategory(
                        name: name,
                        icon: selectedIcon,
                        color: selectedColor.toHex(),
                        taskCount: 0,
                        completedCount: 0,
                        isCustom: true
                    )
                    TaskCategory.saveCategories(categories + [newCategory])
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(name.isEmpty)
            )
        }
    }
}

#Preview {
    AddCategoryView(categories: .constant([]))
}
