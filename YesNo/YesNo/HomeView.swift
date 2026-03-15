import SwiftUI

struct HomeView: View {
    @Binding var currentView: ViewType
    @State private var showCodeAlert = false
    @State private var secretCode = ""

    var body: some View {
        VStack {
            Spacer()
            Text("Yes/No")
                .font(.largeTitle)
                .fontWeight(.bold)
            Spacer()
            VStack(spacing: 16) {
                Button(action: {
                    currentView = .setup
                }) {
                    Text("Start")
                        .font(.title)
                        .padding()
                        .frame(maxWidth: 220)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
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
                    .background(Color.purple.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: 3)
                        .onEnded { _ in
                            secretCode = ""
                            showCodeAlert = true
                        }
                )
            }
            Spacer()
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
    }
}