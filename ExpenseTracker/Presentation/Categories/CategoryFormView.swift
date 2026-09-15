import SwiftUI

struct CategoryFormView: View {
    let viewModel: CategoriesViewModel
    let category: ExpenseCategory?

    @State private var name: String
    @State private var icon: String
    @State private var type: TransactionType
    @State private var selectedColor: Color
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
        _selectedColor = State(
            initialValue: category?.color
                ?? Color(hex: ExpenseCategory.defaultColorHex(for: .expense))
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                detailsSection
                colorSection
                iconSection
            }
            .appFormStyle()
            .navigationTitle(category == nil ? "Danh mục mới" : "Sửa danh mục")
            .navigationBarTitleDisplayMode(.inline)
            .formToolbar(isSaveDisabled: trimmedName.isEmpty, onSave: save)
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
            .onChange(of: type) { _, newType in
                guard category == nil else { return }
                selectedColor = Color(hex: ExpenseCategory.defaultColorHex(for: newType))
            }
            TextField("Tên danh mục", text: $name)
        }
    }

    private var colorSection: some View {
        Section("Màu sắc") {
            ColorPicker(
                "Màu danh mục",
                selection: $selectedColor,
                supportsOpacity: false
            )
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
            AppIconBadge(
                icon: value,
                color: icon == value ? .white : selectedColor,
                size: 44,
                backgroundColor: icon == value ? selectedColor : AppTheme.surface,
                borderColor: icon == value ? selectedColor : AppTheme.separator,
                borderWidth: 0.5,
                iconScale: 0.46
            )
        }
        .accessibilityLabel(value)
        .accessibilityAddTraits(icon == value ? .isSelected : [])
    }

    private func save() {
        Task {
            let didSave = await viewModel.save(
                id: category?.id,
                name: trimmedName,
                icon: icon,
                type: type,
                colorHex: selectedColor.hexRGB
            )
            if didSave { dismiss() }
        }
    }
}
