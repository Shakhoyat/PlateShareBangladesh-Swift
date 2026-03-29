//
//  EmailAuthView.swift
//  PlateShareBD
//
//  Created by PlateShare Team.
//

import SwiftUI

struct EmailAuthView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @FocusState private var focusedField: Field?

    enum Field { case email, password }

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "envelope.badge.shield.half.filled")
                        .font(.system(size: 50))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.psAccent, .psAccentDark],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .padding(.bottom, 8)

                    Text(isSignUp ? "Create Account" : "Welcome Back")
                        .font(.title2.bold())
                        .foregroundStyle(Color.psTextPrimary)

                    Text(isSignUp ? "অ্যাকাউন্ট তৈরি করুন" : "আবার স্বাগতম")
                        .font(.subheadline)
                        .foregroundStyle(Color.psTextSecondary)
                }
                .padding(.top, 20)

                // Email & Password fields
                VStack(spacing: 14) {
                    PSTextField(
                        placeholder: "Email address",
                        text: $email,
                        keyboardType: .emailAddress,
                        icon: "envelope.fill"
                    )
                    .focused($focusedField, equals: .email)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.next)
                    .onSubmit { focusedField = .password }

                    PSTextField(
                        placeholder: "Password (min 6 characters)",
                        text: $password,
                        icon: "lock.fill",
                        isSecure: true
                    )
                    .focused($focusedField, equals: .password)
                    .textContentType(isSignUp ? .newPassword : .password)
                    .submitLabel(.done)
                    .onSubmit { submitAuth() }
                }

                // Submit
                PSButton(
                    isSignUp ? "Create Account" : "Sign In",
                    isLoading: authViewModel.isLoading
                ) {
                    submitAuth()
                }
                .disabled(email.isEmpty || password.count < 6)

                // Toggle sign-in / sign-up
                Button {
                    PSHaptics.selection()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isSignUp.toggle()
                        authViewModel.errorMessage = nil
                    }
                } label: {
                    Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(Color.psAccent)
                }

                // Error display
                if let error = authViewModel.errorMessage {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(Color.psError)
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(Color.psError)
                    }
                    .padding(12)
                    .background(Color.psError.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .transition(.move(edge: .top).combined(with: .opacity))
                }

                Spacer()
            }
            .padding(24)
            .animation(.spring(response: 0.35, dampingFraction: 0.75), value: authViewModel.errorMessage != nil)
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { focusedField = .email }
        .onChange(of: authViewModel.errorMessage) { _, newError in
            if newError != nil { PSHaptics.error() }
        }
    }

    private func submitAuth() {
        guard !email.isEmpty, password.count >= 6 else { return }
        focusedField = nil
        Task {
            if isSignUp {
                await authViewModel.register(email: email, password: password)
            } else {
                await authViewModel.signIn(email: email, password: password)
            }
        }
    }
}

#Preview {
    NavigationStack {
        EmailAuthView()
            .environmentObject(AuthViewModel())
    }
}
