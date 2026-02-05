//
//  GlassStyle.swift
//  PokéQA Academy
//
//  Created by Codex on 2/5/26.
//

import SwiftUI

struct GlassBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.15, green: 0.18, blue: 0.35),
                    Color(red: 0.08, green: 0.10, blue: 0.20),
                    Color(red: 0.10, green: 0.14, blue: 0.28)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color.white.opacity(0.18))
                .frame(width: 280, height: 280)
                .blur(radius: 20)
                .offset(x: -140, y: -220)

            Circle()
                .fill(Color.white.opacity(0.10))
                .frame(width: 220, height: 220)
                .blur(radius: 24)
                .offset(x: 160, y: -140)

            RoundedRectangle(cornerRadius: 60, style: .continuous)
                .fill(Color.white.opacity(0.06))
                .frame(width: 420, height: 420)
                .blur(radius: 30)
                .offset(x: 120, y: 260)
        }
    }
}

struct GlassCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 12)
    }
}

extension View {
    func glassCard() -> some View {
        modifier(GlassCardStyle())
    }
}

#Preview {
    ZStack {
        GlassBackground()
        Text("Glass")
            .padding(24)
            .glassCard()
    }
}
