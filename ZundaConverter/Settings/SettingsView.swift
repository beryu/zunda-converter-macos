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
        .frame(width: 520, height: 540)
    }

    // MARK: - General Tab

    private var generalTab: some View {
        ScrollView {
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

                    if settings.conversionMode == .ai {
                        aiStatusSection
                    }
                }

                Section("一般設定") {
                    Toggle("ログイン時に起動", isOn: $settings.launchAtLogin)
                    Toggle("変換完了時に通知", isOn: $settings.showNotification)
                }

                Section("ショートカット") {
                    ShortcutRecorderView()
                    
                    if !AccessibilityHelper.shared.isTrusted {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.yellow)
                                Text("権限が必要です")
                                    .font(.caption)
                                    .fontWeight(.bold)
                            }
                            
                            Text("ショートカット機能を使うにはアクセシビリティ権限を許可してください。")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Button("権限設定を開く") {
                                AccessibilityHelper.shared.promptForPermission()
                            }
                            .font(.caption)
                        }
                        .padding(.vertical, 4)
                    }
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

    // MARK: - AI Status Section

    @ViewBuilder
    private var aiStatusSection: some View {
        if #available(macOS 26, *) {
            if LLMConverter.shared.isAvailable {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Apple Intelligence: 利用可能")
                        .font(.caption)
                }
            } else if let reason = LLMConverter.shared.unavailableReason {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.yellow)
                        Text("Apple Intelligence が必要です")
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                    Text(reason)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        } else {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                    Text("非対応")
                        .font(.caption)
                        .fontWeight(.bold)
                }
                Text("AIモードにはmacOS 26以降が必要です。")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}
