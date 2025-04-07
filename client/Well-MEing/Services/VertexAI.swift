import FirebaseVertexAI

func talkToGemini(prompt: String) async throws -> String {
    // Initialize the Vertex AI service
    let vertex = VertexAI.vertexAI()

    // Create a `GenerativeModel` instance with a model that supports your use case
    let model = vertex.generativeModel(modelName: "gemini-2.0-flash")

    // To generate text output, call generateContent with the text input
    let response = try await model.generateContent(prompt)
    return response.text ?? "No text in response."
}
