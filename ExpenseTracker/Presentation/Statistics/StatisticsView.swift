import SwiftUI

struct StatisticsView: View {
    @State var viewModel: StatisticsViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: AppSpacing.medium) {
                    MonthSelector(
                        month: viewModel.selectedMonth,
                        previous: { Task { await viewModel.moveMonth(-1) } },
                        next: { Task { await viewModel.moveMonth(1) } }
                    )
                    StatisticsSummaryView(summary: viewModel.summary)
                    if let errorMessage = viewModel.errorMessage {
                        ErrorBanner(message: errorMessage)
                    }
                    MonthlyCashFlowCalendar(
                        month: viewModel.selectedMonth,
                        items: viewModel.dailyCashFlow
                    )
                    statisticsContent
                }
                .padding(.horizontal, AppSpacing.medium)
                .padding(.top, AppSpacing.xSmall)
                .padding(.bottom, AppSpacing.xxLarge)
            }
            .appScreenBackground()
            .navigationTitle("Thống kê")
            .task { await viewModel.load() }
            .refreshable { await viewModel.load() }
        }
    }

    @ViewBuilder
    private var statisticsContent: some View {
        if viewModel.categorySpending.isEmpty && viewModel.dailySpending.isEmpty {
            EmptyStateView(
                icon: "chart.bar",
                title: "Chưa có dữ liệu",
                message: "Biểu đồ sẽ xuất hiện khi bạn thêm chi tiêu trong tháng."
            )
            .frame(minHeight: 280)
            .appCard(padding: 0)
        } else {
            DailySpendingChart(items: viewModel.dailySpending)
            CategorySpendingChart(items: viewModel.categorySpending)
        }
    }
}

private struct MonthlyCashFlowCalendar: View {
    let month: Date
    let items: [DailyCashFlow]

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: AppSpacing.xxxSmall),
        count: 7
    )
    private let weekdayTitles = ["T2", "T3", "T4", "T5", "T6", "T7", "CN"]
    private let calendar = Calendar.current

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            AppSectionHeader(title: "Lịch thu chi", icon: "calendar")

            LazyVGrid(columns: columns, spacing: AppSpacing.xSmall) {
                ForEach(weekdayTitles, id: \.self) { title in
                    Text(title)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }

                ForEach(Array(dayCells.enumerated()), id: \.offset) { _, date in
                    if let date {
                        dayCell(for: date)
                    } else {
                        Color.clear
                            .frame(height: 66)
                            .accessibilityHidden(true)
                    }
                }
            }

            HStack(spacing: AppSpacing.medium) {
                legend(color: AppTheme.teal, title: "Thu nhập")
                legend(color: AppTheme.coral, title: "Chi tiêu")
            }
            .frame(maxWidth: .infinity)
        }
        .appCard(padding: AppSpacing.medium)
    }

    private var dayCells: [Date?] {
        guard
            let monthInterval = calendar.dateInterval(of: .month, for: month),
            let days = calendar.range(of: .day, in: .month, for: month)
        else {
            return []
        }

        let firstDay = calendar.startOfDay(for: monthInterval.start)
        let leadingEmptyDays = (calendar.component(.weekday, from: firstDay) + 5) % 7
        var cells = Array<Date?>(repeating: nil, count: leadingEmptyDays)
        cells.append(contentsOf: days.compactMap { day in
            calendar.date(byAdding: .day, value: day - 1, to: firstDay)
        })

        let trailingEmptyDays = (7 - cells.count % 7) % 7
        cells.append(contentsOf: Array<Date?>(repeating: nil, count: trailingEmptyDays))
        return cells
    }

    private var cashFlowByDay: [Date: DailyCashFlow] {
        Dictionary(uniqueKeysWithValues: items.map {
            (calendar.startOfDay(for: $0.date), $0)
        })
    }

    private func dayCell(for date: Date) -> some View {
        let item = cashFlowByDay[calendar.startOfDay(for: date)]
        let isToday = calendar.isDateInToday(date)

        return VStack(spacing: 3) {
            Text(date.formatted(.dateTime.day()))
                .font(.caption.weight(isToday ? .bold : .medium))
                .foregroundStyle(isToday ? Color.white : Color.primary)
                .frame(width: 24, height: 24)
                .background(isToday ? AppTheme.teal : Color.clear, in: Circle())

            Spacer(minLength: 0)

            amountLine(prefix: "+", amount: item?.income ?? 0, color: AppTheme.teal)
            amountLine(prefix: "−", amount: item?.expense ?? 0, color: AppTheme.coral)
        }
        .padding(.horizontal, 2)
        .padding(.vertical, AppSpacing.xxxSmall)
        .frame(maxWidth: .infinity, minHeight: 66, alignment: .top)
        .background(
            AppTheme.navy.opacity(item == nil ? 0 : 0.035),
            in: RoundedRectangle(cornerRadius: AppRadius.small, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: AppRadius.small, style: .continuous)
                .stroke(
                    isToday ? AppTheme.teal.opacity(0.25) : Color.clear,
                    lineWidth: 1
                )
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel(for: date, item: item))
    }

    private func amountLine(prefix: String, amount: Decimal, color: Color) -> some View {
        Text(amount > 0 ? prefix + AppFormatters.compactMoney(amount.doubleValue) : " ")
            .font(.system(size: 8, weight: .semibold, design: .rounded))
            .foregroundStyle(color)
            .lineLimit(1)
            .minimumScaleFactor(0.65)
            .frame(maxWidth: .infinity)
    }

    private func legend(color: Color, title: String) -> some View {
        HStack(spacing: AppSpacing.xxSmall) {
            Circle()
                .fill(color)
                .frame(width: 7, height: 7)
            Text(title)
                .font(AppTypography.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func accessibilityLabel(for date: Date, item: DailyCashFlow?) -> String {
        let dateText = date.formatted(.dateTime.day().month().year())
        guard let item else { return "\(dateText), không có giao dịch" }
        return "\(dateText), thu \(AppFormatters.money(item.income)), chi \(AppFormatters.money(item.expense))"
    }
}
