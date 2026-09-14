import Foundation
import SwiftData

@MainActor
final class TransactionLocalDataSource {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll() throws -> [TransactionEntity] {
        let descriptor = FetchDescriptor<TransactionEntity>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }

    func fetch(id: UUID) throws -> TransactionEntity? {
        try fetchAll().first { $0.id == id }
    }

    func insert(_ entity: TransactionEntity) throws {
        context.insert(entity)
        try context.save()
    }

    func saveChanges() throws {
        try context.save()
    }

    func delete(_ entity: TransactionEntity) throws {
        context.delete(entity)
        try context.save()
    }
}
