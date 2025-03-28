import SwiftUI

struct Profile: View {

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Profile data title
            Text("Your profile")
                .font(.title2)
                .bold()
                .padding(.horizontal)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Profile image
            ProfileImageCircle()
                .frame(width: 160, height: 160)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal)

            VStack(alignment: .leading, spacing: -10) {
                // Profile information
                ProfileInformationList()

                // Bio
                Biography()
            }
        }
    }
}

struct ProfileImageCircle: View {
    @State private var profileImage: Image? = nil
    let imageURL = URL(string: "https://picsum.photos/200")!

    var body: some View {
        ZStack {
            // Placeholder borders if image is not yet loaded
            if profileImage == nil {
                Circle()
                    .fill(Color.clear)
                    .overlay(Circle().stroke(Color.secondary, lineWidth: 4))  // white border
            }

            // Show profile image when available
            profileImage?
                .resizable()
                .scaledToFit()
                .clipShape(Circle())
                .overlay(
                    Circle().stroke(Color.secondary, lineWidth: 2)
                )  // white border
        }
        .onAppear {
            Task {
                profileImage = await loadImage(url: imageURL)
            }
        }
        .padding()
    }
}

struct ProfileInformationList: View {
    @State var name: String = ""
    @State var mail: String = ""

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Name")
                Spacer()
                TextField("Your name", text: $name)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.trailing)
            }
            .padding(.horizontal)
            .padding(.top)

            Divider()
                .padding(.horizontal)

            HStack {
                Text("Mail")
                Spacer()
                TextField("Your mail", text: $mail)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.trailing)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.secondary.opacity(0.20))
                .padding()
        )
    }
}

struct Biography: View {
    @State var bio: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Bio")
                .padding(.horizontal)
                .padding(.top)
                .bold()

            Text(
                "This will be used to generate personalized reports."
            )
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.horizontal)

            Divider().padding(.horizontal)

            TextField("Your bio", text: $bio)
                .foregroundColor(.secondary)
                .padding(.horizontal)
                .padding(.bottom)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.secondary.opacity(0.20))
                .padding()
        )
    }
}
