extension Error {
    var userMessage: String {
        (self as? DomainError)?.userMessage
            ?? "Đã có lỗi xảy ra. Vui lòng thử lại."
    }
}
