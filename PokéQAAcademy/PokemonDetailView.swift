//
//  PokemonDetailView.swift
//  PokéQA Academy
//
//  Created by Codex on 2/5/26.
//

import SwiftUI

struct PokemonDetailView: View {
    @StateObject private var viewModel: PokemonDetailViewModel

    init(idOrName: String) {
        _viewModel = StateObject(wrappedValue: PokemonDetailViewModel(idOrName: idOrName))
    }

    var body: some View {
        ZStack {
            GlassBackground()

            Group {
                if viewModel.isLoading {
                    ProgressView("Loading Pokémon...")
                        .padding(20)
                        .glassCard()
                } else if let errorMessage = viewModel.errorMessage {
                    ContentUnavailableView {
                        Label("Network Error", systemImage: "wifi.exclamationmark")
                    } description: {
                        Text(errorMessage)
                    }
                    .padding(20)
                    .glassCard()
                } else if let detail = viewModel.detail {
                    ScrollView {
                        VStack(spacing: 20) {
                            if let spriteURL = detail.sprites.frontDefault,
                               let url = URL(string: spriteURL) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFit()
                                    case .failure:
                                        Image(systemName: "photo")
                                            .imageScale(.large)
                                            .foregroundStyle(.secondary)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                                .frame(width: 180, height: 180)
                                .padding(14)
                                .background(.thinMaterial, in: Circle())
                                .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
                            }

                            VStack(spacing: 8) {
                                Text(detail.displayName)
                                    .font(.largeTitle.bold())
                                Text("#\(detail.id)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            HStack(spacing: 12) {
                                InfoPill(title: "Height", value: "\(detail.height)")
                                InfoPill(title: "Weight", value: "\(detail.weight)")
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Types")
                                    .font(.headline)
                                HStack {
                                    ForEach(detail.types, id: \.slot) { entry in
                                        Text(entry.type.displayName)
                                            .font(.subheadline.weight(.semibold))
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(.thinMaterial, in: Capsule())
                                            .overlay(
                                                Capsule()
                                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                            )
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Base Stats")
                                    .font(.headline)
                                ForEach(detail.stats, id: \.stat.name) { entry in
                                    HStack {
                                        Text(entry.stat.displayName)
                                        Spacer()
                                        Text("\(entry.baseStat)")
                                            .font(.subheadline.monospacedDigit())
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding()
                        .glassCard()
                        .padding()
                    }
                } else {
                    ContentUnavailableView("No Data", systemImage: "questionmark")
                        .padding(20)
                        .glassCard()
                }
            }
        }
        .navigationTitle("Pokémon")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.load()
        }
    }
}

private struct InfoPill: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline.monospacedDigit())
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    NavigationStack {
        PokemonDetailView(idOrName: "1")
    }
}
