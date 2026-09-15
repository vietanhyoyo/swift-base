import SwiftUI

struct BudgetFormView: View {
    let viewModel: BudgetsViewModel
    let progress: BudgetProgress?

    @State private var categoryID: UUID?
    @State private var amount: String
    @Environment(\.dismiss) private var dismiss

    init(viewModel: BudgetsViewModel, progress: BudgetProgress? = nil) {
        self.viewModel = viewModel
        self.progress = progress
        _categoryID = State(
            initialValue: progress?.budget.categoryID
                ?? viewModel.expenseCategories.first?.id
        )
        _amount = State(initialValue: progress.map {
            AppFormatters.vietnameseMoneyInput(from: $0.budget.amount)
        } ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Danh mục") {
                    Picker("Danh mục", selection: $categoryID) {
                        ForEach(viewModel.expenseCategories) { category in
                            Label(category.name, systemImage: category.icon)
                                .tag(Optional(category.id))
                        }
                    }
                }
                Section("Giới hạn mỗi tháng") {
                    VietnameseMoneyTextField(text: $amount)
                }
            }
            .appFormStyle()
            .navigationTitle(progress == nil ? "Ngân sách mới" : "Sửa ngân sách")
            .navigationBarTitleDisplayMode(.inline)
            .formToolbar(isSaveDisabled: !canSave, onSave: save)
        }
    }

    private var parsedAmount: Decimal? {
        AppFormatters.decimal(from: amount)
    }

    private var canSave: Bool {
        categoryID != nil && (parsedAmount ?? 0) > 0
    }

    private func save() {
        guard let categoryID, let parsedAmount else { return }

        Task {
            let didSave = await viewModel.save(
                id: progress?.budget.id,
                categoryID: categoryID,
                amount: parsedAmount
            )
            if didSave { dismiss() }
        }
    }
}
