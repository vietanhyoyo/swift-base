import Foundation

@MainActor
struct AccountUseCases {
    let accounts: any AccountRepository
    let transactions: any TransactionRepository

    func getAll() async throws -> [Account] {
        try await accounts.getAccounts()
    }

    func save(_ account: Account, isEditing: Bool) async throws {
        guard account.initialBalance >= 0 else {
            throw DomainError.invalidAmount
        }

        if isEditing {
            try await accounts.updateAccount(account)
        } else {
            try await accounts.addAccount(account)
        }
    }

    func delete(id: UUID) async throws {
        let isUsed = try await transactions.getTransactions().contains {
            $0.accountID == id
        }
        guard !isUsed else {
            throw DomainError.itemInUse
        }
        try await accounts.deleteAccount(id: id)
    }

    func balance(for account: Account) async throws -> Decimal {
        let allTransactions = try await transactions.getTransactions()
        return Self.calculateBalance(account: account, transactions: allTransactions)
    }

    func totalBalance() async throws -> Decimal {
        let allAccounts = try await accounts.getAccounts()
        let allTransactions = try await transactions.getTransactions()

        return allAccounts.reduce(0) { result, account in
            result + Self.calculateBalance(account: account, transactions: allTransactions)
        }
    }

    static func calculateBalance(
        account: Account,
        transactions: [ExpenseTransaction]
    ) -> Decimal {
        transactions
            .filter { $0.accountID == account.id }
            .reduce(account.initialBalance) { result, transaction in
                transaction.type == .income
                    ? result + transaction.amount
                    : result - transaction.amount
            }
    }
}
