import SwiftUI

struct GameView: View {
    @ObservedObject var gameState: GameState
    @ObservedObject var motionManager: MotionManager
    @Binding var currentView: ViewType
    @State private var showFeedback = false
    @State private var isCorrect = false
    @State private var feedbackTimer: Timer?

    @State private var ready = false
    @State private var countdown = 5
    @State private var readyTimer: Timer?

    @State private var leftOpacity = 0.4
    @State private var rightOpacity = 0.4

    @State private var progress = 0.0
    @State private var animTimer: Timer?
    @State private var currentAnimColor: Color? = nil

    private var currentQuestion: Question? {
        guard gameState.currentQuestionIndex < gameState.questions.count else { return nil }
        return gameState.questions[gameState.currentQuestionIndex]
    }

    var body: some View {
        ZStack {
            GeometryReader { geo in
                HStack(spacing: 0) {
                    Color.red.opacity(0.2).frame(width: geo.size.width / 2)
                    Color.green.opacity(0.2).frame(width: geo.size.width / 2)
                }
            }.edgesIgnoringSafeArea(.all)

            VStack {
                if showFeedback {
                    feedbackView
                } else {
                    questionView
                }
            }
        }
        .onChange(of: motionManager.rotation) { _, rot in
            let newColor = abs(rot) > 0.174 ? (rot < 0 ? Color.green : Color.red) : nil
            if newColor != currentAnimColor {
                if let color = newColor {
                    startAnim(color)
                } else {
                    resetAnim()
                }
            }
        }
        .onChange(of: gameState.isGameOver) { _, newValue in if newValue { currentView = .result } }
        .onChange(of: gameState.currentQuestionIndex) { _, _ in startCountdown() }
        .onAppear {
            gameState.startTimer()
            startCountdown()
        }
    }

    private var questionView: some View {
        VStack(spacing: 20) {
            Text("\(gameState.language.turnText) \(gameState.currentTurn + 1)").font(.headline)

            if !ready {
                Text("\(gameState.language.readQuestionText) \(countdown)").font(.subheadline).foregroundColor(.secondary)
            }

            Text(currentQuestion?.text ?? "")
                .font(.title)
                .multilineTextAlignment(.center)
                .padding()

            Spacer()

            ZStack {
                Circle().fill(Color.red.opacity(0.4)).frame(width: 300, height: 300).mask(
                    Path { p in
                        p.move(to: CGPoint(x: 150, y: 150))
                        p.addArc(center: CGPoint(x: 150, y: 150), radius: 150, startAngle: .degrees(90), endAngle: .degrees(270), clockwise: false)
                        p.closeSubpath()
                    }
                )

                Circle().fill(Color.green.opacity(0.4)).frame(width: 300, height: 300).mask(
                    Path { p in
                        p.move(to: CGPoint(x: 150, y: 150))
                        p.addArc(center: CGPoint(x: 150, y: 150), radius: 150, startAngle: .degrees(-90), endAngle: .degrees(90), clockwise: false)
                        p.closeSubpath()
                    }
                )

                Circle().fill(Color.black).frame(width: 300, height: 300).mask(
                    Path { p in
                        p.move(to: CGPoint(x: 150, y: 150))
                        p.addArc(center: CGPoint(x: 150, y: 150), radius: 150, startAngle: .degrees(260), endAngle: .degrees(280), clockwise: false)
                        p.closeSubpath()
                    }
                )

                if abs(motionManager.rotation) > 0.174 {
                    if motionManager.rotation < 0 {
                        Circle().fill(Color.green.opacity(rightOpacity)).frame(width: 300, height: 300).mask(
                            Path { p in
                                p.move(to: CGPoint(x: 150, y: 150))
                                p.addArc(center: CGPoint(x: 150, y: 150), radius: 150, startAngle: .degrees(-90), endAngle: .degrees(90), clockwise: false)
                                p.closeSubpath()
                            }
                        )
                    } else {
                        Circle().fill(Color.red.opacity(leftOpacity)).frame(width: 300, height: 300).mask(
                            Path { p in
                                p.move(to: CGPoint(x: 150, y: 150))
                                p.addArc(center: CGPoint(x: 150, y: 150), radius: 150, startAngle: .degrees(90), endAngle: .degrees(270), clockwise: false)
                                p.closeSubpath()
                            }
                        )
                    }
                }

                Image(systemName: "arrow.up")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .rotationEffect(Angle(radians: -motionManager.rotation))
                    .animation(.linear(duration: 0.1), value: motionManager.rotation)
            }.frame(height: 300)

            Spacer()

            HStack {
                ForEach(0..<gameState.scores.count, id: \.self) { i in
                    VStack {
                        Text("\(gameState.language.teamText) \(i + 1)")
                        Text("\(gameState.scores[i])")
                    }.padding()
                }
            }

            if case .timedMode = gameState.gameMode, let t = gameState.timeRemaining {
                Text("\(gameState.language.timeText) \(t)s").font(.largeTitle)
            }
        }.padding()
    }

    private var feedbackView: some View {
        VStack {
            Text(isCorrect ? gameState.language.correctText : gameState.language.wrongText)
                .font(.largeTitle)
                .foregroundColor(isCorrect ? .green : .red)
            Spacer()
        }
        .onAppear {
            feedbackTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
                showFeedback = false
                motionManager.resetStability()
            }
        }
        .onDisappear { feedbackTimer?.invalidate() }
    }

    private func validateAnswer(_ yes: Bool? = nil) {
        guard ready, let color = currentAnimColor, let question = currentQuestion else { return }
        let y = yes ?? (color == .green)
        isCorrect = y == question.answer
        gameState.submitAnswer(isYes: y)
        showFeedback = true
        resetAnim()
        stopCountdown()
    }

    private func startCountdown() {
        stopCountdown()
        ready = false
        countdown = 5
        readyTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { t in
            if countdown > 1 { countdown -= 1 } else { ready = true; t.invalidate() }
        }
    }

    private func stopCountdown() {
        readyTimer?.invalidate()
        readyTimer = nil
    }

    private func startAnim(_ color: Color) {
        animTimer?.invalidate()
        progress = 0.0
        currentAnimColor = color
        if color == .green {
            rightOpacity = 1.0; leftOpacity = 0.4
        } else {
            leftOpacity = 1.0; rightOpacity = 0.4
        }
        animTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { t in
            progress += 0.05 / 2.0
            let op = 1.0 - (1.0 * progress)
            if color == .green { rightOpacity = op } else { leftOpacity = op }
            if progress >= 1.0 { t.invalidate(); validateAnswer() }
        }
    }

    private func resetAnim() {
        animTimer?.invalidate()
        progress = 0.0
        currentAnimColor = nil
        leftOpacity = 0.4
        rightOpacity = 0.4
    }
}