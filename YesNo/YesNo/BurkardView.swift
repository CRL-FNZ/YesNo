import SwiftUI

struct BurkardQuestion: Codable {
    let text: String
    let category: String
    let image: String?
}

struct BurkardView: View {
    let language: Language
    @Binding var currentView: ViewType
    @State private var questions: [BurkardQuestion] = []
    @State private var currentIndex: Int = 0
    @State private var showQuestion = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.yellow.opacity(0.3), Color.orange.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)

            VStack(spacing: 16) {
                HStack {
                    Button(action: { currentView = .home }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text(language.backText)
                        }
                        .foregroundColor(.primary)
                    }
                    Spacer()
                    Text(language.burkardTitle)
                        .font(.headline)
                    Spacer()
                    Color.clear.frame(width: 70)
                }
                .padding(.horizontal)

                if !questions.isEmpty {
                    Spacer()

                    Text(questions[currentIndex].category)
                        .font(.caption)
                        .textCase(.uppercase)
                        .tracking(2)
                        .foregroundColor(.secondary)

                    if let imageName = questions[currentIndex].image,
                       let uiImage = UIImage(named: imageName) ?? loadBundleImage(named: imageName) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(16)
                            .padding(.horizontal, 16)
                            .opacity(showQuestion ? 1 : 0)
                            .animation(.easeOut(duration: 0.5), value: showQuestion)
                    }

                    Text(questions[currentIndex].text)
                        .font(.title3)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .foregroundColor(.secondary)
                        .opacity(showQuestion ? 1 : 0)
                        .offset(y: showQuestion ? 0 : 20)
                        .animation(.easeOut(duration: 0.5), value: showQuestion)

                    Spacer()
                }

                Text(language.burkardSubtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Button(action: nextQuestion) {
                    HStack {
                        Text(language.nextQuestionText)
                        Image(systemName: "arrow.right")
                    }
                    .font(.title3)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.yellow.opacity(0.9))
                    .foregroundColor(.black)
                    .cornerRadius(14)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 20)
            }
            .padding(.top)
        }
        .onAppear {
            loadQuestions()
            showQuestion = true
        }
    }

    private func loadBundleImage(named name: String) -> UIImage? {
        if let url = Bundle.main.url(forResource: name, withExtension: "png"),
           let data = try? Data(contentsOf: url) {
            return UIImage(data: data)
        }
        return nil
    }

    private func loadQuestions() {
        let jsonFile = language == .italian ? "burkard_questions" : "burkard_questions_de"
        guard let url = Bundle.main.url(forResource: jsonFile, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let loaded = try? JSONDecoder().decode([BurkardQuestion].self, from: data) else {
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
