import SwiftUI

// MARK: - Layers

/// The four reading layers every topic and problem has.
enum Layer: Int, CaseIterable, Identifiable {
    case gist = 1, picture, mechanics, expert
    var id: Int { rawValue }

    func name(forProblem: Bool = false) -> String {
        switch self {
        case .gist: "The Gist"
        case .picture: "The Picture"
        case .mechanics: forProblem ? "The Design" : "How It Works"
        case .expert: "Expert Depth"
        }
    }

    var blurb: String {
        switch self {
        case .gist: "One sentence. The idea in a breath."
        case .picture: "Plain English and a diagram."
        case .mechanics: "Components, flow, trade-offs, real numbers."
        case .expert: "Failure modes, real systems, interview questions."
        }
    }

    var color: Color {
        switch self {
        case .gist: .teal
        case .picture: .blue
        case .mechanics: .indigo
        case .expert: .purple
        }
    }
}

struct LayerHeader: View {
    let layer: Layer
    var forProblem = false

    var body: some View {
        HStack(spacing: 10) {
            Text("\(layer.rawValue)")
                .font(.system(.caption, design: .rounded).weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 22, height: 22)
                .background(Circle().fill(layer.color))
            Text(layer.name(forProblem: forProblem))
                .font(.title2.weight(.semibold))
            Spacer()
        }
        .padding(.top, 28)
        .padding(.bottom, 4)
    }
}

/// Shown at the end of the visible layers when there is more to read.
struct GoDeeperButton: View {
    @Binding var depth: Int
    var forProblem = false

    var body: some View {
        if let next = Layer(rawValue: depth + 1) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { depth = next.rawValue }
            } label: {
                HStack {
                    Image(systemName: "arrow.down.circle.fill")
                    Text("Go deeper: \(next.name(forProblem: forProblem))")
                        .fontWeight(.medium)
                    Text("— \(next.blurb)").foregroundStyle(.secondary)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 10).fill(next.color.opacity(0.10)))
                .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(next.color.opacity(0.35)))
            }
            .buttonStyle(.plain)
            .padding(.top, 28)
        }
    }
}

struct DepthPicker: View {
    @Binding var depth: Int

    var body: some View {
        Picker("Depth", selection: $depth) {
            ForEach(Layer.allCases) { layer in
                Text("\(layer.rawValue)").tag(layer.rawValue)
                    .help("\(layer.name()) — \(layer.blurb)")
            }
        }
        .pickerStyle(.segmented)
        .help("How many layers deep to read (⌘1–⌘4)")
    }
}

// MARK: - Text

/// Renders inline markdown (**bold**, *italic*, `code`).
/// Content uses "~" to mean "approximately", so it is escaped rather than read as strikethrough.
func md(_ string: String) -> Text {
    let options = AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
    let escaped = string.replacingOccurrences(of: "~", with: "\\~")
    if let attributed = try? AttributedString(markdown: escaped, options: options) {
        return Text(attributed)
    }
    return Text(string)
}

struct Paragraphs: View {
    let paragraphs: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(paragraphs, id: \.self) { p in
                md(p).font(.body).lineSpacing(3).textSelection(.enabled)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct SubHeading: View {
    let title: String
    var body: some View {
        Text(title.uppercased())
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
            .tracking(0.8)
            .padding(.top, 16)
            .padding(.bottom, 2)
    }
}

struct Bullets: View {
    let items: [String]
    var numbered = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(items.enumerated()), id: \.offset) { i, item in
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(numbered ? "\(i + 1)." : "•")
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                        .frame(minWidth: numbered ? 18 : 8, alignment: .trailing)
                    md(item).textSelection(.enabled).fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

// MARK: - Cards and tables

struct Card<Content: View>: View {
    @ViewBuilder let content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 4) { content }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.primary.opacity(0.04)))
            .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.primary.opacity(0.08)))
    }
}

struct NamedCards: View {
    let items: [(name: String, text: String)]
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 260), spacing: 10, alignment: .top)], spacing: 10) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                Card {
                    md(item.name).font(.headline)
                    md(item.text).foregroundStyle(.secondary).textSelection(.enabled)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

struct NumbersGrid: View {
    let numbers: [Number]
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 200), spacing: 10, alignment: .top)], spacing: 10) {
            ForEach(numbers, id: \.self) { n in
                Card {
                    md(n.value).font(.system(.title3, design: .rounded).weight(.semibold))
                        .textSelection(.enabled).fixedSize(horizontal: false, vertical: true)
                    md(n.metric).font(.callout).foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

struct TradeoffTable: View {
    let tradeoffs: [Tradeoff]
    var body: some View {
        Grid(alignment: .topLeading, horizontalSpacing: 14, verticalSpacing: 10) {
            GridRow {
                Text("Choice").fontWeight(.semibold)
                Label("Gain", systemImage: "plus.circle").foregroundStyle(.green).fontWeight(.semibold)
                Label("Cost", systemImage: "minus.circle").foregroundStyle(.orange).fontWeight(.semibold)
            }
            .font(.callout)
            Divider()
            ForEach(tradeoffs, id: \.self) { t in
                GridRow {
                    md(t.choice).fontWeight(.medium)
                    md(t.pro)
                    md(t.con)
                }
                .textSelection(.enabled)
                .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.primary.opacity(0.04)))
    }
}

/// Interview questions with the answer hidden until asked for — try it yourself first.
struct QuestionList: View {
    let questions: [Question]
    @State private var revealed: Set<Int> = []

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(Array(questions.enumerated()), id: \.offset) { i, q in
                Card {
                    HStack(alignment: .firstTextBaseline) {
                        Image(systemName: "questionmark.bubble").foregroundStyle(Layer.expert.color)
                        md(q.q).fontWeight(.medium).fixedSize(horizontal: false, vertical: true)
                    }
                    if revealed.contains(i) {
                        md(q.a).textSelection(.enabled).padding(.top, 6)
                            .fixedSize(horizontal: false, vertical: true)
                    } else {
                        Button("Show answer") { withAnimation { _ = revealed.insert(i) } }
                            .buttonStyle(.link)
                            .padding(.top, 4)
                    }
                }
            }
        }
    }
}

// MARK: - Diagram

/// A left-to-right flow of labelled boxes joined by arrows; wraps onto new rows when narrow.
struct DiagramView: View {
    let diagram: Diagram
    var tint: Color = Layer.picture.color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            FlowLayout(spacing: 6, rowSpacing: 12) {
                ForEach(Array(diagram.steps.enumerated()), id: \.offset) { i, step in
                    HStack(spacing: 6) {
                        VStack(spacing: 3) {
                            Text(step.label).font(.callout.weight(.semibold)).multilineTextAlignment(.center)
                            Text(step.detail).font(.caption).foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(width: 118)
                        .frame(minHeight: 58)
                        .padding(.horizontal, 6)
                        .background(RoundedRectangle(cornerRadius: 9).fill(tint.opacity(0.10)))
                        .overlay(RoundedRectangle(cornerRadius: 9).strokeBorder(tint.opacity(0.45)))
                        if i < diagram.steps.count - 1 {
                            Image(systemName: "arrow.right").font(.caption.weight(.bold)).foregroundStyle(tint)
                        }
                    }
                }
            }
            md(diagram.caption).font(.caption).foregroundStyle(.secondary).italic()
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.primary.opacity(0.025)))
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    var rowSpacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = arrange(width: proposal.width ?? .infinity, subviews: subviews)
        let height = rows.map(\.height).reduce(0, +) + rowSpacing * CGFloat(max(rows.count - 1, 0))
        let width = rows.map(\.width).max() ?? 0
        return CGSize(width: proposal.width ?? width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var y = bounds.minY
        for row in arrange(width: bounds.width, subviews: subviews) {
            var x = bounds.minX
            for index in row.indices {
                let size = subviews[index].sizeThatFits(.unspecified)
                subviews[index].place(at: CGPoint(x: x, y: y + (row.height - size.height) / 2),
                                      proposal: ProposedViewSize(size))
                x += size.width + spacing
            }
            y += row.height + rowSpacing
        }
    }

    private struct Row { var indices: [Int] = []; var width: CGFloat = 0; var height: CGFloat = 0 }

    private func arrange(width: CGFloat, subviews: Subviews) -> [Row] {
        var rows: [Row] = [Row()]
        for (i, view) in subviews.enumerated() {
            let size = view.sizeThatFits(.unspecified)
            let extra = rows[rows.count - 1].indices.isEmpty ? size.width : spacing + size.width
            if rows[rows.count - 1].width + extra > width, !rows[rows.count - 1].indices.isEmpty {
                rows.append(Row())
            }
            let added = rows[rows.count - 1].indices.isEmpty ? size.width : spacing + size.width
            rows[rows.count - 1].indices.append(i)
            rows[rows.count - 1].width += added
            rows[rows.count - 1].height = max(rows[rows.count - 1].height, size.height)
        }
        return rows
    }
}

// MARK: - Related

struct RelatedChips: View {
    let ids: [String]
    @EnvironmentObject private var library: Library
    @EnvironmentObject private var nav: Navigator

    var body: some View {
        FlowLayout(spacing: 8, rowSpacing: 8) {
            ForEach(ids, id: \.self) { id in
                if let topic = library.topic(id), let domain = library.domain(ofTopic: id) {
                    Button {
                        nav.go(to: .topic(id))
                    } label: {
                        Label(topic.title, systemImage: domain.symbol)
                            .font(.callout)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .background(Capsule().fill(Color.accentColor.opacity(0.12)))
                    }
                    .buttonStyle(.plain)
                    .help("\(domain.name): \(topic.gist)")
                }
            }
        }
    }
}

/// Keeps reading text at a comfortable line length.
struct ReadingColumn<Content: View>: View {
    @ViewBuilder let content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 8) { content }
            .frame(maxWidth: 820, alignment: .leading)
            .padding(.horizontal, 36)
            .padding(.vertical, 28)
            .frame(maxWidth: .infinity)
    }
}
