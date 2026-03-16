import SwiftUI

struct ConfettiPiece: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    let color: Color
    let size: CGFloat
    let rotation: Double
    let speed: Double
    let wobble: Double
}

struct ConfettiView: View {
    @State private var pieces: [ConfettiPiece] = []
    @State private var animating = false
    let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange, .pink, .cyan]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(pieces) { piece in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(piece.color)
                        .frame(width: piece.size, height: piece.size * 0.6)
                        .rotationEffect(.degrees(animating ? piece.rotation + 360 : piece.rotation))
                        .position(
                            x: piece.x + (animating ? CGFloat(sin(piece.wobble * 3) * 30) : 0),
                            y: animating ? geo.size.height + 50 : piece.y
                        )
                        .opacity(animating ? 0 : 1)
                }
            }
            .onAppear {
                pieces = (0..<60).map { _ in
                    ConfettiPiece(
                        x: CGFloat.random(in: 0...geo.size.width),
                        y: CGFloat.random(in: -50...0),
                        color: colors.randomElement()!,
                        size: CGFloat.random(in: 6...12),
                        rotation: Double.random(in: 0...360),
                        speed: Double.random(in: 2...4),
                        wobble: Double.random(in: 0...2 * .pi)
                    )
                }
                withAnimation(.easeIn(duration: 3)) {
                    animating = true
                }
            }
        }
        .allowsHitTesting(false)
    }
}
