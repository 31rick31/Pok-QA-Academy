//
//  PokemonListViewModel.swift
//  PokéQA Academy
//
//  Created by Ricky Memije on 2/5/26.
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
    @Published var types: [NamedAPIResource] = []
    @Published var selectedTypeName: String? = nil
    @Published var generations: [NamedAPIResource] = []
    @Published var selectedGenerationName: String? = nil

    private let service: PokeAPIService

    init(service: PokeAPIService? = nil) {
        if let service {
            self.service = service
        } else {
            self.service = PokeAPIService(session: .shared)
        }
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

    var selectedGenerationTitle: String {
        if let generationName = selectedGenerationName {
            return generationDisplayName(from: generationName)
        }
        return "Generation"
    }

    func generationDisplayName(from apiName: String) -> String {
        if let numeral = apiName.split(separator: "-").last,
           let number = romanNumeralToInt(String(numeral)) {
            return "Gen \(number)"
        }
        return apiName.replacingOccurrences(of: "-", with: " ").capitalized
    }

    func load() async {
        if isLoading { return }
        isLoading = true
        errorMessage = nil
        do {
            async let allPokemon = service.fetchAllPokemon()
            async let regionList = service.fetchRegions()
            async let typeList = service.fetchTypes()
            async let generationList = service.fetchGenerations()
            items = try await allPokemon
            regions = try await regionList.sorted { $0.name < $1.name }
            types = try await typeList
                .filter { $0.name != "unknown" && $0.name != "shadow" }
                .sorted { $0.name < $1.name }
            generations = try await generationList.sorted { $0.name < $1.name }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func selectMasterDex() async {
        selectedRegionName = nil
        selectedPokedexName = "national"
        selectedTypeName = nil
        selectedGenerationName = nil
        await loadAllPokemon()
    }

    func selectRegion(name: String) async {
        selectedRegionName = name
        selectedTypeName = nil
        selectedGenerationName = nil
        await loadFirstPokedexForRegion(name: name)
    }

    func selectType(name: String) async {
        selectedTypeName = name
        selectedGenerationName = nil
        await loadType(name: name)
    }

    func clearTypeFilter() async {
        selectedTypeName = nil
        if let _ = selectedRegionName {
            await loadPokedex(named: selectedPokedexName)
        } else {
            await loadAllPokemon()
        }
    }

    func selectGeneration(name: String) async {
        selectedGenerationName = name
        selectedRegionName = nil
        selectedTypeName = nil
        await loadGeneration(name: name)
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

    private func loadAllPokemon() async {
        isLoading = true
        errorMessage = nil
        do {
            items = try await service.fetchAllPokemon()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private func loadType(name: String) async {
        isLoading = true
        errorMessage = nil
        do {
            let detail = try await service.fetchTypeDetail(name: name)
            items = detail.pokemon.map { entry in
                PokemonListItem(name: entry.pokemon.name, url: entry.pokemon.url)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private func loadGeneration(name: String) async {
        isLoading = true
        errorMessage = nil
        do {
            let detail = try await service.fetchGenerationDetail(name: name)
            items = detail.pokemonSpecies.map { species in
                PokemonListItem(name: species.name, url: species.url)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private func romanNumeralToInt(_ value: String) -> Int? {
        let mapping: [Character: Int] = [
            "I": 1, "V": 5, "X": 10, "L": 50, "C": 100, "D": 500, "M": 1000
        ]
        let chars = Array(value.uppercased())
        guard !chars.isEmpty else { return nil }
        var total = 0
        var previous = 0
        for ch in chars.reversed() {
            guard let current = mapping[ch] else { return nil }
            if current < previous {
                total -= current
            } else {
                total += current
                previous = current
            }
        }
        return total
    }
}
