//
//  PokemonDetailViewModel.swift
//  PokéQA Academy
//
//  Created by Ricky Memije on 2/5/26.
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

    init(idOrName: String, service: PokeAPIService? = nil) {
        self.idOrName = idOrName
        if let service {
            self.service = service
        } else {
            self.service = PokeAPIService(session: .shared)
        }
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
