import Foundation
import Observation

@MainActor
@Observable
final class StatisticsViewModel {
    var selectedMonth = Date()
    var summary = MonthlySummary(income: 0, expense: 0)
    var categorySpending: [CategorySpending] = []
    var dailySpending: [DailySpending] = []
    var dailyCashFlow: [DailyCashFlow] = []
    var isLoading = false
    var errorMessage: String?

    private let statistics: StatisticsUseCases

    init(statistics: StatisticsUseCases) {
        self.statistics = statistics
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            summary = try await statistics.monthlySummary(for: selectedMonth)
            dailyCashFlow = try await statistics.dailyCashFlow(for: selectedMonth)
            categorySpending = try await statistics.expenseByCategory(for: selectedMonth)
            dailySpending = try await statistics.dailyExpense(for: selectedMonth)
        } catch {
            errorMessage = error.userMessage
        }
    }

    func moveMonth(_ value: Int) async {
        selectedMonth = Calendar.current.date(
            byAdding: .month,
            value: value,
            to: selectedMonth
        ) ?? selectedMonth
        await load()
    }
}
