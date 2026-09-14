@MainActor
extension AppContainer {
    func makeDashboardViewModel() -> DashboardViewModel {
        DashboardViewModel(
            statistics: statisticsUseCases,
            accounts: accountUseCases,
            categories: categoryUseCases,
            budgets: budgetUseCases
        )
    }

    func makeTransactionListViewModel() -> TransactionListViewModel {
        TransactionListViewModel(
            transactions: transactionUseCases,
            categories: categoryUseCases,
            accounts: accountUseCases
        )
    }

    func makeTransactionFormViewModel(
        transaction: ExpenseTransaction? = nil
    ) -> TransactionFormViewModel {
        TransactionFormViewModel(
            existing: transaction,
            transactions: transactionUseCases,
            categories: categoryUseCases,
            accounts: accountUseCases
        )
    }

    func makeStatisticsViewModel() -> StatisticsViewModel {
        StatisticsViewModel(statistics: statisticsUseCases)
    }

    func makeAccountsViewModel() -> AccountsViewModel {
        AccountsViewModel(useCases: accountUseCases)
    }

    func makeBudgetsViewModel() -> BudgetsViewModel {
        BudgetsViewModel(
            budgets: budgetUseCases,
            categories: categoryUseCases
        )
    }

    func makeCategoriesViewModel() -> CategoriesViewModel {
        CategoriesViewModel(useCases: categoryUseCases)
    }
}
