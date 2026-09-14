import Foundation
import SwiftData

@MainActor
final class CategoryLocalDataSource {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll() throws -> [CategoryEntity] {
        let descriptor = FetchDescriptor<CategoryEntity>(
            sortBy: [SortDescriptor(\.name)]
        )
        return try context.fetch(descriptor)
    }

    func fetch(id: UUID) throws -> CategoryEntity? {
        try fetchAll().first { $0.id == id }
    }

    func insert(_ entity: CategoryEntity) throws {
        context.insert(entity)
        try context.save()
    }

    func saveChanges() throws {
        try context.save()
    }

    func delete(_ entity: CategoryEntity) throws {
        context.delete(entity)
        try context.save()
    }
}
