import Foundation
import Observation

@MainActor
@Observable
final class BudgetsViewModel {
    var month = Date()
    var progress: [BudgetProgress] = []
    var expenseCategories: [ExpenseCategory] = []
    var errorMessage: String?

    private let budgets: BudgetUseCases
    private let categories: CategoryUseCases

    init(budgets: BudgetUseCases, categories: CategoryUseCases) {
        self.budgets = budgets
        self.categories = categories
    }

    func load() async {
        do {
            expenseCategories = try await categories.getAll().filter {
                $0.type == .expense
            }
            progress = try await budgets.progress(for: month)
        } catch {
            errorMessage = error.userMessage
        }
    }

    func moveMonth(_ value: Int) async {
        month = Calendar.current.date(
            byAdding: .month,
            value: value,
            to: month
        ) ?? month
        await load()
    }

    func save(id: UUID? = nil, categoryID: UUID, amount: Decimal) async -> Bool {
        let budget = Budget(
            id: id ?? UUID(),
            categoryID: categoryID,
            amount: amount,
            month: month
        )

        do {
            try await budgets.save(budget, isEditing: id != nil)
            await load()
            return true
        } catch {
            errorMessage = error.userMessage
            return false
        }
    }

    func delete(_ progress: BudgetProgress) async {
        do {
            try await budgets.delete(id: progress.budget.id)
            await load()
        } catch {
            errorMessage = error.userMessage
        }
    }
}
