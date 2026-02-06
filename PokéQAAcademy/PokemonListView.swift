//
//  PokemonListView.swift
//  PokéQA Academy
//
//  Created by Ricky Memije on 11/7/25.
//

import SwiftUI

struct PokemonListView: View {
    @StateObject private var viewModel = PokemonListViewModel()

    var body: some View {
        ZStack {
            GlassBackground()

            NavigationStack {
                PokemonListContent(viewModel: viewModel)
                    .navigationTitle("Pokédex")
                    .toolbar {
                        PokemonListToolbar(viewModel: viewModel)
                    }
                    .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always))
                    .safeAreaInset(edge: .bottom) {
                        TypeFilterBar(
                            types: viewModel.types,
                            selectedType: viewModel.selectedTypeName,
                            onSelect: { name in
                                Task { await viewModel.selectType(name: name) }
                            },
                            onClear: {
                                Task { await viewModel.clearTypeFilter() }
                            }
                        )
                        .padding(.horizontal)
                        .padding(.bottom, 6)
                    }
            }
        }
        .task {
            await viewModel.load()
        }
    }
}

private struct PokemonListContent: View {
    @ObservedObject var viewModel: PokemonListViewModel

    var body: some View {
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
            } else {
                List(viewModel.filteredItems) { item in
                    NavigationLink {
                        PokemonDetailView(idOrName: item.name)
                    } label: {
                        PokemonRowView(item: item)
                    }
                    .listRowBackground(Color.clear)
                }
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
                .padding(.horizontal, 8)
                .glassCard()
                .padding()
            }
        }
    }
}

private struct PokemonListToolbar: ToolbarContent {
    @ObservedObject var viewModel: PokemonListViewModel

    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Button("Master Dex") {
                    Task { await viewModel.selectMasterDex() }
                }
                Divider()
                ForEach(viewModel.regions, id: \.name) { region in
                    Button(region.name.replacingOccurrences(of: "-", with: " ").capitalized) {
                        Task { await viewModel.selectRegion(name: region.name) }
                    }
                }
            } label: {
                Label(viewModel.selectedPokedexTitle, systemImage: "map")
            }
        }
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                ForEach(viewModel.generations, id: \.name) { generation in
                    Button(viewModel.generationDisplayName(from: generation.name)) {
                        Task { await viewModel.selectGeneration(name: generation.name) }
                    }
                }
            } label: {
                Label(viewModel.selectedGenerationTitle, systemImage: "sparkles")
            }
        }
    }
}

private struct PokemonRowView: View {
    let item: PokemonListItem

    var body: some View {
        HStack {
            Text(String(item.id))
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 32, alignment: .trailing)
            Text(item.displayName)
            Spacer()
            if let spriteURL = item.spriteURL {
                AsyncImage(url: spriteURL) { phase in
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
                .frame(width: 36, height: 36)
                .background(.thinMaterial, in: Circle())
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
            }
        }
        .padding(.vertical, 6)
    }
}

private struct TypeFilterBar: View {
    let types: [NamedAPIResource]
    let selectedType: String?
    let onSelect: (String) -> Void
    let onClear: () -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                Button {
                    onClear()
                } label: {
                    Text("All")
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(selectedType == nil ? Color.white.opacity(0.25) : Color.white.opacity(0.12), in: Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                }

                ForEach(types, id: \.name) { type in
                    Button {
                        onSelect(type.name)
                    } label: {
                        Text(type.name.replacingOccurrences(of: "-", with: " ").capitalized)
                            .font(.subheadline.weight(.semibold))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(selectedType == type.name ? Color.white.opacity(0.25) : Color.white.opacity(0.12), in: Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    }
                }
            }
            .padding(10)
        }
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.18), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.2), radius: 16, x: 0, y: 10)
    }
}

#Preview {
    PokemonListView()
}
