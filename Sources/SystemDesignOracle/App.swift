import SwiftUI

@main
struct SystemDesignOracleApp: App {
    @StateObject private var library = Library()
    @StateObject private var nav = Navigator()
    @AppStorage("depth") private var depth = 2

    init() {
        // Launched as a bare executable (`swift run`) the process would otherwise stay in the background.
        NSApplication.shared.setActivationPolicy(.regular)
    }

    var body: some Scene {
        WindowGroup("System Design Oracle") {
            ContentView(depth: $depth)
                .environmentObject(library)
                .environmentObject(nav)
                .frame(minWidth: 900, minHeight: 600)
                .onAppear { NSApplication.shared.activate(ignoringOtherApps: true) }
        }
        .defaultSize(width: 1280, height: 840)
        .commands {
            CommandGroup(after: .sidebar) {
                Divider()
                ForEach(Layer.allCases) { layer in
                    Button("Depth \(layer.rawValue): \(layer.name())") { depth = layer.rawValue }
                        .keyboardShortcut(KeyEquivalent(Character("\(layer.rawValue)")), modifiers: .command)
                }
            }
            CommandMenu("Go") {
                Button("Back") { nav.back() }
                    .keyboardShortcut("[", modifiers: .command)
                    .disabled(!nav.canGoBack)
                Button("Next Topic") { nav.step(+1, in: library.readingOrder) }
                    .keyboardShortcut(.downArrow, modifiers: [.command, .option])
                Button("Previous Topic") { nav.step(-1, in: library.readingOrder) }
                    .keyboardShortcut(.upArrow, modifiers: [.command, .option])
                Divider()
                Button("Home") { nav.go(to: nil) }
                    .keyboardShortcut("h", modifiers: [.command, .shift])
            }
            CommandGroup(replacing: .help) {
                Button("Send Feedback…") { nav.showFeedback = true }
            }
        }
    }
}

/// Current selection plus a back stack, so following a related link can be undone.
final class Navigator: ObservableObject {
    @Published var selection: Selection? {
        didSet { if !isGoingBack, oldValue != selection { history.append(oldValue) } }
    }
    @Published var showFeedback = false
    @Published private(set) var history: [Selection?] = []
    private var isGoingBack = false

    /// `-open topic:<id>` or `-open problem:<id>` on the command line opens that page (used for screenshots).
    init() {
        let open = UserDefaults.standard.string(forKey: "open") ?? ""
        if open.hasPrefix("topic:") { selection = .topic(String(open.dropFirst(6))) }
        if open.hasPrefix("problem:") { selection = .problem(String(open.dropFirst(8))) }
    }

    var canGoBack: Bool { !history.isEmpty }

    func go(to selection: Selection?) { self.selection = selection }

    func back() {
        guard let previous = history.popLast() else { return }
        isGoingBack = true
        selection = previous
        isGoingBack = false
    }

    func step(_ offset: Int, in order: [Selection]) {
        guard !order.isEmpty else { return }
        guard let current = selection, let i = order.firstIndex(of: current) else {
            selection = order.first
            return
        }
        selection = order[min(max(i + offset, 0), order.count - 1)]
    }
}

struct ContentView: View {
    @Binding var depth: Int
    @EnvironmentObject private var library: Library
    @EnvironmentObject private var nav: Navigator

    var body: some View {
        NavigationSplitView {
            Sidebar()
                .navigationSplitViewColumnWidth(min: 240, ideal: 280, max: 360)
        } detail: {
            detail
                .id(nav.selection)
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        Button { nav.back() } label: { Image(systemName: "chevron.backward") }
                            .disabled(!nav.canGoBack)
                            .help("Back (⌘[)")
                    }
                    ToolbarItem(placement: .primaryAction) {
                        HStack(spacing: 6) {
                            Text("Depth").font(.callout).foregroundStyle(.secondary)
                            DepthPicker(depth: $depth).frame(width: 150)
                        }
                    }
                }
        }
        .sheet(isPresented: $nav.showFeedback) {
            FeedbackView(context: feedbackContext)
        }
    }

    @ViewBuilder private var detail: some View {
        switch nav.selection {
        case .topic(let id):
            if let topic = library.topic(id), let domain = library.domain(ofTopic: id) {
                TopicView(topic: topic, domain: domain, depth: $depth).navigationTitle(topic.title)
            }
        case .problem(let id):
            if let problem = library.problem(id) {
                ProblemView(problem: problem, depth: $depth).navigationTitle(problem.title)
            }
        case nil:
            HomeView().navigationTitle("System Design Oracle")
        }
    }

    private var feedbackContext: String {
        switch nav.selection {
        case .topic(let id): "topic: \(id)"
        case .problem(let id): "problem: \(id)"
        case nil: "home"
        }
    }
}

struct Sidebar: View {
    @EnvironmentObject private var library: Library
    @EnvironmentObject private var nav: Navigator
    @State private var query = ""
    @State private var collapsed: Set<String> = []

    var body: some View {
        List(selection: $nav.selection) {
            let problems = library.problems.filter { library.matches(.problem($0.id), query: query) }
            if !problems.isEmpty {
                Section(isExpanded: expanded("problems")) {
                    ForEach(problems) { p in
                        Label(p.title, systemImage: "hammer")
                            .lineLimit(2)
                            .tag(Selection.problem(p.id))
                    }
                } header: {
                    Text("Design Problems")
                }
            }
            ForEach(library.domains) { domain in
                let topics = domain.topics.filter { library.matches(.topic($0.id), query: query) }
                if !topics.isEmpty {
                    Section(isExpanded: expanded(domain.id)) {
                        ForEach(topics) { t in
                            Text(t.title).lineLimit(2).tag(Selection.topic(t.id))
                        }
                    } header: {
                        Label(domain.name, systemImage: domain.symbol)
                    }
                }
            }
            if !query.isEmpty && library.readingOrder.allSatisfy({ !library.matches($0, query: query) }) {
                Text("Nothing matches “\(query)”").foregroundStyle(.secondary)
            }
        }
        .searchable(text: $query, placement: .sidebar, prompt: "Search every layer")
        .safeAreaInset(edge: .bottom) {
            HStack {
                Button { nav.go(to: nil) } label: { Label("Home", systemImage: "house") }
                Spacer()
                Button { nav.showFeedback = true } label: { Label("Feedback", systemImage: "bubble.left") }
                    .help("Report a mistake or suggest a topic")
            }
            .buttonStyle(.borderless)
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.bar)
        }
    }

    /// Sections start expanded; searching expands everything so matches are visible.
    private func expanded(_ id: String) -> Binding<Bool> {
        Binding(
            get: { !query.isEmpty || !collapsed.contains(id) },
            set: { open in if open { collapsed.remove(id) } else { collapsed.insert(id) } }
        )
    }
}

struct HomeView: View {
    @EnvironmentObject private var library: Library
    @EnvironmentObject private var nav: Navigator

    var body: some View {
        ScrollView {
            ReadingColumn {
                Text("System Design Oracle").font(.largeTitle.weight(.bold))
                Text("How real systems are built, from the kernel to the self-driving car — "
                     + "\(library.domains.count) domains, \(library.topicCount) topics and "
                     + "\(library.problems.count) worked design problems.")
                    .font(.title3).foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                SubHeading(title: "Every page reads in four layers — stop whenever you’ve had enough").padding(.top, 20)
                HStack(alignment: .top, spacing: 10) {
                    ForEach(Layer.allCases) { layer in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(layer.rawValue)  \(layer.name())").font(.headline).foregroundStyle(layer.color)
                            Text(layer.blurb).font(.callout).foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .background(RoundedRectangle(cornerRadius: 10).fill(layer.color.opacity(0.08)))
                    }
                }
                Text("Set the depth in the toolbar or with ⌘1–⌘4.").font(.caption).foregroundStyle(.secondary)

                if !library.problems.isEmpty {
                    SubHeading(title: "Design problems — worked end to end").padding(.top, 20)
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 300), spacing: 10, alignment: .top)], spacing: 10) {
                        ForEach(library.problems) { p in
                            Button { nav.go(to: .problem(p.id)) } label: {
                                Card {
                                    Text(p.title).font(.headline).multilineTextAlignment(.leading)
                                    Text(p.prompt).font(.callout).foregroundStyle(.secondary)
                                        .lineLimit(3).multilineTextAlignment(.leading)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                SubHeading(title: "Concepts by domain").padding(.top, 20)
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 300), spacing: 10, alignment: .top)], spacing: 10) {
                    ForEach(library.domains) { d in
                        Card {
                            Label(d.name, systemImage: d.symbol).font(.headline)
                            Text(d.summary).font(.callout).foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.bottom, 4)
                            ForEach(d.topics) { t in
                                Button(t.title) { nav.go(to: .topic(t.id)) }
                                    .buttonStyle(.link)
                                    .font(.callout)
                            }
                        }
                    }
                }

                if !library.loadErrors.isEmpty {
                    SubHeading(title: "Content that failed to load").padding(.top, 20)
                    Bullets(items: library.loadErrors).font(.caption.monospaced())
                }
            }
        }
    }
}
