import SwiftUI

struct ThinkQuestion: Codable {
    let text: String
    let category: String
}

struct ThinkView: View {
    let language: Language
    @Binding var currentView: ViewType
    @State private var questions: [ThinkQuestion] = []
    @State private var currentIndex: Int = 0
    @State private var showQuestion = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.purple.opacity(0.3), Color.indigo.opacity(0.2)],
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
                    Text(language.thinkTitle)
                        .font(.headline)
                    Spacer()
                    Color.clear.frame(width: 70)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 12)

                // Question centered
                Spacer()

                if !questions.isEmpty {
                    VStack(spacing: 16) {
                        Text(questions[currentIndex].category)
                            .font(.caption)
                            .textCase(.uppercase)
                            .tracking(2)
                            .foregroundColor(.secondary)

                        Text(questions[currentIndex].text)
                            .font(.title2)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                            .opacity(showQuestion ? 1 : 0)
                            .offset(y: showQuestion ? 0 : 20)
                            .animation(.easeOut(duration: 0.5), value: showQuestion)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                    )
                    .padding(.horizontal)
                }

                Spacer()

                // Bottom
                Text(language.thinkSubtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 8)

                Button(action: nextQuestion) {
                    HStack {
                        Text(language.nextQuestionText)
                        Image(systemName: "arrow.right")
                    }
                    .font(.title3)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.purple.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(14)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            loadQuestions()
            showQuestion = true
        }
    }

    private func loadQuestions() {
        let jsonFile = language == .italian ? "think_questions" : "think_questions_de"
        guard let url = Bundle.main.url(forResource: jsonFile, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let loaded = try? JSONDecoder().decode([ThinkQuestion].self, from: data) else {
            return
        }
        questions = loaded.shuffled()
        currentIndex = 0
    }

    private func nextQuestion() {
        showQuestion = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            currentIndex = (currentIndex + 1) % questions.count
            if currentIndex == 0 {
                questions.shuffle()
            }
            showQuestion = true
        }
    }
}
