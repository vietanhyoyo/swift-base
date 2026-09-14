import SwiftUI

struct DashboardBudgetCard: View {
    let items: [BudgetProgress]

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            AppSectionHeader(
                title: "Ngân sách tháng",
                icon: "gauge.with.dots.needle.50percent"
            )
            ForEach(items.prefix(3)) { progress in
                BudgetProgressRow(progress: progress)
            }
        }
        .appCard()
    }
}

private struct BudgetProgressRow: View {
    let progress: BudgetProgress

    private var color: Color {
        switch progress.status {
        case .safe: AppTheme.teal
        case .warning: AppTheme.gold
        case .exceeded: AppTheme.coral
        }
    }

    var body: some View {
        VStack(spacing: AppSpacing.xSmall) {
            HStack(spacing: AppSpacing.xSmall) {
                AppIconBadge(
                    icon: progress.category.icon,
                    color: progress.category.color,
                    size: 34
                )
                Text(progress.category.name)
                    .font(AppTypography.cardTitle)
                Spacer()
                Text("\(Int(progress.ratio.doubleValue * 100))%")
                    .font(AppTypography.captionEmphasis)
                    .foregroundStyle(color)
                    .padding(.horizontal, AppSpacing.xSmall)
                    .padding(.vertical, AppSpacing.xxxSmall)
                    .background(color.opacity(0.11), in: Capsule())
            }
            ProgressView(value: min(progress.ratio.doubleValue, 1))
                .tint(color)
        }
    }
}
