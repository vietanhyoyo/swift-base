import Charts
import SwiftUI

struct CategorySpendingChart: View {
    let items: [CategorySpending]

    private let colors: [Color] = [
        AppTheme.teal,
        AppTheme.violet,
        AppTheme.coral,
        AppTheme.gold,
        .blue,
        .mint
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.large) {
            AppSectionHeader(
                title: "Phân bổ theo danh mục",
                icon: "chart.pie.fill"
            )
            Chart(items) { item in
                SectorMark(
                    angle: .value("Số tiền", item.amount.doubleValue),
                    innerRadius: .ratio(0.62),
                    angularInset: 2.5
                )
                .foregroundStyle(by: .value("Danh mục", item.category.name))
                .cornerRadius(5)
            }
            .chartForegroundStyleScale(range: colors)
            .chartLegend(
                position: .bottom,
                alignment: .leading,
                spacing: AppSpacing.small
            )
            .frame(height: 250)

            Divider()
            categoryRows
        }
        .appCard()
    }

    private var categoryRows: some View {
        VStack(spacing: AppSpacing.small) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                HStack(spacing: AppSpacing.small) {
                    AppIconBadge(
                        icon: item.category.icon,
                        color: colors[index % colors.count],
                        size: 36
                    )
                    Text(item.category.name)
                        .font(AppTypography.body)
                    Spacer()
                    Text(AppFormatters.money(item.amount))
                        .font(AppTypography.cardTitle)
                }
            }
        }
    }
}
