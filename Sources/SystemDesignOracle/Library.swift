import Foundation

/// All content, loaded once at launch from the Content folder.
final class Library: ObservableObject {
    /// Sidebar order, roughly bottom of the stack to the top.
    static let domainOrder = [
        "os", "gpu", "storage", "networking", "distributed", "data",
        "security", "ml-training", "inference", "autonomous-vehicles",
    ]

    let domains: [Domain]
    let problems: [Problem]
    let loadErrors: [String]

    private let topicsByID: [String: Topic]
    private let domainByTopicID: [String: Domain]
    private let searchText: [Selection: String]

    init(contentURL: URL? = Library.findContent()) {
        var domains: [Domain] = []
        var problems: [Problem] = []
        var errors: [String] = []
        let decoder = JSONDecoder()
        let fm = FileManager.default

        if let contentURL {
            let files = (try? fm.contentsOfDirectory(at: contentURL, includingPropertiesForKeys: nil)) ?? []
            for file in files where file.pathExtension == "json" {
                do { domains.append(try decoder.decode(Domain.self, from: Data(contentsOf: file))) }
                catch { errors.append("\(file.lastPathComponent): \(error)") }
            }
            let problemFiles = (try? fm.contentsOfDirectory(
                at: contentURL.appendingPathComponent("problems"), includingPropertiesForKeys: nil)) ?? []
            for file in problemFiles where file.pathExtension == "json" {
                do { problems.append(try decoder.decode(Problem.self, from: Data(contentsOf: file))) }
                catch { errors.append("problems/\(file.lastPathComponent): \(error)") }
            }
        } else {
            errors.append("Content folder not found.")
        }

        func rank(_ id: String) -> Int { Library.domainOrder.firstIndex(of: id) ?? Int.max }
        domains.sort { (rank($0.id), $0.name) < (rank($1.id), $1.name) }
        problems.sort { (rank($0.domain), $0.title) < (rank($1.domain), $1.title) }

        var topicsByID: [String: Topic] = [:]
        var domainByTopicID: [String: Domain] = [:]
        var searchText: [Selection: String] = [:]
        for d in domains {
            for t in d.topics {
                topicsByID[t.id] = t
                domainByTopicID[t.id] = d
                searchText[.topic(t.id)] = Library.haystack(t, domain: d)
            }
        }
        for p in problems {
            searchText[.problem(p.id)] = Library.haystack(p, domain: nil)
        }

        self.domains = domains
        self.problems = problems
        self.loadErrors = errors
        self.topicsByID = topicsByID
        self.domainByTopicID = domainByTopicID
        self.searchText = searchText
    }

    var topicCount: Int { topicsByID.count }

    func topic(_ id: String) -> Topic? { topicsByID[id] }
    func domain(ofTopic id: String) -> Domain? { domainByTopicID[id] }
    func domain(_ id: String) -> Domain? { domains.first { $0.id == id } }
    func problem(_ id: String) -> Problem? { problems.first { $0.id == id } }
    func problems(in domainID: String) -> [Problem] { problems.filter { $0.domain == domainID } }

    /// Every word of the query must appear somewhere in the item's text.
    func matches(_ selection: Selection, query: String) -> Bool {
        let words = query.lowercased().split(separator: " ")
        guard !words.isEmpty else { return true }
        guard let text = searchText[selection] else { return false }
        return words.allSatisfy { text.contains($0) }
    }

    /// Topics and problems in reading order, for next/previous navigation.
    var readingOrder: [Selection] {
        domains.flatMap { $0.topics.map { Selection.topic($0.id) } } + problems.map { .problem($0.id) }
    }

    // MARK: - Loading

    /// The bundled Content folder inside the .app, or the source folder when run with `swift run`.
    static func findContent() -> URL? {
        let fm = FileManager.default
        if let bundled = Bundle.main.resourceURL?.appendingPathComponent("Content"),
           fm.fileExists(atPath: bundled.path) {
            return bundled
        }
        let source = URL(fileURLWithPath: #filePath).deletingLastPathComponent().appendingPathComponent("Content")
        return fm.fileExists(atPath: source.path) ? source : nil
    }

    /// All text values of an item (not its field names), lowercased, for search.
    private static func haystack(_ item: Any, domain: Domain?) -> String {
        func strings(_ value: Any) -> [String] {
            if let s = value as? String { return [s] }
            return Mirror(reflecting: value).children.flatMap { strings($0.value) }
        }
        return (strings(item) + [domain?.name ?? ""]).joined(separator: " ").lowercased()
    }
}
