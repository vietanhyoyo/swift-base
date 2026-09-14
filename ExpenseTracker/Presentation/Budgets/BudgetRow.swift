import SwiftUI

struct BudgetRow: View {
    let progress: BudgetProgress

    private var color: Color {
        switch progress.status {
        case .safe: AppTheme.teal
        case .warning: AppTheme.gold
        case .exceeded: AppTheme.coral
        }
    }

    var body: some View {
        VStack(spacing: AppSpacing.small) {
            HStack(spacing: AppSpacing.small) {
                AppIconBadge(icon: progress.category.icon, color: progress.category.color, size: 38)
                Text(progress.category.name)
                    .font(AppTypography.bodyEmphasis)
                Spacer()
                Text("\(percentage)%")
                    .font(AppTypography.captionEmphasis)
                    .foregroundStyle(color)
                    .padding(.horizontal, AppSpacing.xSmall)
                    .padding(.vertical, AppSpacing.xxxSmall)
                    .background(color.opacity(0.11), in: Capsule())
            }
            ProgressView(value: min(progress.ratio.doubleValue, 1))
                .tint(color)
            HStack {
                Text("Đã dùng \(AppFormatters.money(progress.spent))")
                Spacer()
                Text("/ \(AppFormatters.money(progress.budget.amount))")
            }
            .font(AppTypography.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, AppSpacing.xxxSmall)
    }

    private var percentage: Int {
        Int(progress.ratio.doubleValue * 100)
    }
}
