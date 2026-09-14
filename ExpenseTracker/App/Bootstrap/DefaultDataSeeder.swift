import Foundation

@MainActor
final class DefaultDataSeeder {
    private let categories: CategoryUseCases
    private let accounts: AccountUseCases

    init(categories: CategoryUseCases, accounts: AccountUseCases) {
        self.categories = categories
        self.accounts = accounts
    }

    func seedIfNeeded() async {
        do {
            try await seedCategoriesIfNeeded()
            try await seedAccountIfNeeded()
        } catch {
            // Feature screens surface persistence failures. Seeding remains retryable.
        }
    }

    private func seedCategoriesIfNeeded() async throws {
        guard try await categories.getAll().isEmpty else { return }

        for category in Self.defaultCategories {
            try await categories.save(category, isEditing: false)
        }
    }

    private func seedAccountIfNeeded() async throws {
        guard try await accounts.getAll().isEmpty else { return }

        let cashAccount = Account(
            id: UUID(),
            name: "Tiền mặt",
            initialBalance: 0
        )
        try await accounts.save(cashAccount, isEditing: false)
    }

    private static let defaultCategories: [ExpenseCategory] = [
        ExpenseCategory(id: UUID(), name: "Ăn uống", icon: "fork.knife", type: .expense, colorHex: "#FF5D73"),
        ExpenseCategory(id: UUID(), name: "Di chuyển", icon: "car.fill", type: .expense, colorHex: "#3B82F6"),
        ExpenseCategory(id: UUID(), name: "Mua sắm", icon: "bag.fill", type: .expense, colorHex: "#A855F7"),
        ExpenseCategory(id: UUID(), name: "Giải trí", icon: "gamecontroller.fill", type: .expense, colorHex: "#EC4899"),
        ExpenseCategory(id: UUID(), name: "Hoá đơn", icon: "doc.text.fill", type: .expense, colorHex: "#F59E0B"),
        ExpenseCategory(id: UUID(), name: "Sức khoẻ", icon: "cross.case.fill", type: .expense, colorHex: "#EF4444"),
        ExpenseCategory(id: UUID(), name: "Giáo dục", icon: "book.fill", type: .expense, colorHex: "#14B8A6"),
        ExpenseCategory(id: UUID(), name: "Khác", icon: "square.grid.2x2.fill", type: .expense, colorHex: "#64748B"),
        ExpenseCategory(id: UUID(), name: "Lương", icon: "banknote.fill", type: .income, colorHex: "#10B981"),
        ExpenseCategory(id: UUID(), name: "Thưởng", icon: "gift.fill", type: .income, colorHex: "#F59E0B"),
        ExpenseCategory(id: UUID(), name: "Đầu tư", icon: "chart.line.uptrend.xyaxis", type: .income, colorHex: "#0EA5E9"),
        ExpenseCategory(id: UUID(), name: "Thu nhập khác", icon: "plus.circle.fill", type: .income, colorHex: "#8B5CF6")
    ]
}
