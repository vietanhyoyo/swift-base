import SwiftUI

struct AppIconBadge: View {
    let icon: String
    var color: Color = AppTheme.teal
    var size: CGFloat = 42

    var body: some View {
        Image(systemName: icon)
            .font(.system(size: size * 0.4, weight: .semibold))
            .foregroundStyle(color)
            .frame(width: size, height: size)
            .background(
                color.opacity(0.12),
                in: RoundedRectangle(cornerRadius: size * 0.31, style: .continuous)
            )
            .accessibilityHidden(true)
    }
}
