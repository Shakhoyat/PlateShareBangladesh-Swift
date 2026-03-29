//
//  LoadingView.swift
//  PlateShareBD
//
//  Created by PlateShare Team.
//

import SwiftUI

struct LoadingView: View {
    var message: String = "Loading..."

    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .tint(.psAccent)
                .scaleEffect(1.5)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(Color.psTextSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.psBgPrimary.ignoresSafeArea())
    }
}

#Preview {
    LoadingView(message: "Verifying...")
}
