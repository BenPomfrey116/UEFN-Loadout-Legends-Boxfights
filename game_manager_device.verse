
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Random }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/UI }

GameInfo := class():
    var map_id : int = -1
    var map_name : string = ""
    var map_description : string = ""

    var current_boss : ?agent = false

    SetMap(map_number:int,the_map_name:string,the_map_description:string):void=
        set map_id = map_number
        set map_name = the_map_name
        set map_description = the_map_description

    SetCurrentBoss(Agent:agent):void=
        set current_boss = option{Agent}
    GetCurrentBoss():?agent=
        return current_boss
    

game_manager_device := class(creative_device):

    #Game management
    game_info : GameInfo = GameInfo{}

    #Pregame
    @editable GAMESTART : trigger_device = trigger_device{}
    @editable GAMESTART_10s : trigger_device = trigger_device{}
    @editable PregameTimer : timer_device = timer_device{}
    @editable ElimAllPickup : health_powerup_device = health_powerup_device{}

    #Main game
    @editable MainDelayTrigger : trigger_device = trigger_device{}
    @editable MainTimer : timer_device = timer_device{}
    @editable ElimManager : elimination_manager_device = elimination_manager_device{}
    @editable PlayerCounter : player_counter_device = player_counter_device{}
    @editable CheckAliveTrigger : trigger_device = trigger_device{}
    @editable EndGameTrigger : trigger_device = trigger_device{}

    #Maps
    @editable storm_beacons : []basic_storm_controller_device = array{}
    @editable map_triggers : []trigger_device = array{}
    @editable m_trigger0 : trigger_device = trigger_device{}
    @editable m_trigger1 : trigger_device = trigger_device{}
    @editable m_trigger2 : trigger_device = trigger_device{}
    @editable m_trigger3 : trigger_device = trigger_device{}
    @editable m_trigger4 : trigger_device = trigger_device{}
    @editable m_trigger5 : trigger_device = trigger_device{}
    var map_list : [int][]string = map{
        0=>array{"Classic",    "Simple 7x7 arena"},
        1=>array{"Cramped",    "Tiny 6x4 box"},
        2=>array{"High Ground","Varied height"},
        3=>array{"Pillars",    "Don't fall off!"},
        4=>array{"Divided",    "Win to advance!"},
        5=>array{"The Agency", "Eliminate Midas!"}
        # 6=>array{"Boxception","Boxes galore!"},
        # 7=>array{"King of the hill","Race to the top!"}
    }
    var counter_locations : [int]transform = map{
        #Classic (X=2560.000000,Y=10240.000000,Z=192.000000)
        0 => transform{Translation := vector3{X := 2560.0,Y := -10240.0,Z := 192.0}}
        #Cramped (X=10240.000000,Y=10752.000000,Z=576.000000)
        1 => transform{Translation := vector3{X := 10240.0,Y := -10752.0,Z := 576.0}}
        #Height (X=19712.000000,Y=8448.000000,Z=192.000000)
        2 => transform{Translation := vector3{X := 19712.0,Y := -8448.0,Z := 192.0}}
        #Pillars (X=32256.000000,Y=10752.000003,Z=-384.000000)
        3 => transform{Translation := vector3{X := 32256.0,Y := -10752.0,Z := -384.0}}
        #Divided (X=-7168.000000,Y=8704.000000,Z=128.000000)
        4 => transform{Translation := vector3{X := -7168.0,Y := -8704.0,Z := 128.0}}
        #Boss (X=10240.000000,Y=3584.000000,Z=128.000000)
        5 => transform{Translation := vector3{X := 10240.0,Y := -3584.0,Z := 128.0}}
    }
    #Split
    @editable split_counters : []player_counter_device = array{}
    @editable split_triggers : []trigger_device = array{}
    #Boss
    @editable ElimManagerBoss : elimination_manager_device = elimination_manager_device{}
    @editable ItemRemoverItems : item_remover_device = item_remover_device{}
    @editable BossGranter : item_granter_device = item_granter_device{}
    @editable BossHud : hud_message_device = hud_message_device{}

    OnBegin<override>()<suspends>:void=

        m_trigger0.TriggeredEvent.Subscribe(PickClassic)
        m_trigger1.TriggeredEvent.Subscribe(PickCramped)
        m_trigger2.TriggeredEvent.Subscribe(PickHighGround)
        m_trigger3.TriggeredEvent.Subscribe(PickPillars)
        m_trigger4.TriggeredEvent.Subscribe(PickDivided)
        m_trigger5.TriggeredEvent.Subscribe(PickAgency)

        PregameTimer.SuccessEvent.Subscribe(EndPregame)
        
        

    # GameStart10s(MaybeAgent:?agent):void=
    #     PickMap(0)

    PickClassic(MaybeAgent:?agent):void=
        PickMap(0)
        Print("picked 0")
    PickCramped(MaybeAgent:?agent):void=
        PickMap(1)
        Print("picked 1")
    PickHighGround(MaybeAgent:?agent):void=
        PickMap(2)
        Print("picked 2")
    PickPillars(MaybeAgent:?agent):void=
        PickMap(3)
        Print("picked 3")
    PickDivided(MaybeAgent:?agent):void=
        PickMap(4)
        Print("picked 4")
    PickAgency(MaybeAgent:?agent):void=
        PickMap(5)
        Print("picked 5")

    PickMap(map_number:int):void=
        Print("PICKING MAP: {map_number}")
        #Store Map info
        if(PlayerCounter.TeleportTo[counter_locations[map_number]]):
        if:
            map_details := map_list[map_number],
            map_name := map_details[0],
            map_description := map_details[1]
        then:
            game_info.SetMap(map_number,map_name,map_description)
            #if(map_image := map_images[map_number]):
                # for(Player->player_info : player_list):
                #     player_info.SetLoadscreen(map_image,StringToMessage("{map_name}"),StringToMessage("{map_description}"))
        #Initialise Map
        if(init_map := map_triggers[map_number]):
            init_map.Trigger()

    EndPregame(MaybeAgent:?agent):void=
        # for(Player->player_info : player_list):
        #     if(PlayerUI := GetPlayerUI[Player]):
        #         player_info.AddLoadscreen(PlayerUI)
        if(game_info.map_id = 4):
            for(split_counter : split_counters):
                split_counter.Enable()
        MainDelayTrigger.Trigger()
        #Kill Players
        spawn{ElimAllPlayers()}
        #Events
        MainDelayTrigger.TriggeredEvent.Subscribe(StartMainGame)
        MainTimer.SuccessEvent.Subscribe(StartBattle)


    ElimAllPlayers()<suspends>:void=
        Sleep(1.0)
        ElimAllPickup.Pickup()

    StartMainGame(MaybeAgent:?agent):void=
        # for(Player->player_info : player_list):
        #     if(PlayerUI := GetPlayerUI[Player]):
        #         player_info.RemoveLoadscreen(PlayerUI)
        MainTimer.Start()
        PlayerCounter.Enable()
        Players : []player = GetPlayspace().GetPlayers()
        for(Player : Players):
            spawn{ShowMapInfo(Player)}


    ShowMapInfo(Player:player)<suspends>:void=
        Sleep(5.0)
        if(PlayerUI := GetPlayerUI[Player]):
            newMapInfoWidget : uis.map_info  = uis.map_info{
                name := StringToMessage("{game_info.map_name}")
                desc := StringToMessage("{game_info.map_description}")
            }
            PlayerUI.AddWidget(newMapInfoWidget)
            set newMapInfoWidget.show_anim = 1
            Sleep(5.0)
            PlayerUI.RemoveWidget(newMapInfoWidget)

    StartBattle(MaybeAgent:?agent):void=
            if(storm_beacon := storm_beacons[game_info.map_id]):
                storm_beacon.GenerateStorm()
            if(game_info.map_id = 4):
                for(split_trigger : split_triggers):
                    split_trigger.Enable()
                spawn{CheckSplitCounters()}
            else if(game_info.map_id = 5):
                ElimManager.EliminatedEvent.Subscribe(AgentEliminated)
                ElimManagerBoss.ItemPickedUpEvent.Subscribe(SetBoss)
            # if(map_id = 9):
            #     spawn{SubwayTrain1()}
            #     spawn{SubwayTrain2()}
            EndGameTrigger.Enable()
            spawn{CheckAlivePlayers()}

    CheckAlivePlayers()<suspends>:void=
        Sleep(0.5)
        PlayerCounter.CompareToTarget()

    AgentElimination(MaybeAgent:?agent):void=
        if(Agent := agent[MaybeAgent?]):
            #do stuff
    AgentEliminated(Agent:agent):void=
        if(game_info.map_id = 5):
            #check if they're the boss
            maybe_current_boss := game_info.GetCurrentBoss()
            if:
                current_boss := maybe_current_boss?
                Agent = current_boss

    CheckSplitCounters()<suspends>:void=
        Sleep(0.5)
        for(split_counter : split_counters):
            split_counter.CompareToTarget()

    SetBoss(Agent:agent):void=
        ItemRemoverItems.Remove(Agent)
        if:
            fort_char := Agent.GetFortCharacter[]
        then:
            fort_char.SetMaxHealth(200.0)
            fort_char.SetHealth(200.0)
            fort_char.SetMaxShield(200.0)
            fort_char.SetShield(200.0)
        BossGranter.GrantItem(Agent)
        game_info.SetCurrentBoss(Agent)
        BossHud.Show()
    