//
//  GameViewModel.swift
//  Pong
//
//  Created by Lukas Bahrle Santana on 11/12/22.
//

import Foundation
import Combine

protocol GameController {
    func load() async
    
    var playerIsActivePublisher: AnyPublisher<Bool, Never> { get }
    var opponentIsActivePublisher: AnyPublisher<Bool, Never> { get }
    
    var movePlayerPublisher: AnyPublisher<CGFloat, Never> { get }
    var moveOpponentPublisher: AnyPublisher<CGFloat, Never> { get }
    
    func onDrag(dragLocation: CGPoint, screenSize: CGSize)
}

protocol GameInput {
    func load() async
    func ready()
    func play()
    func movePlayer(x: CGFloat)
    func moveOpponent(x: CGFloat)
    func update(timestamp: TimeInterval, screenRatio: CGFloat)
}

protocol GameOutput {
    var statePublisher: AnyPublisher<(state: GameState, score: (player: Int, opponent: Int)), Never>  { get }
}

@MainActor
class GameViewModel: ObservableObject {
    @Published var gameState: GameState = .ready {
        didSet {
            if gameState == .gameOver {
                onGameOver()
            }
            else if gameState == .goal {
                onGoal()
            }
        }
    }
    private(set) var score: (player: Int, opponent: Int) = (0, 0)
    
    private var isGameOver: Bool = false
    
    private var subscriptions = Set<AnyCancellable>()
    
    private let gameInput: GameInput
    private let gameOutput: GameOutput
    private let gameController: GameController
    
    init(gameInput: GameInput, gameOutput: GameOutput, gameController: GameController) {
        self.gameInput = gameInput
        self.gameOutput = gameOutput
        self.gameController = gameController
        
        self.gameController.playerIsActivePublisher.sink { [weak self] value in
            guard let self else { return }
            
        }
        .store(in: &subscriptions)
        
        self.gameController.opponentIsActivePublisher.sink { [weak self] value in
            guard let self else { return }
            
        }
        .store(in: &subscriptions)
        
        self.gameController.movePlayerPublisher.sink { [weak self] value in
            guard let self else { return }
            self.gameInput.movePlayer(x: value)
        }
        .store(in: &subscriptions)
        
        self.gameController.moveOpponentPublisher.sink { [weak self] value in
            guard let self else { return }
            self.gameInput.moveOpponent(x: value)
        }
        .store(in: &subscriptions)
        
        self.gameOutput.statePublisher.sink {  [weak self] (state: GameState, score: (player: Int, opponent: Int)) in
            guard let self else { return }
            self.score = score
            self.gameState = state
        }
        .store(in: &subscriptions)
    }
    
    func load() async {
        await gameInput.load()
    }
    
    func play() {
        logic.play()
    }
    
    func onDrag(dragLocation: CGPoint, screenSize: CGSize) {
        gameController.onDrag(dragLocation: dragLocation, screenSize: screenSize)
    }
    
    func update(timestamp: TimeInterval, screenRatio: CGFloat) {
        gameInput.update(timestamp: timestamp, screenRatio: screenRatio)
    }
    
    private func onGoal() {
        Task {
            try? await Task.sleep(nanoseconds: NSEC_PER_SEC * 2)
            logic.play()
        }
    }
    
    private func onGameOver() {
        Task {
            try? await Task.sleep(nanoseconds: NSEC_PER_SEC * 3)
            logic.ready()
        }
    }
}
