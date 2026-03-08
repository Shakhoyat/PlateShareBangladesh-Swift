//
//  PhoneAuthView.swift
//  PlateShareBD
//
//  Created by PlateShare Team.
//

import SwiftUI

struct PhoneAuthView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var phoneNumber = ""
    @State private var otpCode = ""
    @FocusState private var focusedField: Field?

    enum Field { case phone, otp }

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "phone.badge.checkmark")
                        .font(.system(size: 50))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.psGreen, .psGreenDark],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .padding(.bottom, 8)

                    Text("Verify Your Number")
                        .font(.title2.bold())
                        .foregroundColor(.psTextPrimary)

                    Text("আপনার ফোন নম্বর যাচাই করুন")
                        .font(.subheadline)
                        .foregroundColor(.psTextSecondary)
                }
                .padding(.top, 20)

                // Phone Input
                if !authViewModel.otpSent {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Phone Number")
                            .font(.caption.weight(.medium))
                            .foregroundColor(.psTextSecondary)

                        HStack(spacing: 8) {
                            // Country code badge
                            HStack(spacing: 4) {
                                Text("🇧🇩")
                                    .font(.title3)
                                Text("+880")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundColor(.psTextPrimary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 12)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)

                            TextField("01XXXXXXXXX", text: $phoneNumber)
                                .keyboardType(.phonePad)
                                .focused($focusedField, equals: .phone)
                                .font(.body.monospacedDigit())
                                .padding(12)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                        }

                        PSButton("Send Verification Code", isLoading: authViewModel.isLoading) {
                            Task { await authViewModel.sendOTP(rawPhone: phoneNumber) }
                        }
                        .disabled(phoneNumber.count < 10)
                        .padding(.top, 8)
                    }
                }

                // OTP Input (shown after OTP sent)
                if authViewModel.otpSent {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.psGreen)
                            Text("Code sent to +880\(phoneNumber)")
                                .font(.caption)
                                .foregroundColor(.psGreen)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.psGreen.opacity(0.1))
                        .cornerRadius(8)

                        Text("Enter 6-digit verification code")
                            .font(.caption.weight(.medium))
                            .foregroundColor(.psTextSecondary)

                        // OTP Input Fields
                        HStack(spacing: 8) {
                            ForEach(0..<6, id: \.self) { index in
                                OTPDigitBox(
                                    digit: getDigit(at: index),
                                    isFocused: otpCode.count == index
                                )
                            }
                        }
                        .onTapGesture {
                            focusedField = .otp
                        }

                        // Hidden text field for actual input
                        TextField("", text: $otpCode)
                            .keyboardType(.numberPad)
                            .focused($focusedField, equals: .otp)
                            .opacity(0)
                            .frame(height: 1)
                            .onChange(of: otpCode) { _, newValue in
                                // Limit to 6 digits
                                if newValue.count > 6 {
                                    otpCode = String(newValue.prefix(6))
                                }
                                // Auto-verify when 6 digits entered
                                if newValue.count == 6 {
                                    Task { await authViewModel.verifyOTP(code: newValue) }
                                }
                            }

                        HStack {
                            Spacer()
                            Button("Resend Code") {
                                otpCode = ""
                                Task { await authViewModel.sendOTP(rawPhone: phoneNumber) }
                            }
                            .font(.footnote.weight(.medium))
                            .foregroundColor(.psGreen)
                        }
                        .padding(.top, 4)
                    }
                }

                // Loading indicator during verification
                if authViewModel.isLoading && authViewModel.otpSent {
                    HStack(spacing: 8) {
                        ProgressView()
                        Text("Verifying...")
                            .font(.subheadline)
                            .foregroundColor(.psTextSecondary)
                    }
                }

                // Error Display
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
        .onAppear { focusedField = .phone }
    }

    private func getDigit(at index: Int) -> String {
        if index < otpCode.count {
            let stringIndex = otpCode.index(otpCode.startIndex, offsetBy: index)
            return String(otpCode[stringIndex])
        }
        return ""
    }
}

struct OTPDigitBox: View {
    let digit: String
    let isFocused: Bool

    var body: some View {
        Text(digit.isEmpty ? " " : digit)
            .font(.title2.monospacedDigit().bold())
            .foregroundColor(.psTextPrimary)
            .frame(width: 46, height: 56)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        isFocused ? Color.psGreen : Color(.systemGray4),
                        lineWidth: isFocused ? 2 : 1
                    )
            )
            .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

#Preview {
    NavigationStack {
        PhoneAuthView()
            .environmentObject(AuthViewModel())
    }
}
