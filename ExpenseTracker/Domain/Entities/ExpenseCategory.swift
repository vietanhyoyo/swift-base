import Foundation

struct ExpenseCategory: Identifiable, Equatable, Sendable {
    let id: UUID
    let name: String
    let icon: String
    let type: TransactionType
}
