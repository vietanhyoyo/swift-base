import SwiftUI

struct CategoryFormView: View {
    let viewModel: CategoriesViewModel
    let category: ExpenseCategory?

    @State private var name: String
    @State private var icon: String
    @State private var type: TransactionType
    @Environment(\.dismiss) private var dismiss

    private let icons = [
        "fork.knife", "car.fill", "bag.fill", "gamecontroller.fill",
        "doc.text.fill", "cross.case.fill", "book.fill", "banknote.fill",
        "gift.fill", "star.fill", "square.grid.2x2.fill"
    ]

    init(viewModel: CategoriesViewModel, category: ExpenseCategory? = nil) {
        self.viewModel = viewModel
        self.category = category
        _name = State(initialValue: category?.name ?? "")
        _icon = State(initialValue: category?.icon ?? "star.fill")
        _type = State(initialValue: category?.type ?? .expense)
    }

    var body: some View {
        NavigationStack {
            Form {
                detailsSection
                iconSection
            }
            .appFormStyle()
            .navigationTitle(category == nil ? "Danh mục mới" : "Sửa danh mục")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Huỷ") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Lưu") { save() }
                        .fontWeight(.semibold)
                        .disabled(trimmedName.isEmpty)
                }
            }
        }
    }

    private var detailsSection: some View {
        Section {
            Picker("Loại", selection: $type) {
                ForEach(TransactionType.allCases, id: \.self) {
                    Text($0.title).tag($0)
                }
            }
            .pickerStyle(.segmented)
            TextField("Tên danh mục", text: $name)
        }
    }

    private var iconSection: some View {
        Section("Biểu tượng") {
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible()), count: 5),
                spacing: AppSpacing.small
            ) {
                ForEach(icons, id: \.self) { value in
                    iconButton(value)
                }
            }
            .padding(.vertical, AppSpacing.xxSmall)
        }
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func iconButton(_ value: String) -> some View {
        Button { icon = value } label: {
            Image(systemName: value)
                .font(.title3)
                .frame(width: 44, height: 44)
                .background(
                    icon == value ? AppTheme.teal : AppTheme.surface,
                    in: RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                )
                .foregroundStyle(icon == value ? .white : .primary)
                .overlay {
                    RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                        .stroke(
                            icon == value ? AppTheme.teal : AppTheme.separator,
                            lineWidth: 0.5
                        )
                }
        }
    }

    private func save() {
        Task {
            let didSave = await viewModel.save(
                id: category?.id,
                name: trimmedName,
                icon: icon,
                type: type
            )
            if didSave { dismiss() }
        }
    }
}
