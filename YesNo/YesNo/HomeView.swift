import SwiftUI

struct HomeView: View {
    @Binding var currentView: ViewType
    @ObservedObject var themeManager: ThemeManager
    @State private var showCodeAlert = false
    @State private var secretCode = ""
    @State private var showSettings = false
    @State private var titleScale: CGFloat = 0.8
    @State private var buttonsOffset: CGFloat = 50
    @State private var buttonsOpacity: Double = 0

    private var theme: AppTheme { themeManager.currentTheme }

    var body: some View {
        ZStack {
            LinearGradient(colors: theme.backgroundColor, startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)

            VStack {
                HStack {
                    Spacer()
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                            .foregroundColor(theme.textColor.opacity(0.7))
                            .padding()
                    }
                }

                Spacer()

                Text("Yes/No")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(theme.textColor)
                    .scaleEffect(titleScale)

                Spacer()

                VStack(spacing: 16) {
                    Button(action: {
                        currentView = .setup
                    }) {
                        Text("Start")
                            .font(.title)
                            .padding()
                            .frame(maxWidth: 220)
                            .background(theme.primaryColor)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                    }

                    Button(action: {
                        currentView = .think
                    }) {
                        HStack {
                            Image(systemName: "brain.head.profile")
                            Text("Think")
                        }
                        .font(.title)
                        .padding()
                        .frame(maxWidth: 220)
                        .background(theme.secondaryColor)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                    }
                    .simultaneousGesture(
                        LongPressGesture(minimumDuration: 3)
                            .onEnded { _ in
                                secretCode = ""
                                showCodeAlert = true
                            }
                    )
                }
                .offset(y: buttonsOffset)
                .opacity(buttonsOpacity)

                Spacer()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                titleScale = 1.0
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
                buttonsOffset = 0
                buttonsOpacity = 1
            }
        }
        .alert("Codice segreto", isPresented: $showCodeAlert) {
            TextField("Inserisci codice", text: $secretCode)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            Button("OK") {
                if secretCode.lowercased() == "regina" {
                    currentView = .burkard
                }
            }
            Button("Annulla", role: .cancel) {}
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(themeManager: themeManager)
        }
    }
}
