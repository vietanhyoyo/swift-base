import Foundation

@MainActor
struct CategoryUseCases {
    let categories: any CategoryRepository
    let transactions: any TransactionRepository

    func getAll() async throws -> [ExpenseCategory] {
        try await categories.getCategories()
    }

    func save(_ category: ExpenseCategory, isEditing: Bool) async throws {
        let name = category.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            throw DomainError.categoryNotFound
        }

        if isEditing {
            try await categories.updateCategory(category)
        } else {
            try await categories.addCategory(category)
        }
    }

    func delete(id: UUID) async throws {
        let isUsed = try await transactions.getTransactions().contains {
            $0.categoryID == id
        }
        guard !isUsed else {
            throw DomainError.itemInUse
        }
        try await categories.deleteCategory(id: id)
    }
}
