import Foundation

struct ExpenseTransaction: Identifiable, Equatable, Sendable {
    let id: UUID
    let amount: Decimal
    let type: TransactionType
    let date: Date
    let note: String?
    let categoryID: UUID
    let accountID: UUID
}
