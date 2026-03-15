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

    @State private var confirmProgress: CGFloat = 0.0
    @State private var currentAnimColor: Color? = nil
    @State private var lastUpdateTime: Date? = nil
    private let baseDuration: TimeInterval = 3.0

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
                if newColor != nil {
                    lastUpdateTime = Date()
                    confirmProgress = 0
                } else {
                    lastUpdateTime = nil
                    confirmProgress = 0
                }
                currentAnimColor = newColor
            }
            if let last = lastUpdateTime, currentAnimColor != nil {
                let now = Date()
                let dt = now.timeIntervalSince(last)
                lastUpdateTime = now
                // abs(rot) va da ~0.174 (10°) a ~1.57 (90°), mappiamo a speed 0.2x..3x
                let tiltRatio = min((abs(rot) - 0.174) / (1.57 - 0.174), 1.0)
                let speed = 0.2 + tiltRatio * 2.8
                confirmProgress = min(confirmProgress + CGFloat(dt * speed / baseDuration), 1.0)
                if confirmProgress >= 1.0 {
                    validateAnswer()
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

                if let color = currentAnimColor {
                    let isGreen = color == .green
                    let startAngle: Double = isGreen ? -90 : 270
                    let endAngle = isGreen ? startAngle + 180 * confirmProgress : startAngle - 180 * confirmProgress
                    Circle().fill(color).frame(width: 300, height: 300).mask(
                        Path { p in
                            p.move(to: CGPoint(x: 150, y: 150))
                            p.addArc(center: CGPoint(x: 150, y: 150), radius: 150,
                                     startAngle: .degrees(startAngle),
                                     endAngle: .degrees(endAngle),
                                     clockwise: !isGreen)
                            p.closeSubpath()
                        }
                    )
                    .animation(.linear(duration: 0.05), value: confirmProgress)
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

    private func resetAnim() {
        lastUpdateTime = nil
        confirmProgress = 0
        currentAnimColor = nil
    }
}