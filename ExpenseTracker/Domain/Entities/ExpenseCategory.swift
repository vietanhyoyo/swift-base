import Foundation

struct ExpenseCategory: Identifiable, Equatable, Sendable {
    let id: UUID
    let name: String
    let icon: String
    let type: TransactionType
    let colorHex: String

    init(
        id: UUID,
        name: String,
        icon: String,
        type: TransactionType,
        colorHex: String? = nil
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.type = type
        self.colorHex = colorHex ?? Self.defaultColorHex(for: type, categoryName: name)
    }

    static func defaultColorHex(for type: TransactionType) -> String {
        type == .income ? "#0092B8" : "#ED4F4A"
    }

    private static func defaultColorHex(
        for type: TransactionType,
        categoryName: String
    ) -> String {
        let knownColors = [
            "Ăn uống": "#FF5D73",
            "Di chuyển": "#3B82F6",
            "Mua sắm": "#A855F7",
            "Giải trí": "#EC4899",
            "Hoá đơn": "#F59E0B",
            "Sức khoẻ": "#EF4444",
            "Giáo dục": "#14B8A6",
            "Khác": "#64748B",
            "Lương": "#10B981",
            "Thưởng": "#F59E0B",
            "Đầu tư": "#0EA5E9",
            "Thu nhập khác": "#8B5CF6"
        ]

        return knownColors[categoryName] ?? defaultColorHex(for: type)
    }
}
