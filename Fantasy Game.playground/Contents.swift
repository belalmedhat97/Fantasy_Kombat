import Foundation

class User{
    var name:String
    var attack:Int
    var defence:Int
    var speed:Int
    var life:Int
    var luck:Int
    init(name:String,attack:Int,defence:Int,speed:Int,life:Int,luck:Int) {
        self.name = name
        self.attack = attack
        self.defence = defence
        self.speed = speed
        self.life = life
        self.luck = luck
    }
}
class Battle{
    var roundCounter:Int = 0
    var usersInBattle:[User] = []
    init(){
        print("start game \n")
    }
    func beginRound(user1:User,user2:User){
        usersInBattle.removeAll()
        roundCounter += 1
        print("\n")
        print("round \(roundCounter)\n")
        let startedUser = getStarterPlayer(user1: user1, user2: user2)
        usersInBattle.append(startedUser)
        beginFight(firstUser: startedUser, SecondUser: startedUser === user1 ? user2 : user1)
        if usersInBattle.count == 2 {
            if usersInBattle[0].life != 0 && usersInBattle[1].life != 0 {
                beginRound(user1: usersInBattle[0], user2: usersInBattle[1])
            }else{
                print("END GAME ============>>> ")
            }
        }else{
            if usersInBattle[0].life != 0 {
                beginRound(user1: usersInBattle[0], user2: usersInBattle[1])
            }else{
                print("END GAME ============>>> ")
            }
        }

        
    }
    func beginFight(firstUser:User,SecondUser:User){
        let attackTypesPercantage:[String:Int] = ["normal":60,"miss":20,"critical":20]
        let attackTypesConstant:[String:Int] = ["normal":1,"miss":0,"critical":3]
        var currentAttackType:String = ""
        currentAttackType = randomWithWeight(distribution: attackTypesPercantage)
        if currentAttackType != "normal" {
            print(currentAttackType)
        }
        // inflicts : ( (total = attack * attackTypesConstant) - Defence )
        let totalAttak = ( firstUser.attack * (attackTypesConstant[currentAttackType] ?? 0) )
        var playerInflicts = ( totalAttak - SecondUser.defence )
        // lifeLeft : ( life - playerInflicts )
        // check if damage will negative then return damage to be zero
        if  playerInflicts.signum() == -1  {
            playerInflicts = 0
        }
        let lifeLeft = checkLifeEnd(userLife: SecondUser.life, Inflicts: playerInflicts)
        print("\(firstUser.name) inflicts \(playerInflicts) of damage")
        print("\(SecondUser.name) has \(lifeLeft) points of life left")
        let userToStartNext = SecondUser
        userToStartNext.life = lifeLeft
        
        if lifeLeft == 0 {
            usersInBattle.append(userToStartNext)
            print("\(firstUser.name) wins !!!")
        }else{
            if usersInBattle.count < 2 {
                usersInBattle.append(userToStartNext)
                beginFight(firstUser: userToStartNext, SecondUser: firstUser)
            }
        }

    }
    func getStarterPlayer(user1:User,user2:User) -> User {
        // speed : check if speed between user 1 and 2 and in case of equal return random user to start
        var startUser = User(name: "", attack: 0, defence: 0, speed: 0, life: 0, luck: 0)
        if user1.speed > user2.speed {
            startUser = user1
        }else if user1.speed > user2.speed{
            startUser = user2
        }else{
            let twoUsers = [user1,user2]
            if let randomUser = twoUsers.randomElement(){
                startUser = randomUser
            }
        }
        return startUser
    }
    
    func checkLifeEnd(userLife:Int,Inflicts:Int) -> Int{
        // check if life remain will be less tahhn zero then return zero and life ends for the player
        let remainLife = userLife - Inflicts
        if  remainLife.signum() == -1 {
            return 0
        }else{
            return remainLife
        }
    }
    
    func randomWithWeight(distribution: [String : Int]) -> String {
        // get a random attack type regarding to the weight of propability of it
        var distributionArray: [String] = []
        distribution.forEach { (key: String, value: Int) in
            let new = Array(repeating: key, count: value)
            distributionArray.append(contentsOf:new)
        }
        let r = Int.random(in: 0..<distributionArray.count)
        return distributionArray[r]
        
    }
}
var Player1 = User(name: "Midoriya", attack: 10, defence: 3, speed: 50, life: 35, luck: 50)
var Player2 = User(name: "Bakugo", attack: 10, defence: 5, speed: 40, life: 50, luck: 0)
let battle = Battle()
battle.beginRound(user1: Player1, user2: Player2)
