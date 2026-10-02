import SwiftUI

/// Small feedback form. Opens a pre-filled GitHub issue in the browser; nothing is sent from the app.
struct FeedbackView: View {
    static let repoURL = "https://github.com/amalmehta/SystemDesignOracle"

    let context: String
    @Environment(\.dismiss) private var dismiss
    @State private var kind = "Content fix"
    @State private var summary = ""
    @State private var details = ""

    private let kinds = ["Content fix", "Topic idea", "Bug", "Other"]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Send Feedback").font(.title2.weight(.semibold))
            Text("Spotted a mistake, want a topic, or hit a bug? This opens a pre-filled GitHub issue in your browser — nothing is sent until you submit it there.")
                .font(.callout).foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Picker("Kind", selection: $kind) {
                ForEach(kinds, id: \.self) { Text($0) }
            }
            .pickerStyle(.segmented)
            TextField("One-line summary", text: $summary)
            TextEditor(text: $details)
                .font(.body)
                .frame(minHeight: 120)
                .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(Color.primary.opacity(0.15)))
            Text("Includes: \(context), app \(appVersion)").font(.caption).foregroundStyle(.secondary)
            HStack {
                Spacer()
                Button("Cancel") { dismiss() }.keyboardShortcut(.cancelAction)
                Button("Open GitHub Issue") {
                    if let url = issueURL { NSWorkspace.shared.open(url) }
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(summary.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(20)
        .frame(width: 480)
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "dev"
    }

    private var issueURL: URL? {
        var components = URLComponents(string: "\(Self.repoURL)/issues/new")
        components?.queryItems = [
            URLQueryItem(name: "title", value: "[\(kind)] \(summary)"),
            URLQueryItem(name: "body", value: "\(details)\n\n---\nWhere: \(context)\nApp version: \(appVersion)"),
        ]
        return components?.url
    }
}
