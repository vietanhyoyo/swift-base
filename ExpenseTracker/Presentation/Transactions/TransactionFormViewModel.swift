import Foundation
import Observation

@MainActor
@Observable
final class TransactionFormViewModel {
    let id: UUID
    let isEditing: Bool
    var type: TransactionType
    var amountText = ""
    var date: Date
    var note = ""
    var categoryID: UUID?
    var accountID: UUID?
    var categories: [ExpenseCategory] = []
    var accounts: [Account] = []
    var isSaving = false
    var errorMessage: String?

    private let transactions: TransactionUseCases
    private let categoryUseCases: CategoryUseCases
    private let accountUseCases: AccountUseCases

    init(
        existing: ExpenseTransaction?,
        transactions: TransactionUseCases,
        categories: CategoryUseCases,
        accounts: AccountUseCases
    ) {
        id = existing?.id ?? UUID()
        isEditing = existing != nil
        type = existing?.type ?? .expense
        date = existing?.date ?? Date()
        note = existing?.note ?? ""
        categoryID = existing?.categoryID
        accountID = existing?.accountID
        if let amount = existing?.amount {
            amountText = AppFormatters.vietnameseMoneyInput(
                NSDecimalNumber(decimal: amount).stringValue
            )
        }
        self.transactions = transactions
        categoryUseCases = categories
        accountUseCases = accounts
    }

    var availableCategories: [ExpenseCategory] {
        categories.filter { $0.type == type }
    }

    var canSave: Bool {
        (AppFormatters.decimal(from: amountText) ?? 0) > 0
            && categoryID != nil
            && accountID != nil
            && !isSaving
    }

    func load() async {
        do {
            categories = try await categoryUseCases.getAll()
            accounts = try await accountUseCases.getAll()
            selectValidDefaults()
        } catch {
            errorMessage = error.userMessage
        }
    }

    func typeChanged() {
        categoryID = availableCategories.first?.id
    }

    func save() async -> Bool {
        guard let transaction = makeTransaction() else {
            errorMessage = DomainError.invalidAmount.userMessage
            return false
        }

        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        do {
            try await transactions.save(transaction, isEditing: isEditing)
            return true
        } catch {
            errorMessage = error.userMessage
            return false
        }
    }

    private func selectValidDefaults() {
        if !availableCategories.contains(where: { $0.id == categoryID }) {
            categoryID = availableCategories.first?.id
        }
        if !accounts.contains(where: { $0.id == accountID }) {
            accountID = accounts.first?.id
        }
    }

    private func makeTransaction() -> ExpenseTransaction? {
        guard
            let amount = AppFormatters.decimal(from: amountText),
            let categoryID,
            let accountID
        else {
            return nil
        }

        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        return ExpenseTransaction(
            id: id,
            amount: amount,
            type: type,
            date: date,
            note: trimmedNote.isEmpty ? nil : note,
            categoryID: categoryID,
            accountID: accountID
        )
    }
}
