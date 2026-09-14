import Foundation

enum DomainError: Error, Equatable {
    case invalidAmount
    case invalidTransactionType
    case accountNotFound
    case categoryNotFound
    case transactionNotFound
    case budgetNotFound
    case duplicateBudget
    case itemInUse
    case persistenceError

    var userMessage: String {
        switch self {
        case .invalidAmount: "Số tiền phải lớn hơn 0."
        case .invalidTransactionType: "Danh mục không phù hợp với loại giao dịch."
        case .accountNotFound: "Không tìm thấy tài khoản."
        case .categoryNotFound: "Không tìm thấy danh mục."
        case .transactionNotFound: "Không tìm thấy giao dịch."
        case .budgetNotFound: "Không tìm thấy ngân sách."
        case .duplicateBudget: "Danh mục này đã có ngân sách trong tháng."
        case .itemInUse: "Không thể xoá vì mục này đang được sử dụng."
        case .persistenceError: "Không thể lưu dữ liệu. Vui lòng thử lại."
        }
    }
}

