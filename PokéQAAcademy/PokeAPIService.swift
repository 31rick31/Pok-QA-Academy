//
//  PokeAPIService.swift
//  PokéQA Academy
//
//  Created by Codex on 2/5/26.
//

import Foundation

enum PokeAPIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpStatus(Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL."
        case .invalidResponse:
            return "Invalid response from server."
        case .httpStatus(let code):
            return "Unexpected server status: \(code)."
        }
    }
}

struct PokeAPIService {
    private let session: URLSession
    private let baseURL = "https://pokeapi.co/api/v2"

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchPokemonList(limit: Int = 40, offset: Int = 0) async throws -> [PokemonListItem] {
        let endpoint = "\(baseURL)/pokemon?limit=\(limit)&offset=\(offset)"
        guard let url = URL(string: endpoint) else { throw PokeAPIError.invalidURL }
        let response: PokemonListResponse = try await fetch(url: url)
        return response.results
    }

    func fetchAllPokemon() async throws -> [PokemonListItem] {
        let countEndpoint = "\(baseURL)/pokemon?limit=1&offset=0"
        guard let countURL = URL(string: countEndpoint) else { throw PokeAPIError.invalidURL }
        let countResponse: PokemonListResponse = try await fetch(url: countURL)
        return try await fetchPokemonList(limit: countResponse.count, offset: 0)
    }

    func fetchPokemonDetail(idOrName: String) async throws -> PokemonDetail {
        let endpoint = "\(baseURL)/pokemon/\(idOrName.lowercased())"
        guard let url = URL(string: endpoint) else { throw PokeAPIError.invalidURL }
        return try await fetch(url: url)
    }

    func fetchRegions() async throws -> [NamedAPIResource] {
        let endpoint = "\(baseURL)/region"
        guard let url = URL(string: endpoint) else { throw PokeAPIError.invalidURL }
        let response: RegionListResponse = try await fetch(url: url)
        return response.results
    }

    func fetchRegionDetail(name: String) async throws -> RegionDetail {
        let endpoint = "\(baseURL)/region/\(name.lowercased())"
        guard let url = URL(string: endpoint) else { throw PokeAPIError.invalidURL }
        return try await fetch(url: url)
    }

    func fetchPokedex(name: String) async throws -> PokedexResponse {
        let endpoint = "\(baseURL)/pokedex/\(name.lowercased())"
        guard let url = URL(string: endpoint) else { throw PokeAPIError.invalidURL }
        return try await fetch(url: url)
    }

    private func fetch<T: Decodable>(url: URL) async throws -> T {
        let (data, response) = try await session.data(from: url)
        guard let http = response as? HTTPURLResponse else {
            throw PokeAPIError.invalidResponse
        }
        guard (200...299).contains(http.statusCode) else {
            throw PokeAPIError.httpStatus(http.statusCode)
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
}
