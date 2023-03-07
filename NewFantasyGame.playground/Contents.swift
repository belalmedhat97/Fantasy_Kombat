import Foundation

class Logger{
    static let shared:Logger = Logger()
    private init(){}
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
    
    static func getDamage(playerName: String, playerInflicts:String) -> String {
        return ("\(playerName) inflicts \(playerInflicts) of damage")
    }
    
    static func getLeftLife(playerName: String, lifeLeft: String) -> String {
        return ("\(playerName) has \(lifeLeft) points of life left")
    }
    
    static func getWinnerPlayer(playerName: String) -> String {
        return"\(playerName) wins !!!"
    }
}

class Player{
    var name:String
    var attack:Int
    var defence:Int
    var speed:Int
    var life:Int
    var luck:Int
    init(name: String, attack: Int, defence: Int, speed: Int, life: Int, luck: Int) {
        self.name = name
        self.attack = attack
        self.defence = defence
        self.speed = speed
        self.life = life
        self.luck = luck
    }

}

protocol AttackType {
    var damageMultiplier: Int { get }
    static var chances: Int { get }
    var label: String { get }
}

class Normal: AttackType {
    let damageMultiplier = 1
    static let chances = 60
    var label = "normal"
}

class Miss: AttackType {
    let damageMultiplier = 0
    static let chances = 20
    let label = "miss"

}

class Critical: AttackType {
    let damageMultiplier = 3
    static let chances = 20
    let label = "critical"

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
            return Miss()
        case missLimit..<normalLimit:
            return Normal()
        case normalLimit...criticalLimit:
            return Critical()
        default:
            return Normal()
        }
    }
    }


class Attack{

    func calculatePlayerRemainLife(playerLife: Int, Inflicts: Int) -> Int {
        // check if life remain will be less than zero then return zero and life ends for the player
        let remainLife = playerLife - Inflicts
        
        if  remainLife.signum() == -1 {
            return 0
        } else {
            return remainLife
        }
    }
    
    func calculateTotalAttack(playerAttack: Int, damage: Int) -> Int {
        return playerAttack * damage
    }
    
    func calculateInflicts(totalAttack: Int, defence: Int ) -> Int {
        var inflicts = (totalAttack - defence)
        if  inflicts.signum() == -1  {
            inflicts = 0
        }
       return inflicts
    }

    func getStarterPlayer(player1:Player, player2:Player) -> Player {
        // speed : check if speed between player 1 and 2 and in case of equal return random player to start
        var startPlayer = player1
        if player1.speed > player2.speed {
            startPlayer = player1
        }else if player1.speed > player2.speed{
            startPlayer = player2
        }else{
            let twoPlayers = [player1,player2]
            if let randomPlayer = twoPlayers.randomElement(){
                startPlayer = randomPlayer
            }
        }
        return startPlayer
    }
}


class Battle{
    private var roundCounter:Int = 0
    private let attack:Attack = Attack()
    private var player1: Player
    private var player2: Player
    init(player1: Player, player2: Player) {
        self.player1 = player1
        self.player2 = player2
        Logger.shared.returnLog(message:"start game \n")
        beginRound()
    }
    private func beginRound() {
        let playerToStart = attack.getStarterPlayer(player1: player1, player2: player2)
        showRound()
        beginFight(firstPlayer: playerToStart, secondPlayer: playerToStart === self.player1 ? self.player2 : self.player1)
        if checkGameWillEnd() != true {
            beginRound()
        }
    }
    
    private func showRound() {
        roundCounter += 1
        Logger.shared.returnLog(message:"\n")
        Logger.shared.returnLog(message:"round \(roundCounter)")
    }

    private func beginFight(firstPlayer: Player, secondPlayer: Player) {
        let attackType = AttackTypeFactory().create(luckBonus: firstPlayer.luck)
        showAttackType(type: attackType)
        
        let totalAttack = attack.calculateTotalAttack(playerAttack: firstPlayer.attack, damage: attackType.damageMultiplier)
        
        var playerInflicts = attack.calculateInflicts(totalAttack: totalAttack, defence: secondPlayer.defence)

        let lifeLeft = attack.calculatePlayerRemainLife(playerLife: secondPlayer.life, Inflicts: playerInflicts)
        Logger.shared.returnLog(message: LoggerLabels.getDamage(playerName: firstPlayer.name, playerInflicts: "\(playerInflicts)"))
        Logger.shared.returnLog(message: LoggerLabels.getLeftLife(playerName: secondPlayer.name, lifeLeft: "\(lifeLeft)"))
        
        checkPlayerWillAttackAgainOrNot(firstPlayer: firstPlayer, secondPlayer: secondPlayer, lifeLeft: lifeLeft)

    }

    private func showAttackType(type:AttackType) {
        if type.label != "normal" {
            Logger.shared.returnLog(message:type.label)
        }
    }
    
    private func checkPlayerWillAttackAgainOrNot(firstPlayer: Player,secondPlayer: Player, lifeLeft: Int) {
        let nextPlayer = returnNextPlayerToStart(toStartPlayer: secondPlayer, lifeleft: lifeLeft)
        if lifeLeft == 0 {
            Logger.shared.returnLog(message:LoggerLabels.getWinnerPlayer(playerName:firstPlayer.name))
        } else {
            if attack.getStarterPlayer(player1: player1, player2: player2) === firstPlayer {
                beginFight(firstPlayer: nextPlayer, secondPlayer: firstPlayer)
            }
            
        }
    }
    
    private func returnNextPlayerToStart(toStartPlayer: Player, lifeleft: Int) -> Player {
        if toStartPlayer === player1 {
            player1.life = lifeleft
            return player1
        } else {
            player2.life = lifeleft
            return player2

        }
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

