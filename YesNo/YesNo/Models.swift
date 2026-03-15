import Foundation
import Combine

enum Language {
    case italian, german
}

extension Language {
    var correctText: String {
        switch self {
        case .italian: return "Corretto!"
        case .german: return "Richtig!"
        }
    }
    
    var wrongText: String {
        switch self {
        case .italian: return "Sbagliato!"
        case .german: return "Falsch!"
        }
    }
    
    var turnText: String {
        switch self {
        case .italian: return "Turno: Squadra"
        case .german: return "Runde: Team"
        }
    }
    
    var readQuestionText: String {
        switch self {
        case .italian: return "Leggi la domanda..."
        case .german: return "Lies die Frage..."
        }
    }
    
    var timeText: String {
        switch self {
        case .italian: return "Tempo:"
        case .german: return "Zeit:"
        }
    }

    var setupTitle: String {
        switch self {
        case .italian: return "Setup Gioco"
        case .german: return "Spieleinstellungen"
        }
    }

    var categoriesText: String {
        switch self {
        case .italian: return "Categorie"
        case .german: return "Kategorien"
        }
    }

    var modeText: String {
        switch self {
        case .italian: return "Modalità"
        case .german: return "Spielmodus"
        }
    }

    var firstToText: String {
        switch self {
        case .italian: return "Primo a"
        case .german: return "Erster mit"
        }
    }

    var timedText: String {
        switch self {
        case .italian: return "A Tempo"
        case .german: return "Zeitspiel"
        }
    }

    var pointsText: String {
        switch self {
        case .italian: return "Punti"
        case .german: return "Punkte"
        }
    }

    var secondsText: String {
        switch self {
        case .italian: return "Secondi"
        case .german: return "Sekunden"
        }
    }

    var teamsTitle: String {
        switch self {
        case .italian: return "Numero Squadre"
        case .german: return "Anzahl Teams"
        }
    }

    var teamText: String {
        switch self {
        case .italian: return "Squadra"
        case .german: return "Team"
        }
    }

    var startGameText: String {
        switch self {
        case .italian: return "Inizia Gioco"
        case .german: return "Spiel starten"
        }
    }

    var resultsTitle: String {
        switch self {
        case .italian: return "Risultati Finali"
        case .german: return "Endergebnisse"
        }
    }

    var pointsSuffix: String {
        switch self {
        case .italian: return "punti"
        case .german: return "Punkte"
        }
    }

    var newGameText: String {
        switch self {
        case .italian: return "Nuova Partita"
        case .german: return "Neues Spiel"
        }
    }

    var thinkTitle: String {
        switch self {
        case .italian: return "Think"
        case .german: return "Think"
        }
    }

    var thinkSubtitle: String {
        switch self {
        case .italian: return "Rifletti e discuti"
        case .german: return "Nachdenken und diskutieren"
        }
    }

    var nextQuestionText: String {
        switch self {
        case .italian: return "Prossima domanda"
        case .german: return "Nächste Frage"
        }
    }

    var burkardTitle: String {
        switch self {
        case .italian: return "Burkard"
        case .german: return "Burkard"
        }
    }

    var burkardSubtitle: String {
        switch self {
        case .italian: return "Condividi e confrontati"
        case .german: return "Teilen und austauschen"
        }
    }

    var backText: String {
        switch self {
        case .italian: return "Indietro"
        case .german: return "Zurück"
        }
    }
}

struct QuestionJSON: Codable {
    let text: String
    let answer: Bool
    let category: String
}

struct Question {
    let text: String
    let answer: Bool // true for Yes, false for No
    let category: Category
}

enum Category: String, CaseIterable {
    case culturaGenerale
    case scienzaNatura
    case popCulture
    case storia

    func displayName(for language: Language) -> String {
        switch self {
        case .culturaGenerale:
            return language == .italian ? "Cultura Generale" : "Allgemeinwissen"
        case .scienzaNatura:
            return language == .italian ? "Scienza e Natura" : "Wissenschaft und Natur"
        case .popCulture:
            return language == .italian ? "Pop Culture" : "Popkultur"
        case .storia:
            return language == .italian ? "Storia" : "Geschichte"
        }
    }
}

enum GameMode {
    case firstTo(points: Int)
    case timedMode(seconds: Int)
}

class GameState: ObservableObject {
    @Published var currentQuestionIndex: Int = 0
    @Published var questions: [Question] = []
    @Published var scores: [Int] = []
    @Published var currentTurn: Int = 0
    @Published var gameMode: GameMode = .firstTo(points: 10)
    @Published var timeRemaining: Int? = nil
    @Published var isGameOver: Bool = false
    var language: Language = .italian
    private var gameTimer: Timer?

    init(language: Language = .italian) {
        self.language = language
        setup(numberOfTeams: 2, gameMode: .firstTo(points: 10), selectedCategories: Category.allCases)
    }

    func setup(numberOfTeams: Int, gameMode: GameMode, selectedCategories: [Category]) {
        stopTimer()
        self.gameMode = gameMode
        self.scores = Array(repeating: 0, count: numberOfTeams)
        self.questions = generateQuestions(for: selectedCategories)
        self.currentQuestionIndex = 0
        self.currentTurn = 0
        self.isGameOver = false

        if case .timedMode(let seconds) = gameMode {
            self.timeRemaining = seconds
        } else {
            self.timeRemaining = nil
        }
    }

    private func generateQuestions(for categories: [Category]) -> [Question] {
        // Load questions from JSON file
        let jsonFile = language == .italian ? "questions" : "questions_de"
        guard let url = Bundle.main.url(forResource: jsonFile, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let jsonQuestions = try? JSONDecoder().decode([QuestionJSON].self, from: data) else {
            return []
        }
        
        let categoryKeys = categories.map { $0.rawValue }
        return jsonQuestions
            .filter { categoryKeys.contains($0.category) }
            .compactMap { json -> Question? in
                guard let category = Category(rawValue: json.category) else { return nil }
                return Question(text: json.text, answer: json.answer, category: category)
            }
            .shuffled()
    }

    func submitAnswer(isYes: Bool) {
        guard currentQuestionIndex < questions.count else { return }
        let question = questions[currentQuestionIndex]
        let isCorrect = (isYes == question.answer)
        if isCorrect {
            scores[currentTurn] += 1
        }
        // Check win condition
        if case .firstTo(let points) = gameMode, scores[currentTurn] >= points {
            isGameOver = true
        } else {
            nextTurn()
        }
    }

    private func nextTurn() {
        currentTurn = (currentTurn + 1) % scores.count
        currentQuestionIndex += 1
        if currentQuestionIndex >= questions.count {
            // Shuffle or end game
            questions.shuffle()
            currentQuestionIndex = 0
        }
    }

    func startTimer() {
        stopTimer()
        guard case .timedMode = gameMode, timeRemaining != nil else { return }
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else { timer.invalidate(); return }
            if let remaining = self.timeRemaining, remaining > 0 {
                self.timeRemaining = remaining - 1
            } else {
                self.isGameOver = true
                timer.invalidate()
            }
        }
    }

    func stopTimer() {
        gameTimer?.invalidate()
        gameTimer = nil
    }
}