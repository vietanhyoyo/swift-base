import Foundation
import Observation

@MainActor
@Observable
final class DashboardViewModel {
    var isLoading = false
    var errorMessage: String?
    var balance: Decimal = 0
    var summary = MonthlySummary(income: 0, expense: 0)
    var categorySpending: [CategorySpending] = []
    var budgetProgress: [BudgetProgress] = []
    var recentTransactions: [ExpenseTransaction] = []
    var categories: [UUID: ExpenseCategory] = [:]
    var selectedMonth = Date()

    private let statistics: StatisticsUseCases
    private let accounts: AccountUseCases
    private let categoryUseCases: CategoryUseCases
    private let budgets: BudgetUseCases

    init(
        statistics: StatisticsUseCases,
        accounts: AccountUseCases,
        categories: CategoryUseCases,
        budgets: BudgetUseCases
    ) {
        self.statistics = statistics
        self.accounts = accounts
        categoryUseCases = categories
        self.budgets = budgets
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            balance = try await accounts.totalBalance()
            summary = try await statistics.monthlySummary(for: selectedMonth)
            categorySpending = try await statistics.expenseByCategory(for: selectedMonth)
            budgetProgress = try await budgets.progress(for: selectedMonth)
            recentTransactions = try await statistics.recent(limit: 5)
            let allCategories = try await categoryUseCases.getAll()
            categories = Dictionary(uniqueKeysWithValues: allCategories.map { ($0.id, $0) })
        } catch {
            errorMessage = error.userMessage
        }
    }

    func moveMonth(_ offset: Int) async {
        selectedMonth = Calendar.current.date(
            byAdding: .month,
            value: offset,
            to: selectedMonth
        ) ?? selectedMonth
        await load()
    }
}
