import SwiftUI

struct SettingsView: View {
    @ObservedObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Suoni / Sounds")) {
                    Toggle(isOn: Binding(
                        get: { SoundManager.shared.soundEnabled },
                        set: { SoundManager.shared.soundEnabled = $0 }
                    )) {
                        HStack {
                            Image(systemName: SoundManager.shared.soundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                            Text("Suoni / Sounds")
                        }
                    }
                }

                Section(header: Text("Tema / Theme")) {
                    ForEach(AppTheme.allCases) { theme in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                themeManager.currentTheme = theme
                            }
                        }) {
                            HStack {
                                Circle()
                                    .fill(theme.primaryColor)
                                    .frame(width: 30, height: 30)
                                Circle()
                                    .fill(theme.secondaryColor)
                                    .frame(width: 30, height: 30)
                                Text(theme.rawValue)
                                    .foregroundColor(.primary)
                                Spacer()
                                if themeManager.currentTheme == theme {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }

                Section(header: Text("Avatar Squadre / Team Avatars")) {
                    ForEach(0..<4, id: \.self) { teamIndex in
                        HStack {
                            Text("Team \(teamIndex + 1)")
                                .frame(width: 60, alignment: .leading)
                            Spacer()
                            HStack(spacing: 4) {
                                ForEach(TeamAvatar.allCases) { avatar in
                                    Image(systemName: avatar.rawValue)
                                        .font(.body)
                                        .foregroundColor(avatar.color)
                                        .frame(width: 32, height: 32)
                                        .background(
                                            Circle()
                                                .fill(themeManager.teamAvatars[teamIndex] == avatar ?
                                                      avatar.color.opacity(0.3) : Color.clear)
                                        )
                                        .overlay(
                                            Circle()
                                                .stroke(themeManager.teamAvatars[teamIndex] == avatar ?
                                                        avatar.color : Color.clear, lineWidth: 2)
                                        )
                                        .onTapGesture {
                                            themeManager.teamAvatars[teamIndex] = avatar
                                        }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("OK") { dismiss() }
                }
            }
        }
    }
}
