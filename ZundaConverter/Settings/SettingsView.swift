import SwiftUI

struct SettingsView: View {
    @ObservedObject private var settings = SettingsStore.shared
    @State private var previewInput = "このコードはリファクタリングが必要です。\nここの処理は少し複雑すぎると思います。\nもう少しシンプルにしていただけますか？"
    @State private var previewOutput = ""

    var body: some View {
        TabView {
            generalTab
                .tabItem {
                    Label("一般", systemImage: "gear")
                }

            previewTab
                .tabItem {
                    Label("プレビュー", systemImage: "eye")
                }
        }
        .frame(width: 520, height: 400)
    }

    // MARK: - General Tab

    private var generalTab: some View {
        Form {
            Section("変換モード") {
                Picker("モード", selection: $settings.conversionMode) {
                    ForEach(ConversionMode.allCases) { mode in
                        Text(mode.displayName).tag(mode)
                    }
                }
                .pickerStyle(.radioGroup)

                Text(settings.conversionMode.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Section("一般設定") {
                Toggle("ログイン時に起動", isOn: $settings.launchAtLogin)
                Toggle("変換完了時に通知", isOn: $settings.showNotification)
            }

            Section("使い方") {
                VStack(alignment: .leading, spacing: 8) {
                    Label("テキストを選択して右クリック", systemImage: "cursorarrow.click.2")
                    Text("→ サービス → 「ずんだもんに変換」を選択")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.leading, 28)
                }
            }
        }
        .padding()
    }

    // MARK: - Preview Tab

    private var previewTab: some View {
        VStack(spacing: 16) {
            Text("変換プレビュー")
                .font(.headline)

            HSplitView {
                VStack(alignment: .leading) {
                    Text("変換前")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextEditor(text: $previewInput)
                        .font(.system(.body, design: .rounded))
                        .frame(minWidth: 200)
                }
                .padding(8)

                VStack(alignment: .leading) {
                    Text("変換後")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    ScrollView {
                        Text(previewOutput)
                            .font(.system(.body, design: .rounded))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .textSelection(.enabled)
                    }
                    .frame(minWidth: 200)
                }
                .padding(8)
            }

            Button("変換する") {
                previewOutput = TextConversionEngine.shared.convert(previewInput)
            }
            .keyboardShortcut(.return, modifiers: .command)
        }
        .padding()
    }
}
