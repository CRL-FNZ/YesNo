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

                Button(action: {
                    currentView = .burkard
                }) {
                    HStack {
                        Image(systemName: "person.2.fill")
                        Text("Burkard")
                    }
                    .font(.title)
                    .padding()
                    .frame(maxWidth: 220)
                    .background(Color.yellow.opacity(0.9))
                    .foregroundColor(.black)
                    .cornerRadius(10)
                }
            }
            Spacer()
        }
    }
}