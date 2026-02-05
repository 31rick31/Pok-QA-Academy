//
//  ContentView.swift
//  PokéQA Academy
//
//  Created by Ricky Memije on 11/7/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = PokemonListViewModel()

    var body: some View {
        ZStack {
            GlassBackground()

            NavigationStack {
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
                                HStack {
                                    Text(String(item.id))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .frame(width: 32, alignment: .trailing)
                                    Text(item.displayName)
                                }
                                .padding(.vertical, 6)
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
                .navigationTitle("Pokédex")
                .toolbar {
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
                }
                .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always))
            }
        }
        .task {
            await viewModel.load()
        }
    }
}

#Preview {
    ContentView()
}
