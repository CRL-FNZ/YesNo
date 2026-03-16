import AVFoundation
import UIKit

class SoundManager {
    static let shared = SoundManager()
    private var players: [String: AVAudioPlayer] = [:]
    var soundEnabled: Bool = true

    private init() {}

    func playCorrect() {
        if soundEnabled { AudioServicesPlaySystemSound(1057) }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    func playWrong() {
        if soundEnabled { AudioServicesPlaySystemSound(1073) }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }

    func playVictory() {
        if soundEnabled { AudioServicesPlaySystemSound(1025) }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    func playTick() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    func playCountdown() {
        if soundEnabled { AudioServicesPlaySystemSound(1103) }
    }

    func playTiltHaptic(intensity: CGFloat) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred(intensity: min(intensity, 1.0))
    }
}
