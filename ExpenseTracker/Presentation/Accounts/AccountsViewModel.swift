import Foundation
import Observation

@MainActor
@Observable
final class AccountsViewModel {
    var accounts: [Account] = []
    var balances: [UUID: Decimal] = [:]
    var errorMessage: String?

    private let useCases: AccountUseCases

    init(useCases: AccountUseCases) {
        self.useCases = useCases
    }

    func load() async {
        do {
            accounts = try await useCases.getAll()
            balances = try await useCases.balances()
        } catch {
            errorMessage = error.userMessage
        }
    }

    func save(id: UUID? = nil, name: String, initialBalance: Decimal) async -> Bool {
        let account = Account(
            id: id ?? UUID(),
            name: name,
            initialBalance: initialBalance
        )

        do {
            try await useCases.save(account, isEditing: id != nil)
            await load()
            return true
        } catch {
            errorMessage = error.userMessage
            return false
        }
    }

    func delete(_ account: Account) async {
        do {
            try await useCases.delete(id: account.id)
            await load()
        } catch {
            errorMessage = error.userMessage
        }
    }
}
