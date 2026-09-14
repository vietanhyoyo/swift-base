import Foundation

@MainActor
struct StatisticsUseCases {
    let transactions: any TransactionRepository
    let categories: any CategoryRepository

    func monthlySummary(
        for month: Date,
        calendar: Calendar = .current
    ) async throws -> MonthlySummary {
        let transactionsInMonth = try await transactions.getTransactions().filter {
            calendar.isDate($0.date, equalTo: month, toGranularity: .month)
        }
        return Self.summary(from: transactionsInMonth)
    }

    func expenseByCategory(
        for month: Date,
        calendar: Calendar = .current
    ) async throws -> [CategorySpending] {
        let allCategories = try await categories.getCategories()
        let expenses = try await transactions.getTransactions().filter {
            $0.type == .expense
                && calendar.isDate($0.date, equalTo: month, toGranularity: .month)
        }

        return allCategories
            .filter { $0.type == .expense }
            .compactMap { category in
                let amount = expenses
                    .filter { $0.categoryID == category.id }
                    .reduce(Decimal.zero) { $0 + $1.amount }
                return amount > 0
                    ? CategorySpending(category: category, amount: amount)
                    : nil
            }
            .sorted { $0.amount > $1.amount }
    }

    func dailyExpense(
        for month: Date,
        calendar: Calendar = .current
    ) async throws -> [DailySpending] {
        let expenses = try await transactions.getTransactions().filter {
            $0.type == .expense
                && calendar.isDate($0.date, equalTo: month, toGranularity: .month)
        }
        let expensesByDay = Dictionary(grouping: expenses) {
            calendar.startOfDay(for: $0.date)
        }

        return expensesByDay
            .map { day, transactions in
                DailySpending(
                    date: day,
                    amount: transactions.reduce(Decimal.zero) { $0 + $1.amount }
                )
            }
            .sorted { $0.date < $1.date }
    }

    func dailyCashFlow(
        for month: Date,
        calendar: Calendar = .current
    ) async throws -> [DailyCashFlow] {
        let transactionsInMonth = try await transactions.getTransactions().filter {
            calendar.isDate($0.date, equalTo: month, toGranularity: .month)
        }
        return Self.dailyCashFlow(from: transactionsInMonth, calendar: calendar)
    }

    func recent(limit: Int) async throws -> [ExpenseTransaction] {
        let sortedTransactions = try await transactions.getTransactions().sorted {
            $0.date > $1.date
        }
        return Array(sortedTransactions.prefix(limit))
    }

    static func summary(from transactions: [ExpenseTransaction]) -> MonthlySummary {
        let income = transactions
            .filter { $0.type == .income }
            .reduce(Decimal.zero) { $0 + $1.amount }
        let expense = transactions
            .filter { $0.type == .expense }
            .reduce(Decimal.zero) { $0 + $1.amount }
        return MonthlySummary(income: income, expense: expense)
    }

    static func dailyCashFlow(
        from transactions: [ExpenseTransaction],
        calendar: Calendar = .current
    ) -> [DailyCashFlow] {
        Dictionary(grouping: transactions) {
            calendar.startOfDay(for: $0.date)
        }
        .map { day, transactions in
            let summary = Self.summary(from: transactions)
            return DailyCashFlow(
                date: day,
                income: summary.income,
                expense: summary.expense
            )
        }
        .sorted { $0.date < $1.date }
    }
}
