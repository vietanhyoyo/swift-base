import SwiftUI

struct StatisticsSummaryView: View {
    let summary: MonthlySummary

    var body: some View {
        HStack(spacing: AppSpacing.small) {
            AppMetricCard(
                title: "Thu nhập",
                value: AppFormatters.money(summary.income),
                icon: "arrow.down.left",
                color: AppTheme.teal
            )
            AppMetricCard(
                title: "Chi tiêu",
                value: AppFormatters.money(summary.expense),
                icon: "arrow.up.right",
                color: AppTheme.coral
            )
        }
    }
}
