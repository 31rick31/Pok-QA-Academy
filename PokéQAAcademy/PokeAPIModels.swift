//
//  PokeAPIModels.swift
//  PokéQA Academy
//
//  Created by Codex on 2/5/26.
//

import Foundation

struct PokemonListResponse: Decodable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [PokemonListItem]
}

struct PokemonListItem: Decodable, Identifiable, Hashable {
    let name: String
    let url: String

    var id: Int {
        // PokeAPI urls end with "/pokemon/{id}/"
        let trimmed = url.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return Int(trimmed.split(separator: "/").last ?? "") ?? 0
    }

    var displayName: String {
        name.capitalized
    }
}

struct NamedAPIResource: Decodable, Hashable {
    let name: String
    let url: String
}

struct RegionListResponse: Decodable {
    let results: [NamedAPIResource]
}

struct RegionDetail: Decodable {
    let name: String
    let pokedexes: [NamedAPIResource]

    var displayName: String {
        name.replacingOccurrences(of: "-", with: " ").capitalized
    }
}

struct PokedexResponse: Decodable {
    let name: String
    let pokemonEntries: [PokedexEntry]

    enum CodingKeys: String, CodingKey {
        case name
        case pokemonEntries = "pokemon_entries"
    }

    var displayName: String {
        name.replacingOccurrences(of: "-", with: " ").capitalized
    }
}

struct PokedexEntry: Decodable, Hashable {
    let entryNumber: Int
    let pokemonSpecies: NamedAPIResource

    enum CodingKeys: String, CodingKey {
        case entryNumber = "entry_number"
        case pokemonSpecies = "pokemon_species"
    }
}

struct PokemonDetail: Decodable {
    let id: Int
    let name: String
    let height: Int
    let weight: Int
    let sprites: PokemonSprites
    let types: [PokemonTypeEntry]
    let stats: [PokemonStatEntry]

    var displayName: String {
        name.capitalized
    }
}

struct PokemonSprites: Decodable {
    let frontDefault: String?

    enum CodingKeys: String, CodingKey {
        case frontDefault = "front_default"
    }
}

struct PokemonTypeEntry: Decodable {
    let slot: Int
    let type: PokemonType
}

struct PokemonType: Decodable {
    let name: String

    var displayName: String {
        name.capitalized
    }
}

struct PokemonStatEntry: Decodable {
    let baseStat: Int
    let stat: PokemonStat

    enum CodingKeys: String, CodingKey {
        case baseStat = "base_stat"
        case stat
    }
}

struct PokemonStat: Decodable {
    let name: String

    var displayName: String {
        name.replacingOccurrences(of: "-", with: " ").capitalized
    }
}
