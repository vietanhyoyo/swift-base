import SwiftUI

struct DashboardView: View {
    let container: AppContainer
    @State private var viewModel: DashboardViewModel
    @State private var isShowingTransactionForm = false

    init(container: AppContainer) {
        self.container = container
        _viewModel = State(initialValue: container.makeDashboardViewModel())
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: AppSpacing.medium) {
                    MonthSelector(
                        month: viewModel.selectedMonth,
                        previous: { Task { await viewModel.moveMonth(-1) } },
                        next: { Task { await viewModel.moveMonth(1) } }
                    )
                    DashboardBalanceCard(
                        balance: viewModel.balance,
                        summary: viewModel.summary
                    )
                    if let errorMessage = viewModel.errorMessage {
                        ErrorBanner(message: errorMessage)
                    }
                    DashboardSpendingCard(items: viewModel.categorySpending)
                    if !viewModel.budgetProgress.isEmpty {
                        DashboardBudgetCard(items: viewModel.budgetProgress)
                    }
                    DashboardRecentCard(
                        transactions: viewModel.recentTransactions,
                        categories: viewModel.categories
                    )
                }
                .padding(.horizontal, AppSpacing.medium)
                .padding(.top, AppSpacing.xSmall)
                .padding(.bottom, AppSpacing.xxLarge)
            }
            .appScreenBackground()
            .navigationTitle("Xin chào 👋")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    addTransactionButton
                }
            }
            .refreshable { await viewModel.load() }
            .task { await viewModel.load() }
            .sheet(
                isPresented: $isShowingTransactionForm,
                onDismiss: { Task { await viewModel.load() } }
            ) {
                TransactionFormView(
                    viewModel: container.makeTransactionFormViewModel()
                )
            }
        }
    }

    private var addTransactionButton: some View {
        Button { isShowingTransactionForm = true } label: {
            Image(systemName: "plus.circle.fill")
                .font(.title3)
        }
        .accessibilityLabel("Thêm giao dịch")
    }
}

#Preview {
    let container = try! AppContainer(inMemory: true)

    DashboardView(container: container)
        .modelContainer(container.modelContainer)
}
