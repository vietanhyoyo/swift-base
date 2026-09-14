extension TransactionType {
    var title: String {
        switch self {
        case .income: "Thu nhập"
        case .expense: "Chi tiêu"
        }
    }
}
