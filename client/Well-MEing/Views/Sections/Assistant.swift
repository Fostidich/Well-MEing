import SwiftUI

struct Assistant: View {
    @State private var showModal = false

    var body: some View {
        VStack {
            Button(action: {
                showModal.toggle()
            }) {
                ZStack {
                    // Button color fill
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.secondary.opacity(0.20))

                    // Button content
                    HStack {
                        Image(systemName: "mic.fill")
                            .font(.title3)
                            .foregroundColor(.accentColor)
                        Text("Voice command")
                            .font(.title3)
                            .bold()
                            .padding()
                            .foregroundColor(.accentColor)
                    }
                }
            }
            .sheet(isPresented: $showModal) {
                VoiceModal()
            }
        }
        .padding()
    }
}

struct VoiceModal: View {
    @Environment(\.dismiss) var dismiss
    @State var speechRecognizer = SpeechRecognizer()

    var body: some View {
        NavigationView {
            VStack {
                // Modal content
                Text(speechRecognizer.recognizedText)
                    .padding()

                Spacer()

                RecordingButton(speechRecognizer: $speechRecognizer)
                .onAppear {
                    speechRecognizer.setupSpeechRecognition()
                }
            }
            .navigationBarTitle("Voice command", displayMode: .inline)  // title in center
            .navigationBarItems(
                leading: Button("Back") {
                    dismiss()  // dismiss modal
                })
        }
    }
}

struct RecordingButton: View {
    @Binding var speechRecognizer: SpeechRecognizer
    
    var body: some View {
        ZStack {
            // Pulsing animation only when recording
            if speechRecognizer.startedListening {
                Circle()
                    .stroke(Color.red, lineWidth: 4)
                    .frame(width: 80, height: 80)  // keep size fixed to avoid shifting
                    .scaleEffect(
                        speechRecognizer.startedListening ? 1.3 : 1
                    )
                    .opacity(speechRecognizer.startedListening ? 0 : 1)
                    .animation(
                        Animation.easeInOut(duration: 1).repeatForever(
                            autoreverses: false),
                        value: speechRecognizer.startedListening
                    )
            }
            
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
}

