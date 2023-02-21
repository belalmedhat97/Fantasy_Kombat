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

 
class Attack{
    private var normalConstant = 1
    private var missConstant = 0
    private var criticalConstant = 3
    
    private var percentage = ["normal":0.6,"miss":0.2,"critical":0.2]
    
     func returnRandomAttack() -> String {
        // get a random attack type regarding to the weight of propability of it
        var percantageProbilities: [Double] = [0.6,0.2,0.2]
        let sumPercantage = percantageProbilities.reduce(0, +)
        var randomProbailityPercantageRange = Double.random(in: 0.0 ..< sumPercantage)

        var sum = 0.0
        for (attack, weight) in percentage {
            sum += weight
            if randomProbailityPercantageRange < weight {
                return attack
            }
            
        }
        return "normal"
        
    }
    func returnAttackConstant(attack: String) -> Int {
        switch attack {
        case "normal":
            return normalConstant
        case "miss":
            return missConstant
        default :
            return criticalConstant
        }
    }
    func returnPlayerRemainLife(playerLife: Int, Inflicts: Int) -> Int {
        // check if life remain will be less than zero then return zero and life ends for the player
        let remainLife = playerLife - Inflicts
        if  remainLife.signum() == -1 {
            return 0
        }else{
            return remainLife
        }
    }
    func getTotalAttack(playerAttack: Int, attackType: String) -> Int {
        return ( playerAttack * returnAttackConstant(attack: attackType))
    }
    func getInflicts(totalAttack: Int, defence: Int ) -> Int {
       return (totalAttack - defence)
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
    private var playersExchangedAttacks = false
    private let attack:Attack = Attack()
    private var playerToStart = Player1
    private var player1:Player
    private var player2:Player
    init(player1: Player, player2: Player) {
        self.player1 = player1
        self.player2 = player2
        Logger.shared.returnLog(message:"start game \n")
        beginRound()
        playerToStart = attack.getStarterPlayer(player1: player1, player2: player2)
    }
    private func beginRound() {
        playersExchangedAttacks = false
        showRound()
        beginFight(firstPlayer: playerToStart, secondPlayer: playerToStart === self.player1 ? self.player2 : self.player1)
        if checkGameWillEnd() != true {
            beginRound()
        }
    }
    

    
    private func beginFight(firstPlayer: Player,secondPlayer: Player) {
        let attackType = attack.returnRandomAttack()
        if attackType != "normal" {
            Logger.shared.returnLog(message:attackType)
        }
        // inflicts : ( (total = attack * attackTypesConstant) - Defence )
        let totalAttack = attack.getTotalAttack(playerAttack: firstPlayer.attack, attackType: attackType)
        
        var playerInflicts = attack.getInflicts(totalAttack: totalAttack, defence: secondPlayer.defence)
        // lifeLeft : ( life - playerInflicts )
        if checkInflictsWillBeNegaitve(inflicts: playerInflicts) == true {
            playerInflicts = 0
        }
        
        let lifeLeft = attack.returnPlayerRemainLife(playerLife: secondPlayer.life, Inflicts: playerInflicts)
        Logger.shared.returnLog(message: LoggerLabels.getDamage(playerName: firstPlayer.name, playerInflicts: "\(playerInflicts)"))
        Logger.shared.returnLog(message: LoggerLabels.getLeftLife(playerName: secondPlayer.name, lifeLeft: "\(lifeLeft)"))
        checkPlayerWillAttackAgainOrNot(firstPlayer: firstPlayer, secondPlayer: secondPlayer, lifeLeft: lifeLeft)


    }
    private func returnNextPlayerToStart(toStartPlayer: Player, lifeleft: Int) -> Player {
        if toStartPlayer === player1 {
            player1.life = lifeleft
            return player1
        }else{
            player2.life = lifeleft
            return player2

        }
    }
    private func checkPlayerWillAttackAgainOrNot(firstPlayer: Player,secondPlayer: Player, lifeLeft: Int) {
        let nextPlayer = returnNextPlayerToStart(toStartPlayer: secondPlayer, lifeleft: lifeLeft)
        if lifeLeft == 0 {
            Logger.shared.returnLog(message:LoggerLabels.getWinnerPlayer(playerName:firstPlayer.name))
        }else{
            if playersExchangedAttacks != true {
                playersExchangedAttacks = true
                beginFight(firstPlayer: nextPlayer, secondPlayer: firstPlayer)
            }
            
        }
    }
    private func checkInflictsWillBeNegaitve(inflicts: Int) -> Bool {
        // check if damage will negative then return damage to be zero
        if  inflicts.signum() == -1  {
            return true
        }else{
            return false
        }
    }
    private func showRound() {
        roundCounter += 1
        Logger.shared.returnLog(message:"\n")
        Logger.shared.returnLog(message:"round \(roundCounter)")
    }
    
    private func checkGameWillEnd() -> Bool {
        if player1.life == 0 {
            Logger.shared.returnLog(message: "END GAME")
            return true
        }else if player2.life == 0 {
            Logger.shared.returnLog(message: "END GAME")
            return true
        }
        return false
    }

    

    

}

var Player1 = Player(name: "Midoriya", attack: 10, defence: 3, speed: 50, life: 35, luck: 50)
var Player2 = Player(name: "Bakugo", attack: 10, defence: 5, speed: 40, life: 50, luck: 0)
let battle = Battle(player1: Player1, player2: Player2)

