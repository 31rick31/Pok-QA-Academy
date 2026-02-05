//
//  PokemonDetailViewModel.swift
//  PokéQA Academy
//
//  Created by Codex on 2/5/26.
//

import Foundation
import Combine

@MainActor
final class PokemonDetailViewModel: ObservableObject {
    @Published var detail: PokemonDetail?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service: PokeAPIService
    private let idOrName: String

    init(idOrName: String, service: PokeAPIService = PokeAPIService()) {
        self.idOrName = idOrName
        self.service = service
    }

    func load() async {
        if isLoading { return }
        isLoading = true
        errorMessage = nil
        do {
            detail = try await service.fetchPokemonDetail(idOrName: idOrName)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
