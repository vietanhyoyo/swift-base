import Foundation
import SwiftData

@MainActor
final class AccountLocalDataSource {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll() throws -> [AccountEntity] {
        let descriptor = FetchDescriptor<AccountEntity>(
            sortBy: [SortDescriptor(\.name)]
        )
        return try context.fetch(descriptor)
    }

    func fetch(id: UUID) throws -> AccountEntity? {
        try fetchAll().first { $0.id == id }
    }

    func insert(_ entity: AccountEntity) throws {
        context.insert(entity)
        try context.save()
    }

    func saveChanges() throws {
        try context.save()
    }

    func delete(_ entity: AccountEntity) throws {
        context.delete(entity)
        try context.save()
    }
}
