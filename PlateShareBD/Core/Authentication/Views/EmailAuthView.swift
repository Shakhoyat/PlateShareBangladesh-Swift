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
                                colors: [.psGreen, .psGreenDark],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .padding(.bottom, 8)

                    Text(isSignUp ? "Create Account" : "Welcome Back")
                        .font(.title2.bold())
                        .foregroundColor(.psTextPrimary)

                    Text(isSignUp ? "অ্যাকাউন্ট তৈরি করুন" : "আবার স্বাগতম")
                        .font(.subheadline)
                        .foregroundColor(.psTextSecondary)
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
                    .autocapitalization(.none)
                    .disableAutocorrection(true)

                    PSTextField(
                        placeholder: "Password (min 6 characters)",
                        text: $password,
                        icon: "lock.fill",
                        isSecure: true
                    )
                    .focused($focusedField, equals: .password)
                    .textContentType(isSignUp ? .newPassword : .password)
                }

                // Submit
                PSButton(
                    isSignUp ? "Create Account" : "Sign In",
                    isLoading: authViewModel.isLoading
                ) {
                    Task {
                        if isSignUp {
                            await authViewModel.register(email: email, password: password)
                        } else {
                            await authViewModel.signIn(email: email, password: password)
                        }
                    }
                }
                .disabled(email.isEmpty || password.count < 6)

                // Toggle sign-in / sign-up
                Button {
                    withAnimation(.easeInOut) {
                        isSignUp.toggle()
                        authViewModel.errorMessage = nil
                    }
                } label: {
                    Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                        .font(.footnote.weight(.medium))
                        .foregroundColor(.psGreen)
                }

                // Error display
                if let error = authViewModel.errorMessage {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.psError)
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.psError)
                    }
                    .padding(12)
                    .background(Color.psError.opacity(0.1))
                    .cornerRadius(8)
                }

                Spacer()
            }
            .padding(24)
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { focusedField = .email }
    }
}

#Preview {
    NavigationStack {
        EmailAuthView()
            .environmentObject(AuthViewModel())
    }
}
