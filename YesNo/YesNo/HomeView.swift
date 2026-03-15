import SwiftUI

struct HomeView: View {
    @Binding var currentView: ViewType

    var body: some View {
        VStack {
            Spacer()
            Text("Yes/No")
                .font(.largeTitle)
                .fontWeight(.bold)
            Spacer()
            Button(action: {
                currentView = .setup
            }) {
                Text("Start")
                    .font(.title)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            Spacer()
        }
    }
}