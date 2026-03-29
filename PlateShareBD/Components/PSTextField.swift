//
//  PSTextField.swift
//  PlateShareBD
//
//  Created by PlateShare Team.
//

import SwiftUI

struct PSTextField: View {
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var icon: String? = nil
    var isSecure: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(.psTextSecondary)
                    .frame(width: 20)
            }

            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
            }
        }
        .padding(14)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }
}

#Preview {
    VStack(spacing: 16) {
        PSTextField(placeholder: "Enter your name", text: .constant(""), icon: "person.fill")
        PSTextField(placeholder: "Phone number", text: .constant(""), keyboardType: .phonePad, icon: "phone.fill")
    }
    .padding()
}
