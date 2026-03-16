import SwiftUI

struct GameView: View {
    @ObservedObject var gameState: GameState
    @ObservedObject var motionManager: MotionManager
    @ObservedObject var themeManager: ThemeManager
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
    @State private var arrowLocked = true
    @State private var lastHapticProgress: CGFloat = 0.0
    @State private var feedbackScale: CGFloat = 0.5
    @State private var feedbackOpacity: Double = 0
    @State private var questionOpacity: Double = 0
    @State private var questionOffset: CGFloat = 30
    private let baseDuration: TimeInterval = 3.0

    private var theme: AppTheme { themeManager.currentTheme }

    private var currentQuestion: Question? {
        guard gameState.currentQuestionIndex < gameState.questions.count else { return nil }
        return gameState.questions[gameState.currentQuestionIndex]
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: theme.backgroundColor, startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)

            GeometryReader { geo in
                HStack(spacing: 0) {
                    theme.wrongColor.opacity(0.15).frame(width: geo.size.width / 2)
                    theme.correctColor.opacity(0.15).frame(width: geo.size.width / 2)
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
            let newColor = abs(rot) > 0.174 ? (rot < 0 ? theme.correctColor : theme.wrongColor) : nil
            if newColor != currentAnimColor {
                if newColor != nil {
                    lastUpdateTime = Date()
                    confirmProgress = 0
                    lastHapticProgress = 0
                } else {
                    lastUpdateTime = nil
                    confirmProgress = 0
                    lastHapticProgress = 0
                }
                currentAnimColor = newColor
            }
            if let last = lastUpdateTime, currentAnimColor != nil {
                let now = Date()
                let dt = now.timeIntervalSince(last)
                lastUpdateTime = now
                let tiltRatio = min((abs(rot) - 0.174) / (1.57 - 0.174), 1.0)
                let speed = 0.2 + tiltRatio * 2.8
                confirmProgress = min(confirmProgress + CGFloat(dt * speed / baseDuration), 1.0)

                // Haptic feedback at progress milestones
                if confirmProgress - lastHapticProgress >= 0.15 {
                    SoundManager.shared.playTiltHaptic(intensity: confirmProgress)
                    lastHapticProgress = confirmProgress
                }

                if confirmProgress >= 1.0 {
                    validateAnswer()
                }
            }
        }
        .onChange(of: gameState.isGameOver) { _, newValue in if newValue { currentView = .result } }
        .onAppear {
            gameState.startTimer()
            startCountdown()
        }
    }

    private var questionView: some View {
        VStack(spacing: 20) {
            HStack {
                if gameState.scores.count > 1 {
                    let avatar = themeManager.teamAvatars[gameState.currentTurn % themeManager.teamAvatars.count]
                    Image(systemName: avatar.rawValue)
                        .foregroundColor(avatar.color)
                        .font(.title2)
                }
                Text("\(gameState.language.turnText) \(gameState.currentTurn + 1)")
                    .font(.headline)
                    .foregroundColor(theme.textColor)
            }

            if !ready {
                Text("\(gameState.language.readQuestionText) \(countdown)")
                    .font(.subheadline)
                    .foregroundColor(theme.textColor.opacity(0.6))
            }

            Text(currentQuestion?.text ?? "")
                .font(.title2)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal)
                .foregroundColor(theme.textColor)
                .opacity(questionOpacity)
                .offset(y: questionOffset)
                .onAppear {
                    withAnimation(.easeOut(duration: 0.6)) {
                        questionOpacity = 1
                        questionOffset = 0
                    }
                }

            Spacer()

            ZStack {
                let circleSize: CGFloat = 200

                Circle().fill(theme.wrongColor.opacity(0.4)).frame(width: circleSize, height: circleSize).mask(
                    Path { p in
                        let r = circleSize / 2
                        p.move(to: CGPoint(x: r, y: r))
                        p.addArc(center: CGPoint(x: r, y: r), radius: r, startAngle: .degrees(90), endAngle: .degrees(270), clockwise: false)
                        p.closeSubpath()
                    }
                )

                Circle().fill(theme.correctColor.opacity(0.4)).frame(width: circleSize, height: circleSize).mask(
                    Path { p in
                        let r = circleSize / 2
                        p.move(to: CGPoint(x: r, y: r))
                        p.addArc(center: CGPoint(x: r, y: r), radius: r, startAngle: .degrees(-90), endAngle: .degrees(90), clockwise: false)
                        p.closeSubpath()
                    }
                )

                Circle().fill(Color.black).frame(width: circleSize, height: circleSize).mask(
                    Path { p in
                        let r = circleSize / 2
                        p.move(to: CGPoint(x: r, y: r))
                        p.addArc(center: CGPoint(x: r, y: r), radius: r, startAngle: .degrees(260), endAngle: .degrees(280), clockwise: false)
                        p.closeSubpath()
                    }
                )

                if let color = currentAnimColor {
                    let isGreen = color == theme.correctColor
                    let startAngle: Double = isGreen ? -90 : 270
                    let endAngle = isGreen ? startAngle + 180 * confirmProgress : startAngle - 180 * confirmProgress
                    Circle().fill(color).frame(width: circleSize, height: circleSize).mask(
                        Path { p in
                            let r = circleSize / 2
                            p.move(to: CGPoint(x: r, y: r))
                            p.addArc(center: CGPoint(x: r, y: r), radius: r,
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
                    .frame(width: 36, height: 36)
                    .foregroundColor(theme.textColor)
                    .rotationEffect(Angle(radians: arrowLocked ? 0 : -motionManager.rotation))
                    .animation(.easeOut(duration: 0.15), value: motionManager.rotation)
            }.frame(height: 200)

            Spacer()

            HStack {
                ForEach(0..<gameState.scores.count, id: \.self) { i in
                    let avatar = themeManager.teamAvatars[i % themeManager.teamAvatars.count]
                    VStack(spacing: 4) {
                        Image(systemName: avatar.rawValue)
                            .foregroundColor(avatar.color)
                            .font(.title3)
                        Text("\(gameState.language.teamText) \(i + 1)")
                            .font(.caption)
                        Text("\(gameState.scores[i])")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(i == gameState.currentTurn ? theme.primaryColor.opacity(0.3) : Color.clear)
                    )
                    .foregroundColor(theme.textColor)
                }
            }

            if case .timedMode = gameState.gameMode, let t = gameState.timeRemaining {
                Text("\(gameState.language.timeText) \(t)s")
                    .font(.largeTitle)
                    .foregroundColor(t <= 10 ? theme.wrongColor : theme.textColor)
                    .scaleEffect(t <= 5 ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: t)
            }
        }.padding()
    }

    private var feedbackView: some View {
        VStack {
            Spacer()
            Text(isCorrect ? gameState.language.correctText : gameState.language.wrongText)
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(isCorrect ? theme.correctColor : theme.wrongColor)
                .scaleEffect(feedbackScale)
                .opacity(feedbackOpacity)
            Spacer()
        }
        .onAppear {
            // Play sound and haptic
            if isCorrect {
                SoundManager.shared.playCorrect()
            } else {
                SoundManager.shared.playWrong()
            }

            // Animate feedback text
            withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                feedbackScale = 1.2
                feedbackOpacity = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeOut(duration: 0.2)) {
                    feedbackScale = 1.0
                }
            }

            feedbackTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
                withAnimation(.easeOut(duration: 0.3)) {
                    feedbackOpacity = 0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showFeedback = false
                    feedbackScale = 0.5
                    questionOpacity = 0
                    questionOffset = 30
                    motionManager.resetStability()
                    startCountdown()
                }
            }
        }
        .onDisappear { feedbackTimer?.invalidate() }
    }

    private func validateAnswer(_ yes: Bool? = nil) {
        guard ready, let color = currentAnimColor, let question = currentQuestion else { return }
        let y = yes ?? (color == theme.correctColor)
        isCorrect = y == question.answer
        gameState.submitAnswer(isYes: y)
        motionManager.paused = true
        showFeedback = true
        resetAnim()
        stopCountdown()
    }

    private func startCountdown() {
        stopCountdown()
        resetAnim()
        motionManager.resetReference()
        arrowLocked = true
        ready = false
        countdown = 5
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            motionManager.paused = false
            arrowLocked = false
        }
        readyTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { t in
            SoundManager.shared.playCountdown()
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
        lastHapticProgress = 0
    }
}
