import Foundation

// Shapes match docs/CONTENT-SCHEMA.md.

struct Domain: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let symbol: String
    let summary: String
    let topics: [Topic]
}

struct Diagram: Codable, Hashable {
    struct Step: Codable, Hashable {
        let label: String
        let detail: String
    }
    let caption: String
    let steps: [Step]
}

struct Component: Codable, Hashable { let name: String; let role: String }
struct Tradeoff: Codable, Hashable { let choice: String; let pro: String; let con: String }
struct Number: Codable, Hashable { let metric: String; let value: String }
struct FailureMode: Codable, Hashable { let name: String; let description: String }
struct RealSystem: Codable, Hashable { let name: String; let note: String }
struct Question: Codable, Hashable { let q: String; let a: String }

struct Topic: Codable, Identifiable, Hashable {
    struct HowItWorks: Codable, Hashable {
        let components: [Component]
        let flow: [String]
        let tradeoffs: [Tradeoff]
        let numbers: [Number]
    }
    struct Expert: Codable, Hashable {
        let details: [String]
        let failureModes: [FailureMode]
        let realSystems: [RealSystem]
        let questions: [Question]
    }
    let id: String
    let title: String
    let gist: String
    let overview: [String]
    let diagram: Diagram
    let howItWorks: HowItWorks
    let expert: Expert
    let related: [String]
}

struct Problem: Codable, Identifiable, Hashable {
    struct Requirements: Codable, Hashable {
        let functional: [String]
        let nonFunctional: [String]
        let estimates: [Number]
    }
    struct Stage: Codable, Hashable {
        let name: String
        let summary: String
        let points: [String]
        let deepDive: [String]
    }
    struct Expert: Codable, Hashable {
        let failureModes: [FailureMode]
        let realSystems: [RealSystem]
        let questions: [Question]
    }
    let id: String
    let title: String
    let domain: String
    let prompt: String
    let gist: String
    let overview: [String]
    let diagram: Diagram
    let requirements: Requirements
    let stages: [Stage]
    let tradeoffs: [Tradeoff]
    let expert: Expert
    let related: [String]
}

/// What the sidebar can select: a concept topic or a worked design problem.
enum Selection: Hashable {
    case topic(String)
    case problem(String)
}
