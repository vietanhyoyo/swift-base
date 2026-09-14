import SwiftUI

struct TransactionListView: View {
    let container: AppContainer
    @State private var viewModel: TransactionListViewModel
    @State private var editingTransaction: ExpenseTransaction?
    @State private var showingAdd = false
    @State private var showingFilters = false

    init(container: AppContainer) {
        self.container = container
        _viewModel = State(initialValue: container.makeTransactionListViewModel())
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.transactions.isEmpty {
                    ProgressView("Đang tải giao dịch…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.filtered.isEmpty {
                    EmptyStateView(
                        icon: hasNoSearchOrFilters ? "tray" : "magnifyingglass",
                        title: hasNoSearchOrFilters ? "Chưa có giao dịch" : "Không tìm thấy",
                        message: viewModel.query.isEmpty && !viewModel.hasFilters
                            ? "Nhấn nút + để ghi lại khoản thu chi đầu tiên."
                            : "Thử thay đổi từ khoá hoặc bộ lọc."
                    )
                } else {
                    transactionList
                }
            }
            .appScreenBackground()
            .navigationTitle("Giao dịch")
            .searchable(text: $viewModel.query, prompt: "Ghi chú hoặc danh mục")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button { showingFilters = true } label: {
                        Image(systemName: filterIcon)
                    }
                    .accessibilityLabel("Bộ lọc")
                    Button { showingAdd = true } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                    .accessibilityLabel("Thêm giao dịch")
                }
            }
            .task { await viewModel.load() }
            .refreshable { await viewModel.load() }
            .sheet(isPresented: $showingAdd, onDismiss: reload) {
                TransactionFormView(
                    viewModel: container.makeTransactionFormViewModel()
                )
            }
            .sheet(item: $editingTransaction, onDismiss: reload) { item in
                TransactionFormView(
                    viewModel: container.makeTransactionFormViewModel(transaction: item)
                )
            }
            .sheet(isPresented: $showingFilters) {
                TransactionFilterView(viewModel: viewModel)
            }
            .errorAlert(message: $viewModel.errorMessage)
        }
    }

    private var transactionList: some View {
        List {
            ForEach(groupedDays, id: \.0) { day, items in
                TransactionDaySection(
                    day: day,
                    transactions: items,
                    categories: viewModel.categories,
                    accounts: viewModel.accounts,
                    onEdit: { editingTransaction = $0 },
                    onDelete: { transaction in
                        Task { await viewModel.delete(transaction) }
                    }
                )
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(AppTheme.background)
    }

    private var groupedDays: [(Date, [ExpenseTransaction])] {
        Dictionary(grouping: viewModel.filtered) {
            Calendar.current.startOfDay(for: $0.date)
        }
        .sorted { $0.key > $1.key }
        .map { ($0.key, $0.value) }
    }

    private var hasNoSearchOrFilters: Bool {
        viewModel.query.isEmpty && !viewModel.hasFilters
    }

    private var filterIcon: String {
        viewModel.hasFilters
            ? "line.3.horizontal.decrease.circle.fill"
            : "line.3.horizontal.decrease.circle"
    }

    private func reload() {
        Task { await viewModel.load() }
    }
}
