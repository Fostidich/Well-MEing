import SwiftUI

struct VoiceCommandsModalContent: View {
    @Environment(\.dismiss) var dismiss
    @State var speechRecognizer = SpeechRecognizer()

    var body: some View {
        VStack(alignment: .center) {
            Text(
                speechRecognizer.recognizedText.isEmpty
                    ? "Start speaking!"
                    : speechRecognizer.recognizedText
            )
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .lineLimit(1)
            .truncationMode(.head)
            .padding(.horizontal)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.5))
            )
            .foregroundColor(
                speechRecognizer.recognizedText.isEmpty
                    ? .secondary : .primary
            )
            .padding()

            RecordingButton(
                speechRecognizer: $speechRecognizer
            )
            .onAppear {
                speechRecognizer.setupSpeechRecognition()
            }
            .padding()
        }
    }
}

struct RecordingButton: View {
    @Binding var speechRecognizer: SpeechRecognizer

    var body: some View {
        // Big red recording button
        Button(action: {
            if speechRecognizer.audioEngine.isRunning {
                speechRecognizer.stopListening()
            } else {
                speechRecognizer.startListening()
            }
        }) {
            Circle()
                .fill(Color.red)
                .frame(width: 80, height: 80)
                .overlay(
                    Image(
                        systemName: speechRecognizer
                            .startedListening
                            ? "stop.fill" : "mic.fill"
                    )
                    .foregroundColor(.white)
                    .font(.system(size: 30))
                )
                .shadow(radius: 5)
        }
    }
}

#Preview {
    VoiceCommandsModalContent()
}
