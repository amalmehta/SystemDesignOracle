import SwiftUI

struct TopicView: View {
    let topic: Topic
    let domain: Domain
    @Binding var depth: Int
    @EnvironmentObject private var library: Library

    var body: some View {
        ScrollView {
            ReadingColumn {
                Label(domain.name, systemImage: domain.symbol)
                    .font(.callout.weight(.medium))
                    .foregroundStyle(.secondary)
                Text(topic.title).font(.largeTitle.weight(.bold)).textSelection(.enabled)

                // Layer 1
                LayerHeader(layer: .gist)
                md(topic.gist).font(.title3).foregroundStyle(.primary.opacity(0.85))
                    .textSelection(.enabled).fixedSize(horizontal: false, vertical: true)

                if depth >= 2 {
                    LayerHeader(layer: .picture)
                    Paragraphs(paragraphs: topic.overview)
                    DiagramView(diagram: topic.diagram).padding(.top, 8)
                }

                if depth >= 3 {
                    let h = topic.howItWorks
                    LayerHeader(layer: .mechanics)
                    SubHeading(title: "The parts")
                    NamedCards(items: h.components.map { ($0.name, $0.role) })
                    SubHeading(title: "Step by step")
                    Bullets(items: h.flow, numbered: true)
                    SubHeading(title: "Trade-offs")
                    TradeoffTable(tradeoffs: h.tradeoffs)
                    SubHeading(title: "Numbers to know")
                    NumbersGrid(numbers: h.numbers)
                }

                if depth >= 4 {
                    let e = topic.expert
                    LayerHeader(layer: .expert)
                    Paragraphs(paragraphs: e.details)
                    SubHeading(title: "How it breaks")
                    NamedCards(items: e.failureModes.map { ($0.name, $0.description) })
                    SubHeading(title: "In real systems")
                    NamedCards(items: e.realSystems.map { ($0.name, $0.note) })
                    SubHeading(title: "Test yourself")
                    QuestionList(questions: e.questions)
                }

                GoDeeperButton(depth: $depth)

                let problems = library.problems.filter { $0.related.contains(topic.id) }
                if !problems.isEmpty {
                    SubHeading(title: "Used in design problems").padding(.top, 20)
                    ProblemLinks(problems: problems)
                }
                SubHeading(title: "Related topics").padding(.top, problems.isEmpty ? 20 : 0)
                RelatedChips(ids: topic.related)
            }
        }
    }
}

struct ProblemView: View {
    let problem: Problem
    @Binding var depth: Int
    @EnvironmentObject private var library: Library

    var body: some View {
        ScrollView {
            ReadingColumn {
                Label("Design Problem · \(library.domain(problem.domain)?.name ?? problem.domain)",
                      systemImage: "hammer")
                    .font(.callout.weight(.medium))
                    .foregroundStyle(.secondary)
                Text(problem.title).font(.largeTitle.weight(.bold)).textSelection(.enabled)

                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "quote.opening").foregroundStyle(.secondary)
                    md(problem.prompt).font(.body.italic()).textSelection(.enabled)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.orange.opacity(0.08)))
                .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.orange.opacity(0.3)))
                .padding(.top, 6)

                LayerHeader(layer: .gist, forProblem: true)
                md(problem.gist).font(.title3).foregroundStyle(.primary.opacity(0.85))
                    .textSelection(.enabled).fixedSize(horizontal: false, vertical: true)

                if depth >= 2 {
                    LayerHeader(layer: .picture, forProblem: true)
                    Paragraphs(paragraphs: problem.overview)
                    DiagramView(diagram: problem.diagram, tint: .orange).padding(.top, 8)
                }

                if depth >= 3 {
                    let r = problem.requirements
                    LayerHeader(layer: .mechanics, forProblem: true)
                    SubHeading(title: "What it must do")
                    Bullets(items: r.functional)
                    SubHeading(title: "How well it must do it")
                    Bullets(items: r.nonFunctional)
                    SubHeading(title: "Back of the envelope")
                    NumbersGrid(numbers: r.estimates)
                    ForEach(Array(problem.stages.enumerated()), id: \.offset) { i, stage in
                        StageView(index: i + 1, stage: stage, showDeepDive: depth >= 4)
                    }
                    SubHeading(title: "Trade-offs")
                    TradeoffTable(tradeoffs: problem.tradeoffs)
                }

                if depth >= 4 {
                    let e = problem.expert
                    LayerHeader(layer: .expert, forProblem: true)
                    Text("Each stage above now includes its deep dive.")
                        .font(.callout).foregroundStyle(.secondary)
                    SubHeading(title: "How it breaks")
                    NamedCards(items: e.failureModes.map { ($0.name, $0.description) })
                    SubHeading(title: "In real systems")
                    NamedCards(items: e.realSystems.map { ($0.name, $0.note) })
                    SubHeading(title: "Interviewer follow-ups")
                    QuestionList(questions: e.questions)
                }

                GoDeeperButton(depth: $depth, forProblem: true)

                SubHeading(title: "Concepts used").padding(.top, 20)
                RelatedChips(ids: problem.related)
            }
        }
    }
}

private struct StageView: View {
    let index: Int
    let stage: Problem.Stage
    let showDeepDive: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Text("\(index)")
                    .font(.caption.weight(.bold)).monospacedDigit()
                    .frame(width: 20, height: 20)
                    .background(RoundedRectangle(cornerRadius: 5).fill(Color.orange.opacity(0.2)))
                Text(stage.name).font(.title3.weight(.semibold))
            }
            md(stage.summary).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
            Bullets(items: stage.points)
            if showDeepDive {
                VStack(alignment: .leading, spacing: 6) {
                    Label("Deep dive", systemImage: "arrow.down.to.line")
                        .font(.caption.weight(.semibold)).foregroundStyle(Layer.expert.color)
                    Paragraphs(paragraphs: stage.deepDive)
                }
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 10).fill(Layer.expert.color.opacity(0.06)))
            }
        }
        .padding(.top, 18)
    }
}

struct ProblemLinks: View {
    let problems: [Problem]
    @EnvironmentObject private var nav: Navigator

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(problems) { p in
                Button { nav.go(to: .problem(p.id)) } label: {
                    Label(p.title, systemImage: "hammer")
                }
                .buttonStyle(.link)
            }
        }
    }
}
