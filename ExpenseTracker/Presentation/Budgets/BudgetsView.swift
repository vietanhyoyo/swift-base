import SwiftUI

struct BudgetsView: View {
    @State var viewModel: BudgetsViewModel
    @State private var isShowingForm = false
    @State private var editingProgress: BudgetProgress?

    var body: some View {
        VStack(spacing: 0) {
            MonthSelector(
                month: viewModel.month,
                previous: { Task { await viewModel.moveMonth(-1) } },
                next: { Task { await viewModel.moveMonth(1) } }
            )
            .padding(.horizontal, AppSpacing.medium)
            .padding(.vertical, AppSpacing.small)

            if viewModel.progress.isEmpty {
                EmptyStateView(
                    icon: "gauge.with.dots.needle.50percent",
                    title: "Chưa có ngân sách",
                    message: "Đặt giới hạn để kiểm soát chi tiêu theo danh mục."
                )
            } else {
                budgetList
            }
        }
        .appScreenBackground()
        .navigationTitle("Ngân sách")
        .toolbar {
            Button { isShowingForm = true } label: {
                Image(systemName: "plus.circle.fill")
            }
        }
        .task { await viewModel.load() }
        .sheet(isPresented: $isShowingForm) {
            BudgetFormView(viewModel: viewModel)
        }
        .sheet(item: $editingProgress) { progress in
            BudgetFormView(viewModel: viewModel, progress: progress)
        }
        .errorAlert(message: $viewModel.errorMessage)
    }

    private var budgetList: some View {
        List {
            ForEach(viewModel.progress) { progress in
                Button { editingProgress = progress } label: {
                    BudgetRow(progress: progress)
                }
                .buttonStyle(.plain)
                .swipeActions {
                    Button("Xoá", role: .destructive) {
                        Task { await viewModel.delete(progress) }
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
    }
}
