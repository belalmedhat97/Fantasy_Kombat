import Foundation

class Logger {
    static let shared: Logger = Logger()
    private init() {}
    func returnLog(message: String) {
        print(message)
    }
}

enum LoggerLabels {
    static let endgame = "endgame"
    static let startGame = "start game \n"
    static func getRoundCounter(number: String) -> String {
        return "round \(number) \n"
    }

    static func getDamage(playerName: String, playerInflicts: String) -> String {
        return ("\(playerName) inflicts \(playerInflicts) of damage")
    }

    static func getLeftLife(playerName: String, lifeLeft: String) -> String {
        return ("\(playerName) has \(lifeLeft) points of life left")
    }

    static func getWinnerPlayer(playerName: String) -> String {
        return"\(playerName) wins !!!"
    }
}

class Player {
    let name: String
    let attack: Int
    let defence: Int
    let speed: Int
    var life: Int
    let luck: Int

    init(name: String, attack: Int, defence: Int, speed: Int, life: Int, luck: Int) {
        self.name = name
        self.attack = attack
        self.defence = defence
        self.speed = speed
        self.life = life
        self.luck = luck
    }

    func reduceLife(by points: Int) {
        let remainLife = life - points
        if  remainLife.signum() == -1 {
            life = 0
        } else {
            life = remainLife
        }
    }
}

protocol AttackType {
    var damageMultiplier: Int { get }
    static var chances: Int { get }
    static var label: String { get }
}

class Normal: AttackType {
    let damageMultiplier = 1
    static let chances = 60
    static var label = "normal"
}

class Miss: AttackType {
    let damageMultiplier = 0
    static let chances = 20
    static let label = "miss"

}

class Critical: AttackType {
    let damageMultiplier = 3
    static let chances = 20
    static let label = "critical"

}

class AttackTypeFactory {
    func create(luckBonus: Int) -> AttackType {
        let start = 0
        let missLimit = start + Miss.chances
        let normalLimit = missLimit + Normal.chances
        let criticalLimit = normalLimit + Critical.chances + luckBonus
        let random = Int.random(in: start...criticalLimit)

        switch random {
        case start..<missLimit:
            Logger.shared.returnLog(message: Miss.label)
            return Miss()
        case missLimit..<normalLimit:
            return Normal()
        case normalLimit...criticalLimit:
            Logger.shared.returnLog(message: Critical.label)
            return Critical()
        default:
            return Normal()
        }
    }
}

class AttackManager {
    func calculateTotalAttack(playerAttack: Int, damage: Int) -> Int {
        return playerAttack * damage
    }

    func calculateInflicts(totalAttack: Int, defence: Int ) -> Int {
        var inflicts = (totalAttack - defence)
        if  inflicts.signum() == -1 {
            inflicts = 0
        }
       return inflicts
    }

}

class RoundManager {
    private var roundCounter: Int = 0

    func showRound() {
        roundCounter += 1
        Logger.shared.returnLog(message: "\n")
        Logger.shared.returnLog(message: "round \(roundCounter)")
    }

    func playerWillStartRound(player1: Player, player2: Player) -> Player {
        var startPlayer = player1
        if player1.speed > player2.speed {
            startPlayer = player1
        } else if player1.speed > player2.speed {
            startPlayer = player2
        } else {
            let twoPlayers = [player1, player2]
            if let randomPlayer = twoPlayers.randomElement() {
                startPlayer = randomPlayer
            }
        }
        return startPlayer
    }

    func getNextPlayer(player1: Player, player2: Player, toStartPlayer: Player, lifeleft: Int) -> Player {
        if toStartPlayer === player1 {
            return setlifeLeftForPlayer(player: player1, lifeLeft: lifeleft)
        } else {
            return setlifeLeftForPlayer(player: player2, lifeLeft: lifeleft)
        }
    }

    func playersWillExchangeAttack(fplayerInRound: Player, BattlePlayers: (player1: Player, player2: Player), nextPlayer: Player, lifeleft: Int) -> Player? {
        if lifeleft == 0 {
            Logger.shared.returnLog(message: LoggerLabels.getWinnerPlayer(playerName: fplayerInRound.name))
        } else {
            if playerWillStartRound(player1: BattlePlayers.player1, player2: BattlePlayers.player2) === fplayerInRound {
                return nextPlayer
            }
        }
        return nil
    }

    private func setlifeLeftForPlayer(player: Player, lifeLeft: Int) -> Player {
        player.life = lifeLeft
        return player
    }
}

class Battle {
    private let attack: AttackManager = AttackManager()
    private let round: RoundManager = RoundManager()
    private var player1: Player
    private var player2: Player
    init(player1: Player, player2: Player) {
        self.player1 = player1
        self.player2 = player2
        Logger.shared.returnLog(message: "start game \n")
        beginRound()
    }

     private func beginRound() {
        let playerToStart = round.playerWillStartRound(player1: player1, player2: player2)
        round.showRound()
        beginFight(firstPlayer: playerToStart, secondPlayer: playerToStart === self.player1 ? self.player2 : self.player1)
        if checkGameWillEnd() != true {
            beginRound()
        }
    }

    private func beginFight(firstPlayer: Player, secondPlayer: Player) {
        let attackType = AttackTypeFactory().create(luckBonus: firstPlayer.luck)
        let totalAttack = attack.calculateTotalAttack(playerAttack: firstPlayer.attack, damage: attackType.damageMultiplier)
        let damageToInflicts = attack.calculateInflicts(totalAttack: totalAttack, defence: secondPlayer.defence)
        Logger.shared.returnLog(message: LoggerLabels.getDamage(playerName: firstPlayer.name, playerInflicts: "\(damageToInflicts)"))
        secondPlayer.reduceLife(by: damageToInflicts)
        Logger.shared.returnLog(message: LoggerLabels.getLeftLife(playerName: secondPlayer.name, lifeLeft: "\(secondPlayer.life)"))
        let nextPlayer = round.getNextPlayer(player1: player1, player2: player2, toStartPlayer: secondPlayer, lifeleft: secondPlayer.life)
        if let starterPlayer = round.playersWillExchangeAttack(fplayerInRound: firstPlayer, BattlePlayers: getPlayersInBattle(), nextPlayer: nextPlayer, lifeleft: secondPlayer.life) {
            beginFight(firstPlayer: starterPlayer, secondPlayer: firstPlayer)
        }
    }

    private func getPlayersInBattle() -> (player1: Player, player2: Player) {
        return (player1, player2)
    }

    private func checkGameWillEnd() -> Bool {
        if player1.life == 0 {
            Logger.shared.returnLog(message: "END GAME")
            return true
        } else if player2.life == 0 {
            Logger.shared.returnLog(message: "END GAME")
            return true
        }
        return false
    }
}

var Player1 = Player(name: "Midoriya", attack: 10, defence: 3, speed: 50, life: 35, luck: 0)
var Player2 = Player(name: "Bakugo", attack: 10, defence: 5, speed: 40, life: 50, luck: 0)
let battle = Battle(player1: Player1, player2: Player2)
