//
//  ErrorBannerView.swift
//  PlateShareBD
//
//  Created by PlateShare Team.
//

import SwiftUI

struct ErrorBannerView: View {
    let message: String
    @Binding var isPresented: Bool

    var body: some View {
        if isPresented {
            HStack(spacing: 10) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.white)
                Text(message)
                    .font(.caption)
                    .foregroundColor(.white)
                    .lineLimit(2)
                Spacer()
                Button {
                    withAnimation { isPresented = false }
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(12)
            .background(Color.psError.opacity(0.9))
            .cornerRadius(10)
            .padding(.horizontal)
            .transition(.move(edge: .top).combined(with: .opacity))
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    withAnimation { isPresented = false }
                }
            }
        }
    }
}

#Preview {
    ErrorBannerView(message: "Something went wrong. Please try again.", isPresented: .constant(true))
}
