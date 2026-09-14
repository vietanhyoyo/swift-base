import SwiftUI

struct AccountFormView: View {
    let viewModel: AccountsViewModel
    let account: Account?

    @State private var name: String
    @State private var amount: String
    @Environment(\.dismiss) private var dismiss

    init(viewModel: AccountsViewModel, account: Account? = nil) {
        self.viewModel = viewModel
        self.account = account
        _name = State(initialValue: account?.name ?? "")
        _amount = State(initialValue: account.map {
            AppFormatters.vietnameseMoneyInput(
                NSDecimalNumber(decimal: $0.initialBalance).stringValue
            )
        } ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Tên tài khoản") {
                    TextField("Ví dụ: Tài khoản ngân hàng", text: $name)
                }
                Section("Số dư ban đầu") {
                    VietnameseMoneyTextField(text: $amount)
                }
            }
            .appFormStyle()
            .navigationTitle(account == nil ? "Tài khoản mới" : "Sửa tài khoản")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Huỷ") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Lưu") { save() }
                        .fontWeight(.semibold)
                        .disabled(trimmedName.isEmpty)
                }
            }
        }
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func save() {
        Task {
            let didSave = await viewModel.save(
                id: account?.id,
                name: trimmedName,
                initialBalance: AppFormatters.decimal(from: amount) ?? 0
            )
            if didSave { dismiss() }
        }
    }
}
