import Foundation
import Observation

@MainActor
@Observable
final class CategoriesViewModel {
    var categories: [ExpenseCategory] = []
    var errorMessage: String?

    private let useCases: CategoryUseCases

    init(useCases: CategoryUseCases) {
        self.useCases = useCases
    }

    func load() async {
        do {
            categories = try await useCases.getAll()
        } catch {
            errorMessage = error.userMessage
        }
    }

    func save(
        id: UUID? = nil,
        name: String,
        icon: String,
        type: TransactionType
    ) async -> Bool {
        let category = ExpenseCategory(
            id: id ?? UUID(),
            name: name,
            icon: icon,
            type: type
        )

        do {
            try await useCases.save(category, isEditing: id != nil)
            await load()
            return true
        } catch {
            errorMessage = error.userMessage
            return false
        }
    }

    func delete(_ category: ExpenseCategory) async {
        do {
            try await useCases.delete(id: category.id)
            await load()
        } catch {
            errorMessage = error.userMessage
        }
    }
}
