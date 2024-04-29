globalvar challenge#variable to keep track of what challenge the player is currently on

#time variables
globalvar timer
globalvar additionalTime
globalvar timeTarget 

globalvar challengePos = [vect(-40.26,8.35,-115.49),vect(-27.35,12.63,-66.51)]#teleport locations

globalvar velocity #value to store the velocity of players
globalvar player #value to store all players


subroutine countdownTimer
subroutine nextChallenge
subroutine kill

#start up rules
rule "timer":      
    #print(player.getPosition()) 
    #print(player.getVelocity().y)  
    #display the timer variable in the top middle of the screen               
    hudHeader(getAllPlayers(), timer, HudPosition.TOP, 0, Color.WHITE, HudReeval.VISIBILITY_SORT_ORDER_AND_STRING, SpecVisibility.ALWAYS)
    timer = 5
                                                
rule "player spawned in":
    @Condition hostPlayer.hasSpawned()     
    player = getAllPlayers()
    wait(1)
    challenge = 1
    setObjectiveDescription(getAllPlayers(), "Challenge {}".format(challenge), HudReeval.VISIBILITY_SORT_ORDER_AND_STRING)

#functions to run during challenges
def countdownTimer():
    @Name "countdown timer"  
    #disable player abilities and other actions
    player.setStatusEffect(null, Status.ROOTED, 9999)  #disables movement  
    player.setAbility1Enabled(false) #disables leftshift ability
    player.setAbility2Enabled(false) #disables E ability
    player.setUltEnabled(false) #disables ult
    player.setPrimaryFireEnabled(false) #disables leftclick
    player.setSecondaryFireEnabled(false) #disables rightclick
    

    timeTarget = timer+additionalTime#store the time additional time starts at 5 and increases the time by 5 after every challenge
    chase(timer, timeTarget, duration=2, ChaseReeval.NONE) #sets the displayed time to 10
    #count down till game start
    smallMessage(getAllPlayers(), 3)#smallMessage just displays a value to all player in this case 3 is displayed
    wait(1)
    smallMessage(getAllPlayers(), 2)
    wait(1)
    smallMessage(getAllPlayers(), 1)
    wait(1)

    stopChasingVariable(timer)   
    chase(timer, 0, rate=1, ChaseReeval.NONE) #start decreases the value of timer till 0
    smallMessage(getAllPlayers(), "Go!")
    player.clearStatusEffect(Status.ROOTED)#stops rooting the player allows them to start moving

def nextChallenge():
    @Name "challenge finished"
    destroyAllEffects()    
    stopChasingVariable(timer)    
    challenge++


def kill(): #this function heavely needs wait after everything becasue its in a while loop
    @Name "kill"    
    wait(0.5)            
    velocity = player.getVelocity().y #this is the velocity of the player in the y direction (can change this to use a formula instead)          
    if velocity <= -10: #when the player is falling there y velocity is going to be negative when there jumping its going to be positive when on the ground 0          
        wait(0.5)
        kill(player,null) #function to kill the player        
        wait(2)
        player.respawn()#function to respawn the player fast        
        player.teleport(challengePos[challenge-1])#the player respawns in the spawn zone so we will need to teleport the player to the challenge position
        return
    

#challenge rules
rule "challenge 1":
    @Condition challenge == 1       
    player.teleport(challengePos[0])#teleport players to the vector position of the first challenge
    player.setFacing(vect(1, 0, 0), Relativity.TO_WORLD) #sets the player to face a specific direction
    bigMessage(player, "Get to the vortex!")#show a message to the player (player in this case is all players)
    additionalTime = 5 #set the additional time to 5 for when the challenge is completed
    player.startForcingHero(Hero.LUCIO)#force the player to be a specific charactter (this case lucio)
    createEffect(getAllPlayers(), Effect.BAD_AURA, Color.GREEN, challengePos[1], 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS) #create a effect at the challenge vector position
    countdownTimer() #start the countdown 
    #let the player use abilities
    player.setAbility1Enabled(true) 
    player.setAbility2Enabled(true)
    while challenge == 1: #while loop to check if the player has a velocity that would kill them       
        kill()

rule "challenge 2":
    @Condition challenge == 2    
    player.teleport(challengePos[1])
    player.setFacing(vect(1, 0, 0), Relativity.TO_WORLD)
    bigMessage(player, "Get to the vortex!")
    additionalTime = 5
    player.startForcingHero(Hero.LUCIO)
    createEffect(getAllPlayers(), Effect.BAD_AURA, Color.GREEN, challengePos[0], 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    countdownTimer()
    player.setAbility1Enabled(true)
    player.setAbility2Enabled(true)
    while challenge == 2:
        kill()  
      
#challenge completed rules
#right now it just switches between the 2 different challenges
rule "challenge 2 finished":
    @Condition challenge == 2 and distance(player.getPosition(), challengePos[0]) < 2       
    challenge = 0
    nextChallenge()

rule "challenge 1 finished":
    @Condition challenge == 1 and distance(player.getPosition(), challengePos[1]) < 2         
    nextChallenge()


#challenge failed rules 
#later on these rules will be implemented
rule "challenge 1 failed":
    @Disabled
        
    
rule "challenge 2 failed":
    @Disabled
    
    
        
    
