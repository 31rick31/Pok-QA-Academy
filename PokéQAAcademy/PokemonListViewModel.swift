//
//  PokemonListViewModel.swift
//  PokéQA Academy
//
//  Created by Codex on 2/5/26.
//

import Foundation
import Combine

@MainActor
final class PokemonListViewModel: ObservableObject {
    @Published var items: [PokemonListItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText: String = ""
    @Published var regions: [NamedAPIResource] = []
    @Published var selectedRegionName: String? = nil
    @Published var selectedPokedexName: String = "national"

    private let service: PokeAPIService

    init(service: PokeAPIService = PokeAPIService()) {
        self.service = service
    }

    var filteredItems: [PokemonListItem] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return items }
        return items.filter { $0.name.localizedCaseInsensitiveContains(trimmed) }
    }

    var selectedPokedexTitle: String {
        if let regionName = selectedRegionName {
            return regionName.replacingOccurrences(of: "-", with: " ").capitalized
        }
        return "Master Dex"
    }

    func load() async {
        if isLoading { return }
        isLoading = true
        errorMessage = nil
        do {
            async let allPokemon = service.fetchAllPokemon()
            async let regionList = service.fetchRegions()
            items = try await allPokemon
            regions = try await regionList.sorted { $0.name < $1.name }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func selectMasterDex() async {
        selectedRegionName = nil
        selectedPokedexName = "national"
        await loadPokedex(named: "national")
    }

    func selectRegion(name: String) async {
        selectedRegionName = name
        await loadFirstPokedexForRegion(name: name)
    }

    private func loadFirstPokedexForRegion(name: String) async {
        isLoading = true
        errorMessage = nil
        do {
            let region = try await service.fetchRegionDetail(name: name)
            guard let first = region.pokedexes.first else {
                items = []
                isLoading = false
                return
            }
            selectedPokedexName = first.name
            await loadPokedex(named: first.name)
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    private func loadPokedex(named name: String) async {
        isLoading = true
        errorMessage = nil
        do {
            let pokedex = try await service.fetchPokedex(name: name)
            items = pokedex.pokemonEntries.map { entry in
                PokemonListItem(name: entry.pokemonSpecies.name, url: entry.pokemonSpecies.url)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
