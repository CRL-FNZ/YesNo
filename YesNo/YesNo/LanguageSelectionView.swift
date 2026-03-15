import SwiftUI

struct LanguageSelectionView: View {
    @Binding var selectedLanguage: Language?
    @Binding var currentView: ViewType

    var body: some View {
        VStack(spacing: 40) {
            Text("Seleziona Lingua / Sprache wählen")
                .font(.largeTitle)
                .multilineTextAlignment(.center)

            HStack(spacing: 40) {
                Button(action: {
                    selectedLanguage = .italian
                    currentView = .home
                }) {
                    VStack {
                        Text("🇮🇹")
                            .font(.system(size: 60))
                        Text("Italiano")
                            .font(.title)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(10)
                }

                Button(action: {
                    selectedLanguage = .german
                    currentView = .home
                }) {
                    VStack {
                        Text("🇩🇪")
                            .font(.system(size: 60))
                        Text("Deutsch")
                            .font(.title)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(10)
                }
            }
        }
        .padding()
    }
}