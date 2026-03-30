//
//  ProfileSetupView.swift
//  PlateShareBD
//
//  Created by PlateShare Team.
//

import SwiftUI
import PhotosUI

struct ProfileSetupView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var displayName = ""
    @State private var area = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var profileImage: UIImage?

    // Common areas in Dhaka for quick selection
    private let popularAreas = [
        "Dhanmondi", "Gulshan", "Banani", "Uttara",
        "Mirpur", "Mohammadpur", "Motijheel", "Old Dhaka",
        "Bashundhara", "Baridhara", "Khilgaon", "Badda"
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Set Up Your Profile")
                        .font(.title2.bold())
                        .foregroundStyle(Color.psTextPrimary)
                    Text("আপনার প্রোফাইল সেট আপ করুন")
                        .font(.subheadline)
                        .foregroundStyle(Color.psTextSecondary)
                }
                .padding(.top, 20)

                // Profile Photo
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    ZStack(alignment: .bottomTrailing) {
                        if let image = profileImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .foregroundStyle(Color.psTextSecondary.opacity(0.3))
                        }

                        Image(systemName: "camera.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(Color.psAccent)
                            .background(Circle().fill(.white).frame(width: 24, height: 24))
                    }
                }
                .onChange(of: selectedPhoto) { _, newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            profileImage = image
                        }
                    }
                }

                // Name field
                VStack(alignment: .leading, spacing: 6) {
                    Text("Your Name")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color.psTextSecondary)
                    PSTextField(placeholder: "Enter your name", text: $displayName, icon: "person.fill")
                }

                // Area selection
                VStack(alignment: .leading, spacing: 10) {
                    Text("Your Area / মহল্লা")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color.psTextSecondary)

                    PSTextField(placeholder: "Enter your area", text: $area, icon: "mappin.and.ellipse")

                    // Quick area selection chips
                    FlowLayout(spacing: 8) {
                        ForEach(popularAreas, id: \.self) { areaName in
                            Button {
                                area = areaName
                            } label: {
                                Text(areaName)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(area == areaName ? Color.psAccent : Color(.systemGray6))
                                    .foregroundStyle(area == areaName ? Color.white : Color.psTextPrimary)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                        }
                    }
                }

                // Submit button
                PSButton("Complete Profile", isLoading: authViewModel.isLoading) {
                    Task {
                        await authViewModel.completeProfileSetup(
                            displayName: displayName.trimmingCharacters(in: .whitespacesAndNewlines),
                            area: area.trimmingCharacters(in: .whitespacesAndNewlines),
                            profileImage: profileImage
                        )
                    }
                }
                .disabled(
                    displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                    area.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                )
                .padding(.top, 8)

                // Error
                if let error = authViewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(Color.psError)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(24)
        }
    }
}

// Simple flow layout for area chips
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> (positions: [CGPoint], size: CGSize) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }

            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            maxX = max(maxX, currentX)
        }

        return (positions, CGSize(width: maxX, height: currentY + lineHeight))
    }
}

#Preview {
    ProfileSetupView()
        .environmentObject(AuthViewModel())
}
