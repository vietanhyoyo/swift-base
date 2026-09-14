import Foundation
import SwiftData

@MainActor
final class BudgetLocalDataSource {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll() throws -> [BudgetEntity] {
        let descriptor = FetchDescriptor<BudgetEntity>(
            sortBy: [SortDescriptor(\.month, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }

    func fetch(id: UUID) throws -> BudgetEntity? {
        try fetchAll().first { $0.id == id }
    }

    func insert(_ entity: BudgetEntity) throws {
        context.insert(entity)
        try context.save()
    }

    func saveChanges() throws {
        try context.save()
    }

    func delete(_ entity: BudgetEntity) throws {
        context.delete(entity)
        try context.save()
    }
}
