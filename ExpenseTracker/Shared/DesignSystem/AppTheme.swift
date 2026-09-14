import SwiftUI

enum AppTheme {
    static let teal = Color(red: 0, green: 146 / 255, blue: 184 / 255)
    static let tealDark = Color(red: 0, green: 78 / 255, blue: 102 / 255)
    static let navy = Color(red: 0.07, green: 0.14, blue: 0.22)
    static let coral = Color(red: 0.93, green: 0.31, blue: 0.29)
    static let gold = Color(red: 0.94, green: 0.62, blue: 0.12)
    static let violet = Color(red: 0.42, green: 0.35, blue: 0.82)

    static let background = Color(uiColor: .systemGroupedBackground)
    static let surface = Color(uiColor: .secondarySystemGroupedBackground)
    static let elevatedSurface = Color(uiColor: .systemBackground)
    static let separator = Color(uiColor: .separator).opacity(0.45)

    static let heroGradient = LinearGradient(
        colors: [navy, tealDark, teal.opacity(0.92)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
