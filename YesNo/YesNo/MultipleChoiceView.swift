import SwiftUI

struct MCQuestion: Codable {
    let text: String
    let options: [String]
    let correctIndex: Int
    let category: String
}

struct MultipleChoiceView: View {
    let language: Language
    @Binding var currentView: ViewType
    @State private var questions: [MCQuestion] = []
    @State private var currentIndex: Int = 0
    @State private var selectedIndex: Int? = nil
    @State private var showResult = false
    @State private var score: Int = 0
    @State private var totalAnswered: Int = 0
    @State private var showQuestion = false

    private var isCorrect: Bool {
        selectedIndex == questions[currentIndex].correctIndex
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.teal.opacity(0.3), Color.blue.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
                // Top bar
                HStack {
                    Button(action: { currentView = .home }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text(language.backText)
                        }
                        .foregroundColor(.primary)
                    }
                    Spacer()
                    Text("Multiple Choice")
                        .font(.headline)
                    Spacer()
                    Text("\(score)/\(totalAnswered)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(width: 70)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 12)

                if !questions.isEmpty {
                    Spacer()

                    // Category
                    Text(questions[currentIndex].category.uppercased())
                        .font(.caption)
                        .tracking(2)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 8)

                    // Question
                    Text(questions[currentIndex].text)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 24)
                        .opacity(showQuestion ? 1 : 0)
                        .offset(y: showQuestion ? 0 : 20)
                        .animation(.easeOut(duration: 0.4), value: showQuestion)

                    Spacer()

                    // Options
                    VStack(spacing: 12) {
                        ForEach(0..<questions[currentIndex].options.count, id: \.self) { index in
                            Button(action: {
                                guard !showResult else { return }
                                selectedIndex = index
                                showResult = true
                                totalAnswered += 1
                                if index == questions[currentIndex].correctIndex {
                                    score += 1
                                    SoundManager.shared.playCorrect()
                                } else {
                                    SoundManager.shared.playWrong()
                                }
                            }) {
                                HStack {
                                    Text(optionLabel(index))
                                        .fontWeight(.bold)
                                        .frame(width: 30)
                                    Text(questions[currentIndex].options[index])
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                    if showResult {
                                        if index == questions[currentIndex].correctIndex {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                        } else if index == selectedIndex {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.red)
                                        }
                                    }
                                }
                                .font(.body)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(optionBackground(index))
                                .foregroundColor(optionTextColor(index))
                                .cornerRadius(12)
                            }
                            .disabled(showResult)
                        }
                    }
                    .padding(.horizontal, 24)
                    .opacity(showQuestion ? 1 : 0)
                    .animation(.easeOut(duration: 0.4).delay(0.1), value: showQuestion)

                    Spacer()

                    // Next button (visible after answering)
                    if showResult {
                        Button(action: nextQuestion) {
                            HStack {
                                Text(language.nextQuestionText)
                                Image(systemName: "arrow.right")
                            }
                            .font(.title3)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.teal.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(14)
                        }
                        .padding(.horizontal, 40)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    Spacer().frame(height: 20)
                }
            }
        }
        .onAppear {
            loadQuestions()
            showQuestion = true
        }
    }

    private func optionLabel(_ index: Int) -> String {
        ["A", "B", "C", "D"][index]
    }

    private func optionBackground(_ index: Int) -> Color {
        guard showResult else {
            return Color(.systemBackground).opacity(0.8)
        }
        if index == questions[currentIndex].correctIndex {
            return Color.green.opacity(0.3)
        }
        if index == selectedIndex {
            return Color.red.opacity(0.3)
        }
        return Color(.systemBackground).opacity(0.4)
    }

    private func optionTextColor(_ index: Int) -> Color {
        guard showResult else { return .primary }
        if index == questions[currentIndex].correctIndex {
            return .green
        }
        if index == selectedIndex {
            return .red
        }
        return .secondary
    }

    private func nextQuestion() {
        showQuestion = false
        selectedIndex = nil
        showResult = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            currentIndex = (currentIndex + 1) % questions.count
            if currentIndex == 0 {
                questions.shuffle()
            }
            showQuestion = true
        }
    }

    private func loadQuestions() {
        let jsonFile = language == .italian ? "mc_questions" : "mc_questions_de"
        guard let url = Bundle.main.url(forResource: jsonFile, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let loaded = try? JSONDecoder().decode([MCQuestion].self, from: data) else {
            return
        }
        questions = loaded.shuffled()
        currentIndex = 0
    }
}
