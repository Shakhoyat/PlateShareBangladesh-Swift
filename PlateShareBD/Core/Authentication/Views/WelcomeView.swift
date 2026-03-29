//
//  WelcomeView.swift
//  PlateShareBD
//
//  Created by PlateShare Team.
//

import SwiftUI

struct WelcomeView: View {
    @State private var isShowingAuth = false
    @State private var animateGradient = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Animated gradient background
                LinearGradient(
                    colors: [
                        Color.psAccent.opacity(0.2),
                        Color.psAccentLight.opacity(0.15),
                        Color.psBgPrimary
                    ],
                    startPoint: animateGradient ? .topLeading : .bottomLeading,
                    endPoint: animateGradient ? .bottomTrailing : .topTrailing
                )
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 5).repeatForever(autoreverses: true), value: animateGradient)

                VStack(spacing: 32) {
                    Spacer()

                    // Logo & Branding
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.psAccent.opacity(0.12))
                                .frame(width: 120, height: 120)

                            Image(systemName: "fork.knife.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 70, height: 70)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.psAccent, .psAccentDark],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }

                        Text("PlateShare BD")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.psTextPrimary)

                        Text("খাবার ভাগ করুন, ভালোবাসা ছড়িয়ে দিন")
                            .font(.subheadline)
                            .foregroundColor(.psTextSecondary)
                            .multilineTextAlignment(.center)

                        Text("Share food, spread love")
                            .font(.caption)
                            .foregroundColor(.psTextSecondary.opacity(0.7))
                    }

                    // Feature highlights
                    VStack(spacing: 16) {
                        FeatureRow(icon: "leaf.fill", title: "Share Surplus Food", subtitle: "From weddings, events & daily meals", color: .psAccent)
                        FeatureRow(icon: "map.fill", title: "Find Nearby", subtitle: "Discover food being shared in your area", color: .psSecondary)
                        FeatureRow(icon: "message.fill", title: "Connect Directly", subtitle: "Message donors and arrange pickup", color: .blue)
                    }
                    .padding(.horizontal, 24)

                    Spacer()

                    // CTA Button
                    VStack(spacing: 12) {
                        NavigationLink(destination: EmailAuthView()) {
                            HStack {
                                Image(systemName: "envelope.fill")
                                Text("Continue with Email")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [.psAccent, .psAccentDark],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(16)
                            .shadow(color: .psAccent.opacity(0.4), radius: 12, x: 0, y: 6)
                        }
                        .accessibilityLabel("Continue with email to sign in or create account")

                        Text("By continuing, you agree to our Terms of Service")
                            .font(.caption2)
                            .foregroundColor(.psTextSecondary)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
            }
            .onAppear {
                animateGradient = true
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String
    var color: Color = .psAccent

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(color)
                .frame(width: 44, height: 44)
                .background(color.opacity(0.12))
                .cornerRadius(12)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.psTextPrimary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.psTextSecondary)
            }

            Spacer()
        }
    }
}

#Preview {
    WelcomeView()
}
