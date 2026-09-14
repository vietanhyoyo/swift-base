import SwiftUI

struct CategoriesView: View {
    @State var viewModel: CategoriesViewModel
    @State private var editingCategory: ExpenseCategory?
    @State private var isShowingForm = false

    var body: some View {
        List {
            ForEach(TransactionType.allCases, id: \.self) { type in
                Section(type.title) {
                    ForEach(categories(for: type)) { category in
                        categoryRow(category)
                    }
                }
            }
        }
        .appFormStyle()
        .navigationTitle("Danh mục")
        .toolbar {
            Button { isShowingForm = true } label: {
                Image(systemName: "plus.circle.fill")
            }
        }
        .task { await viewModel.load() }
        .sheet(isPresented: $isShowingForm) {
            CategoryFormView(viewModel: viewModel)
        }
        .sheet(item: $editingCategory) { category in
            CategoryFormView(viewModel: viewModel, category: category)
        }
        .errorAlert(message: $viewModel.errorMessage)
    }

    private func categories(for type: TransactionType) -> [ExpenseCategory] {
        viewModel.categories.filter { $0.type == type }
    }

    private func categoryRow(_ category: ExpenseCategory) -> some View {
        Button { editingCategory = category } label: {
            HStack(spacing: AppSpacing.small) {
                AppIconBadge(
                    icon: category.icon,
                    color: category.color,
                    size: 38
                )
                Text(category.name)
                    .font(AppTypography.bodyEmphasis)
                    .foregroundStyle(.primary)
            }
            .padding(.vertical, 2)
        }
        .swipeActions {
            Button("Xoá", role: .destructive) {
                Task { await viewModel.delete(category) }
            }
        }
    }
}
