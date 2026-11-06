
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Verse }
using { /Verse.org/Assets }
using { /Verse.org/Random }

PlayerDetails := class():
    
    Player : player

    max_level : int = 20
    max_xp : int = 5000
    level_widget : uis.level_widget = uis.level_widget{}
    var level : int
    var current_xp : int
    
    var current_widget : ?widget = false

    var preset_index : ?int

    #Item indexes
    var rweapon_index : int
    var cweapon_index : int
    var healing_index : int
    var utility_index : int 
    var rampage_index : int
    #Perk indexes
    var perk1_index : ?int
    var perk2_index : ?int
    current_perk_widget : uis.perk_info = uis.perk_info{}

    #Rampage
    var current_elims : int = 0
    rampage_info_widget : uis.rampage_info = uis.rampage_info{}

    #Mastery
    var current_vfx : ?int = false
    var rweapon_progress : [int]int = map{}
    var cweapon_progress : [int]int = map{}
    var mastery_widget : uis.mastery_widget = uis.mastery_widget{}

    ShowLevelWidget(show:logic):void=
        UpdateLevelWidgetFields()
        if(PlayerUI := GetPlayerUI[Player]):
            if(show = true):
                spawn{AddLevelWidget(PlayerUI)}
            else:
                PlayerUI.RemoveWidget(level_widget)
    AddLevelWidget(PlayerUI:player_ui)<suspends>:void=
        Sleep(1.0)
        PlayerUI.AddWidget(level_widget)
        set level_widget.play_anim = 1

    UpdateLevelWidgetFields():void=
        set level_widget.lvl_txt = StringToMessage("Level {level}")
        set level_widget.current_txt = StringToMessage("{current_xp}")
        if(max_xp > 0):
            xp_percentage : float = (1.0 * current_xp) / (1.0 * max_xp)

            set level_widget.current_xp_bar_len = xp_percentage
        if(level = max_level):
            set level_widget.max_level = true
            
    GiveXp(new_amount:int):logic=
        var levelled_up : logic = false
        xp_remaining := max_xp - current_xp
        if(xp_remaining <= new_amount and level <> max_level):
            #Level up occurs
            set level += 1
            set level_widget.lvl_digit = level
            if(level = max_level):
                set current_xp = max_xp
                set level_widget.max_level = true
            else:
                set current_xp = new_amount - xp_remaining
            set levelled_up = true
        else:
            #Just add xp
            set current_xp += new_amount
        UpdateLevelWidgetFields()
        return levelled_up

    GetLevel():int=
        return level
    GetCurrentXp():int=
        return current_xp

    IncrementCurrentElims():int=
        set current_elims += 1
        return current_elims
    SetRampageWidget(img:texture, max_elims:int):void=
        set rampage_info_widget.img = img
        set rampage_info_widget.max_elims = StringToMessage("{max_elims}")
        set rampage_info_widget.current_elims = StringToMessage("0")
        if(PlayerUI := GetPlayerUI[Player]):
            PlayerUI.AddWidget(rampage_info_widget)
    UpdateRampageWidget():void=
        set rampage_info_widget.current_elims = StringToMessage("{current_elims}")
    CompleteRampageWidget():void=
        set rampage_info_widget.achieved = true

    SetCurrentPerksWidget(perk1_img:texture,perk2_img:texture):void=
        set current_perk_widget.perk1_img = perk1_img
        set current_perk_widget.perk2_img = perk2_img
        if(PlayerUI := GetPlayerUI[Player]):
            PlayerUI.AddWidget(current_perk_widget)
    UpdateCurrentPerksWidget(changed_perk1:logic, new_img:texture):void=
        if(changed_perk1?):
            set current_perk_widget.perk1_img = new_img
        else:
            set current_perk_widget.perk2_img = new_img
    SwitchCurrentPerksWidgetMode(pregame_mode:logic):void=
        set current_perk_widget.pregame_mode = pregame_mode
    AddCurrentPerksWidget():void=
        if:
            PlayerUI := GetPlayerUI[Player]
            perk1_index?
            perk2_index?
        then:
            PlayerUI.AddWidget(current_perk_widget)
    RemoveCurrentPerksWidget():void=
        if(PlayerUI := GetPlayerUI[Player]):
            PlayerUI.RemoveWidget(current_perk_widget)

    SetCurrentWidget(newWidget:widget):void=
        if(PlayerUI := GetPlayerUI[Player]):
            # Remove current widget if exists
            if(widgetToRemove := current_widget?):
                PlayerUI.RemoveWidget(widgetToRemove)
            else:
                #If current widget didnt exist
                RemoveCurrentPerksWidget()
            PlayerUI.AddWidget(newWidget, player_ui_slot{InputMode := ui_input_mode.All})
            PlayerUI.SetFocus(newWidget)
            
        set current_widget = option{newWidget}
        
    ResetCurrentWidget():void=
        if(PlayerUI := GetPlayerUI[Player], widgetToRemove := current_widget?):
            PlayerUI.RemoveWidget(widgetToRemove)
        set current_widget = false
        AddCurrentPerksWidget()
    IsInWidget():logic=
        var in_widget : logic = false
        if(the_current_widget := current_widget?):
            set in_widget = true
            if(mastery_reward_check := uis.mastery_reward_widget[the_current_widget]):
                set in_widget = false
            else if(switch_loadout_check := uis.switch_to_custom_widget[the_current_widget]):
                set in_widget = false
        return in_widget

    SetPresetIndex(new_index:?int):void=
        set preset_index = new_index
    GetPresetIndex():?int=
        return preset_index

    SetCWeaponIndex(new_index:int):void=
        set cweapon_index = new_index
    GetCWeaponIndex():int=
        return cweapon_index
    SetRWeaponIndex(new_index:int):void=
        set rweapon_index = new_index
    GetRWeaponIndex():int=
            return rweapon_index
    SetHealingIndex(new_index:int):void=
        set healing_index = new_index
    GetHealingIndex():int=
            return healing_index
    SetUtilityIndex(new_index:int):void=
            set utility_index = new_index
    GetUtilityIndex():int=
            return utility_index
    SetRampageIndex(new_index:int):void=
        set rampage_index = new_index
    GetRampageIndex():int=
        return rampage_index

    SetPerk1Index(new_index:?int):void=
        set perk1_index = new_index
    GetPerk1Index():?int=
        return perk1_index
    SetPerk2Index(new_index:?int):void=
        set perk2_index = new_index
    GetPerk2Index():?int=
        return perk2_index

    SetRWeaponProgress(new_progress:[int]int):[int]int=
        set rweapon_progress = new_progress
    SetCWeaponProgress(new_progress:[int]int):[int]int=
        set cweapon_progress = new_progress
    GetRWeaponProgress():[int]int=
        return rweapon_progress
    GetCWeaponProgress():[int]int=
        return cweapon_progress

    SetMasteryWidget(index_prefix:int, textures:[]texture, names:[]string, title:string, progress:[int]int):void=
        if:
            img0 := textures[index_prefix]
            img1 := textures[index_prefix+1]
            img2 := textures[index_prefix+2]
            img3 := textures[index_prefix+3]
            name0 := names[index_prefix]
            name1 := names[index_prefix+1]
            name2 := names[index_prefix+2]
            name3 := names[index_prefix+3]
            elims0 := progress[index_prefix]
            elims1 := progress[index_prefix+1]
            elims2 := progress[index_prefix+2]
            elims3 := progress[index_prefix+3]
            progress0 := (elims0 * 1.0) / 10.0
            progress1 := (elims1 * 1.0) / 10.0
            progress2 := (elims2 * 1.0) / 10.0
            progress3 := (elims3 * 1.0) / 10.0
        then:
            set mastery_widget.img0 = img0
            set mastery_widget.img1 = img1
            set mastery_widget.img2 = img2
            set mastery_widget.img3 = img3
            set mastery_widget.title0 = StringToMessage("{name0}")
            set mastery_widget.title1 = StringToMessage("{name1}")
            set mastery_widget.title2 = StringToMessage("{name2}")
            set mastery_widget.title3 = StringToMessage("{name3}")
            set mastery_widget.elims0 = StringToMessage("{elims0}")
            set mastery_widget.elims1 = StringToMessage("{elims1}")
            set mastery_widget.elims2 = StringToMessage("{elims2}")
            set mastery_widget.elims3 = StringToMessage("{elims3}")
            set mastery_widget.progress0 = progress0
            set mastery_widget.progress1 = progress1
            set mastery_widget.progress2 = progress2
            set mastery_widget.progress3 = progress3
            set mastery_widget.main_title = StringToMessage("{title}")
        if(PlayerUI := GetPlayerUI[Player]):
            PlayerUI.AddWidget(mastery_widget)
    HideMasteryWidget():void=
        if(PlayerUI := GetPlayerUI[Player]):
            PlayerUI.RemoveWidget(mastery_widget)

    IncrementRWeaponProgress(elim_weapon:int):?int=
        if:
            rweapon_elims := rweapon_progress[elim_weapon]
            rweapon_elims < 10
        then:
            if(set rweapon_progress[elim_weapon] += 1):
        return option{rweapon_progress[elim_weapon]}
    IncrementCWeaponProgress(elim_weapon:int):?int=
        if:
            cweapon_elims := cweapon_progress[elim_weapon]
            cweapon_elims < 10
        then:
            if(set cweapon_progress[elim_weapon] += 1):
        return option{cweapon_progress[elim_weapon]}

    SetVFXIndex(new_index:?int):void=
        set current_vfx = new_index
    GetVFXIndex():?int=
        return current_vfx

    var is_boss : logic = false
    GiveBoss():void=
        set is_boss = true
        if(PlayerUI := GetPlayerUI[Player]):
            PlayerUI.RemoveWidget(rampage_info_widget)
    GetBossStatus():logic=
        return is_boss
   





StringToMessage<localizes>(String:string):message = "{String}"


player_ui_device := class(creative_device):
    
    var player_list : [player]PlayerDetails = map{}

    #Level devices
    @editable level_tracker : tracker_device = tracker_device{}
    @editable current_xp_tracker : tracker_device = tracker_device{}
    @editable xp_huds : []hud_message_device = array{}
    @editable playtime_timer : timer_device = timer_device{}
    @editable winner_trigger : trigger_device = trigger_device{}
    @editable real_xp_accolades : []accolades_device = array{}
    xp_actions : [int]int = map{
        0 => 1000 #elim
        1 => 750 #rampage
        2 => 2500 #win
        3 => 2000 #weapon mastery
        4 => 500 #playtime
    }

    #Game management
    @editable game_start : trigger_device = trigger_device{}
    @editable MainGameDelayTrigger : trigger_device = trigger_device{}
    @editable ElimManager : elimination_manager_device = elimination_manager_device{}
    @editable PregameTimer : timer_device = timer_device{}
    @editable CloseUITrigger : trigger_device = trigger_device{}
    #Boss
    @editable BossGranter : item_granter_device = item_granter_device{}

    #Preset loadout
    @editable preset_button : button_device = button_device{}
    @editable var preset_switches : []switch_device = array{}
    @editable s_using_preset : switch_device = switch_device{}
    preset_item_indexes : [][]int = array{
        array{3,0,1,0,1},
        array{6,5,3,2,0},
        array{1,2,0,1,2}
    }

    #Custom loadout
    @editable custom_loadout_button : button_device = button_device{}
    #   Item binary switches
    @editable var cweapon_switches : []switch_device = array{}
    @editable var rweapon_switches : []switch_device = array{}
    @editable var healing_switches : []switch_device = array{}
    @editable var utility_switches : []switch_device = array{}
    @editable var rampage_switches : []switch_device = array{}

    #Item granters/removers
    @editable loadout_remover : item_remover_device = item_remover_device{}
    @editable ammo_granter : item_granter_device = item_granter_device{}
    @editable mats_granter : item_granter_device = item_granter_device{}
    @editable var cweapon_granters : []item_granter_device = array{}
    @editable var rweapon_granters : []item_granter_device = array{}
    @editable var healing_granters : []item_granter_device = array{}
    @editable var utility_granters : []item_granter_device = array{}
    @editable var rampage_granters : []item_granter_device = array{}

    #Item UI textures
    @editable rweapon_textures : []texture = array{}
    @editable cweapon_textures : []texture = array{}
    @editable healing_textures : []texture = array{}
    @editable utility_textures : []texture = array{}
    @editable rampage_textures : []texture = array{}
    rampage_amounts : []int = array{1,2,3,4,5}

    #Generic widget stuff
    @editable rgeneric_textures : []texture = array{}
    @editable cgeneric_textures : []texture = array{}
    generic_titles : []string = array{"Ranged Weapon","Close Quarter Weapon","Healing","Utility","Rampage"}
    rgeneric_names : []string = array{"Assault Rifles","Sniper Rifles","Text"}
    cgeneric_names : []string = array{"Shotguns","SMGs","Pistols"}

    rweapon_titles : [int]string = map{
        0 => "Assault Rifles",
        4 => "Sniper Rifles"}
    cweapon_titles : [int]string = map{
        0 => "Shotguns",
        4 => "SMGs",
        8 => "Pistols"}

    rweapon_names : []string = array{
        "Nemesis","Enforcer","Surgical Burst","Combat",
        "Bolt-Action","Bow","Hunting Rifle","Heavy Impact"
    }
    cweapon_names : []string = array{
        "Tactical","Charge","Double Barrel","Thunder",
        "Flex","Twin Mag","Thunder Burst","Stinger",
        "Ranger","Hand Cannon","Hammer","Mammoth"
    }
    healing_names : []string = array{
        "Small Shields","Guzzle Juice","Big Shields","Floppers","Slurp Juice"
    }
    utility_names : []string = array{
        "Proximity","Smoke","Stealth","Stink","C4"
    }
    rampage_names : []string = array{
        "Boogie","Pulse Scan","Nitro","Seven Cannon","Mythic Fish"
    }

    #Perks
    @editable perks_button : button_device = button_device{}
    @editable perk1_switches : []switch_device = array{}
    @editable perk2_switches : []switch_device = array{}
    @editable perk_textures : []texture = array{}
    perk_name_info : [][]string = array{
        array{"Healing Pack", "Extra healing items"}
        array{"Utility Pack", "Extra utility items"}
        array{"Rarity Boost", "Increase rarity +1"}
        array{"Material Pack", "Extra materials"}
        array{"Prime Materials", "Stronger materials"}
        array{"Trap Roll", "Random trap item"}
    }
    #Perk Functionality
    @editable better_cweapon_granters : []item_granter_device = array{}
    @editable better_rweapon_granters : []item_granter_device = array{}
    @editable extra_heal_granters : []item_granter_device = array{}
    @editable extra_util_granters : []item_granter_device = array{}
    @editable extra_mats_granter : item_granter_device = item_granter_device{}
    @editable better_mats_granter : item_granter_device = item_granter_device{}
    @editable trap_granter : item_granter_device = item_granter_device{}
    #Regular mats granter


    #Item and perk unlocks
    rweapon_unlocks : [int]int = map{
        #weaponIndex => levelUnlocked
        0 => 1,
        1 => 1,
        2 => 7,
        3 => 14,
        4 => 1,
        5 => 1,
        6 => 11,
        7 => 16
    }
    cweapon_unlocks : [int]int = map{
        0 => 1, 
        1 => 3,
        2 => 11,
        3 => 13,
        4 => 1,
        5 => 2,
        6 => 5,
        7 => 12,
        8 => 1,
        9 => 1,
        10 => 6,
        11 => 15
    }
    healing_unlocks : [int]int = map{
        0 => 1,
        1 => 1,
        2 => 4,
        3 => 9,
        4 => 15
    }
    utility_unlocks : [int]int = map{
        0 => 1,
        1 => 1,
        2 => 8,
        3 => 14,
        4 => 18
    }
    rampage_unlocks : [int]int = map{
        0 => 0,
        1 => 2,
        2 => 10,
        3 => 17,
        4 => 20
    }

    perk_unlocks : [int]int = map{
        0 => 5,
        1 => 10,
        2 => 19,
        3 => 5,
        4 => 12,
        5 => 16
    }

    #Mastery
    @editable mastery_button : button_device = button_device{}
    @editable remove_vfx_button : button_device = button_device{}
    @editable vfx_switches : []switch_device = array{}
    @editable s_vfx_active : switch_device = switch_device{}
    @editable vfx_creators : []vfx_creator_device = array{}
    #Trackers
    @editable rweapon_trackers : []tracker_device = array{}
    @editable cweapon_trackers : []tracker_device = array{}
    @editable ar_tracker : tracker_device = tracker_device{}
    @editable sniper_tracker : tracker_device = tracker_device{}
    @editable bow_tracker : tracker_device = tracker_device{}
    @editable bow_conbut : conditional_button_device = conditional_button_device{}
    @editable smg_tracker : tracker_device = tracker_device{}
    @editable sg_tracker : tracker_device = tracker_device{}
    @editable pistol_tracker : tracker_device = tracker_device{}
    #Volumes
    @editable ar_mastery_vol : volume_device = volume_device{}
    @editable sniper_mastery_vol : volume_device = volume_device{}
    @editable shotgun_mastery_vol : volume_device = volume_device{}
    @editable smg_mastery_vol : volume_device = volume_device{}
    @editable pistol_mastery_vol : volume_device = volume_device{}

    OnBegin<override>()<suspends>:void=
        Players : []player = GetPlayspace().GetPlayers()
        for(Player : Players):
            #Get current level and xp from the trackers
            level : int = level_tracker.GetValue(Player)
            current_xp : int = current_xp_tracker.GetValue(Player)      

            #Initialise the loadout indexes 
            var maybe_preset_index : ?int = false
            if(s_using_preset.GetCurrentState[Player]):
                #player is using a preset so add their preset index
                preset_index : int = GetBinaryIndex(Player, preset_switches)
                set maybe_preset_index = option{preset_index}
            #custom loadout indexes
            rweapon_index : int = GetBinaryIndex(Player, rweapon_switches)
            cweapon_index : int = GetBinaryIndex(Player, cweapon_switches)
            healing_index : int = GetBinaryIndex(Player, healing_switches)
            utility_index : int = GetBinaryIndex(Player, utility_switches)
            rampage_index : int = GetBinaryIndex(Player, rampage_switches)

            #perk indexes
            perk1_index : int = GetBinaryIndex(Player, perk1_switches)
            perk2_index : int = GetBinaryIndex(Player, perk2_switches)

            var maybe_vfx_index : ?int = false
            if(s_vfx_active.GetCurrentState[Player]):
                vfx_index : int = GetBinaryIndex(Player, vfx_switches)
                set maybe_vfx_index = option{vfx_index}
                if(vfx_creator := vfx_creators[vfx_index]):
                    vfx_creator.SpawnAt(Player)
                    # vfx_creator.Begin(Player)

            #Create player details object
            NewDetails : PlayerDetails = PlayerDetails{
                Player:=Player
                preset_index:=maybe_preset_index
                cweapon_index:=cweapon_index
                rweapon_index:=rweapon_index
                healing_index:=healing_index
                utility_index:=utility_index
                rampage_index:=rampage_index
                current_vfx:=maybe_vfx_index
                level:=level
                current_xp:=current_xp
                perk1_index:=if(level >= 5) then option{perk1_index} else false
                perk2_index:=if(level >= 5) then option{perk2_index} else false
            }
            #Map the player to their details object
            if(set player_list[Player] = NewDetails):
            #Show their level widget
            NewDetails.ShowLevelWidget(true)
            if(level >= 5):
                if:
                    perk1_img := perk_textures[perk1_index]
                    perk2_img := perk_textures[perk2_index+3]
                then:
                    NewDetails.SetCurrentPerksWidget(perk1_img, perk2_img)
            
        

        #Events
        game_start.TriggeredEvent.Subscribe(GameStart)
        preset_button.InteractedWithEvent.Subscribe(ShowPreset)
        custom_loadout_button.InteractedWithEvent.Subscribe(OpenCustom)
        perks_button.InteractedWithEvent.Subscribe(ShowMainPerks)
        CloseUITrigger.TriggeredEvent.Subscribe(CloseUIs)
        
        PregameTimer.SuccessEvent.Subscribe(PregameEnd)
        MainGameDelayTrigger.TriggeredEvent.Subscribe(GiveAllLoadout)
        

        #Mastery
        mastery_button.InteractedWithEvent.Subscribe(ShowMasteryReward)
        remove_vfx_button.InteractedWithEvent.Subscribe(RemoveVFX)
        #Trackers
        #Mastery volumes
        ar_mastery_vol.AgentEntersEvent.Subscribe(ShowARMastery)
        ar_mastery_vol.AgentExitsEvent.Subscribe(HideMastery)
        sniper_mastery_vol.AgentEntersEvent.Subscribe(ShowSniperMastery)
        sniper_mastery_vol.AgentExitsEvent.Subscribe(HideMastery)
        shotgun_mastery_vol.AgentEntersEvent.Subscribe(ShowShotgunMastery)
        shotgun_mastery_vol.AgentExitsEvent.Subscribe(HideMastery)
        smg_mastery_vol.AgentEntersEvent.Subscribe(ShowSMGMastery)
        smg_mastery_vol.AgentExitsEvent.Subscribe(HideMastery)
        pistol_mastery_vol.AgentEntersEvent.Subscribe(ShowPistolMastery)
        pistol_mastery_vol.AgentExitsEvent.Subscribe(HideMastery)

        #XP
        playtime_timer.SuccessEvent.Subscribe(GivePlaytimeXP)


    # AddPlayerToList(Player:player):void=
    #     new_details : PlayerDetails = PlayerDetails{
    #             Player:=Player
    #         }
    #     if(set player_list[Player] = new_details):

    RemovePlayerFromList(Player:player):void=
        var new_player_list : [player]PlayerDetails = map{}
        for(k -> v : player_list, k <> Player):
            if(set new_player_list[k] = v):
        set player_list = new_player_list

    GameStart(MaybeAgent:?agent):void=
        for(Player -> player_details : player_list):
            GiveItems(Player, player_details, true)
            spawn{SetMastery(Player, player_details)}

    GiveAllLoadout(MaybeAgent:?agent):void=
        Print("Giving loadout!")
        for(Player -> player_details : player_list):
            maybe_preset_index : ?int = player_details.GetPresetIndex()
                if(preset_index := maybe_preset_index?):
                    GrantPreset(Player, player_details, preset_index, false)
                else:
                    GrantCustom(Player, player_details, false)

    CloseUIs(MaybeAgent:?agent):void=
        for(Player -> player_details : player_list):
            in_widget := player_details.IsInWidget()
            player_details.ResetCurrentWidget()
            if(in_widget?):
                GiveItems(Player, player_details, true)
            spawn{ShowStartingInfo(Player)}
            #Change perk info mode
            player_details.SwitchCurrentPerksWidgetMode(false)
            #Show rampage widget
            var rampage_index : int = player_details.GetRampageIndex()
            maybe_preset_index : ?int = player_details.GetPresetIndex()
            if:
                preset_index := maybe_preset_index?
                preset_rampage := preset_item_indexes[preset_index][4]
            then:
                set rampage_index = preset_rampage
            if:
                rampage_img := rampage_textures[rampage_index]
                rampage_elims := rampage_amounts[rampage_index]
            then:
                player_details.SetRampageWidget(rampage_img, rampage_elims)

    ShowStartingInfo(Player:player)<suspends>:void=
        if(PlayerUI := GetPlayerUI[Player]):
            newStartingWidget : uis.auto_close_info  = uis.auto_close_info{}
            PlayerUI.AddWidget(newStartingWidget)
            set newStartingWidget.show_anim = 1
            Sleep(4.0)
            PlayerUI.RemoveWidget(newStartingWidget)

    PregameEnd(MaybeAgent:?agent):void=
        #Game
        ElimManager.EliminationEvent.Subscribe(AgentElimination)
        #Mastery
        ar_tracker.CompleteEvent.Subscribe(RWeaponElim)
        sniper_tracker.CompleteEvent.Subscribe(RWeaponElim)
        bow_tracker.CompleteEvent.Subscribe(BowWeaponCheck)
        sg_tracker.CompleteEvent.Subscribe(CWeaponElim)
        smg_tracker.CompleteEvent.Subscribe(CWeaponElim)
        pistol_tracker.CompleteEvent.Subscribe(CWeaponElim)
        #XP
        winner_trigger.TriggeredEvent.Subscribe(GiveWinXP)
        #Boss
        BossGranter.ItemGrantedEvent.Subscribe(StopRampage)


    GivePlayerXP(Agent:agent, xp_index:int):logic=
        var levelled_up : logic = false
        if:
            player_details := player_list[player[Agent]]
            xp_amount := xp_actions[xp_index]
            xp_hud := xp_huds[xp_index]
            real_xp_accolade := real_xp_accolades[xp_index]
        then:
            set levelled_up = player_details.GiveXp(xp_amount)
            new_level := player_details.GetLevel()
            if(new_level < player_details.max_level):
                xp_hud.Show(Agent)
            current_xp_tracker.SetValue(Agent, player_details.GetCurrentXp())
            level_tracker.SetValue(Agent, player_details.GetLevel())
            #Give player real xp (not in-island custom level system xp - called "pts" in uis)
            real_xp_accolade.Award(Agent)
                
        return levelled_up
    GivePlaytimeXP(MaybeAgent:?agent):void=
        if(Agent := MaybeAgent?):
            levelled_up := GivePlayerXP(Agent, 4)
            if(levelled_up?):
                if(player_details := player_list[player[Agent]]):
                    level := player_details.GetLevel()
                    if:
                        level = 5
                        img0 := perk_textures[0]
                        img1 := perk_textures[3]
                    then:
                        player_details.UpdateCurrentPerksWidget(true, img0)
                        player_details.UpdateCurrentPerksWidget(false, img1)

    GiveWinXP(MaybeAgent:?agent):void=
        if(Agent := MaybeAgent?):
            GivePlayerXP(Agent, 2)
        
    SetMastery(Player:player, player_details:PlayerDetails)<suspends>:void=
        var cweapon_progress : [int]int = map{}
        var rweapon_progress : [int]int = map{}
        for (i := 0..11):
            #do cweapon
            if(ctracker := cweapon_trackers[i]):
                c_elims := ctracker.GetValue(Player)
                if(set cweapon_progress[i] = c_elims):
            #if <= 7, do rweapon
            if(i <= 7):
                if(rtracker := rweapon_trackers[i]):
                    r_elims := rtracker.GetValue(Player)
                    if(set rweapon_progress[i] = r_elims):
        player_details.SetCWeaponProgress(cweapon_progress)
        player_details.SetRWeaponProgress(rweapon_progress)

    ShowARMastery(Agent:agent):void=
        ShowRWeaponMastery(Agent, 0,"Assault Rifle Mastery")
    ShowSniperMastery(Agent:agent):void=
        ShowRWeaponMastery(Agent, 4,"Sniper Rifle Mastery")
    ShowRWeaponMastery(Agent:agent, index_prefix:int, title:string):void=
        if:
            player_details := player_list[player[Agent]]
        then:
            rweapon_progress := player_details.GetRWeaponProgress()
            player_details.SetMasteryWidget(index_prefix,rweapon_textures,rweapon_names,title,rweapon_progress)
    ShowShotgunMastery(Agent:agent):void=
        ShowCWeaponMastery(Agent, 0,"Shotgun Mastery")
    ShowSMGMastery(Agent:agent):void=
        ShowCWeaponMastery(Agent, 4,"SMG Mastery")
    ShowPistolMastery(Agent:agent):void=
        ShowCWeaponMastery(Agent, 8,"Pistol Mastery")
    ShowCWeaponMastery(Agent:agent, index_prefix:int, title:string):void=
        if:
            player_details := player_list[player[Agent]]
        then:
            cweapon_progress := player_details.GetCWeaponProgress()
            player_details.SetMasteryWidget(index_prefix,cweapon_textures,cweapon_names,title,cweapon_progress)
    HideMastery(Agent:agent):void=
        if:
            Player := player[Agent]
            player_details := player_list[Player]
        then:
            player_details.HideMasteryWidget()


    GiveItems(Player:player, player_details:PlayerDetails, is_pregame:logic):void=
        maybe_preset_index : ?int = player_details.GetPresetIndex()
        if(preset_index := maybe_preset_index?):
            #Player is using preset, so give preset items
            GrantPreset(Player, player_details, preset_index, is_pregame)
        else:
            #Player is using custom loadout, so give custom items
            GrantCustom(Player, player_details, is_pregame)

    GrantCustom(Player:player, player_details:PlayerDetails, is_pregame:logic):void=

        ammo_granter.GrantItem(Player)
        
        maybe_perk_1 := player_details.GetPerk1Index()
        maybe_perk_2 := player_details.GetPerk2Index()
        
        rweapon_index := player_details.GetRWeaponIndex()
        if(rweapon_granter := if(maybe_perk_1 = option{2}) 
        then better_rweapon_granters[rweapon_index] 
        else rweapon_granters[rweapon_index]):
            rweapon_granter.GrantItem(Player)

        cweapon_index := player_details.GetCWeaponIndex()
        if(cweapon_granter := if(maybe_perk_1 = option{2}) 
        then better_cweapon_granters[cweapon_index] 
        else cweapon_granters[cweapon_index]):
            cweapon_granter.GrantItem(Player)

        healing_index := player_details.GetHealingIndex()
        if(healing_granter := if(maybe_perk_1 = option{0}) 
        then extra_heal_granters[healing_index]
        else healing_granters[healing_index]):
            healing_granter.GrantItem(Player)

        utility_index := player_details.GetUtilityIndex()
        if(utility_granter := if(maybe_perk_1 = option{1})
        then extra_util_granters[utility_index]
        else utility_granters[utility_index]):
            utility_granter.GrantItem(Player)

        rampage_index := player_details.GetRampageIndex()
        if(is_pregame = true, rampage_granter := rampage_granters[rampage_index]):
            rampage_granter.GrantItem(Player)

        #Perk 2 (mats and traps)
        if(maybe_perk_2 = option{0}):
            #Extra mats
            extra_mats_granter.GrantItem(Player)
        else if(maybe_perk_2 = option{1}):
            #Better mats
            better_mats_granter.GrantItem(Player)
        else:
            mats_granter.GrantItem(Player)
            if(maybe_perk_2 = option{2}):
                random_trap_index : int = GetRandomInt(0,5)
                trap_granter.GrantItemIndex(Player, random_trap_index)


    GrantPreset(Player:player, player_details:PlayerDetails, preset_index:int, is_pregame:logic):void=
        if(preset_list := preset_item_indexes[preset_index]):

            ammo_granter.GrantItem(Player)
            
            maybe_perk_1 := player_details.GetPerk1Index()
            maybe_perk_2 := player_details.GetPerk2Index()
            
            if(rweapon := preset_list[0],
            rweapon_granter := if(maybe_perk_1 = option{2}) 
            then better_rweapon_granters[rweapon] 
            else rweapon_granters[rweapon]):
                rweapon_granter.GrantItem(Player)

            if(cweapon := preset_list[1], 
            cweapon_granter := if(maybe_perk_1 = option{2}) 
            then better_cweapon_granters[cweapon] 
            else cweapon_granters[cweapon]):
                cweapon_granter.GrantItem(Player)

            if(healing := preset_list[2], 
            healing_granter := if(maybe_perk_1 = option{0}) 
            then extra_heal_granters[healing]
            else healing_granters[healing]):
                healing_granter.GrantItem(Player)

            if(utility := preset_list[3], 
            utility_granter := if(maybe_perk_1 = option{1})
            then extra_util_granters[utility]
            else utility_granters[utility]):
                utility_granter.GrantItem(Player)

            if(is_pregame = true, rampage := preset_list[4], 
            rampage_granter := rampage_granters[rampage]):
                rampage_granter.GrantItem(Player)

            #Perk 2 (mats and traps)
            if(maybe_perk_2 = option{0}):
                #Extra mats
                extra_mats_granter.GrantItem(Player)
            else if(maybe_perk_2 = option{1}):
                #Better mats
                better_mats_granter.GrantItem(Player)
            else:
                mats_granter.GrantItem(Player)
                if(maybe_perk_2 = option{2}):
                    random_trap_index : int = GetRandomInt(0,6)
                    trap_granter.GrantItemIndex(Player, random_trap_index)


        
    SetSwitchesFromIndex(Agent:agent, ss:[]switch_device, value:int):void =
        var PowerOfTwo : int = 1
        for(s : ss):
            # Check if the current bit is 1.
            # Mod is failable, so we use it in an 'if' context.
            if(DivResult := Floor(value / PowerOfTwo), Mod[DivResult, 2] = 1):
                # Bit is 1 - turn the switch ON for this agent.
                s.SetState(Agent, true)
            else:
                # Bit is 0 - turn the switch OFF for this agent.
                s.SetState(Agent, false)
            # Move to the next bit position (1 -> 2 -> 4 -> 8 -> ...)
            set PowerOfTwo *= 2
    GetBinaryIndex(Agent:agent, ss:[]switch_device):int=
        var value : int = 0
        var bit_number : int = 1
        for(s : ss):
            if(s.GetCurrentState[Agent]):
                set value += bit_number
            set bit_number *= 2
        return value

    ShowPreset(Agent:agent):void=
        #Remove loadout
        loadout_remover.Remove(Agent)
        #Show UI
        if(Player := player[Agent]):
            if(player_details := player_list[Player]):
                var selected0 : logic = false
                var selected1 : logic = false
                var selected2 : logic = false
                maybe_preset_index : ?int = player_details.GetPresetIndex()
                if(preset_index := maybe_preset_index?):
                    if(preset_index = 0):
                        set selected0 = true
                    else if(preset_index = 1):
                        set selected1 = true
                    else if(preset_index = 2):
                        set selected2 = true
                newWidget : uis.preset_loadout_widget = uis.preset_loadout_widget{
                    selected0 := selected0
                    selected1 := selected1
                    selected2 := selected2
                }
                player_details.SetCurrentWidget(newWidget)
                #Await for button events
                spawn{WaitForPlayerPreset(Player, newWidget)}
    WaitForPlayerPreset(Player:player, uiInstance:uis.preset_loadout_widget)<suspends>:void=
        var close : logic = false
        if(player_details := player_list[Player]):
            loop:
                Sleep(0.1)
                if(close = false):
                    race:
                        block:
                            #Get the index of the pressed button
                            selection_value := uiInstance.select_click.Await()
                            preset_index := selection_value(0)
                            #Set the usingPreset switch as the user has selected one
                            s_using_preset.TurnOn(Player)
                            #Set all selected checkmarks to false
                            set uiInstance.selected0 = false
                            set uiInstance.selected1 = false
                            set uiInstance.selected2 = false
                            #Check the index to show the right checkmark
                            if(preset_index = 0):
                                set uiInstance.selected0 = true
                            else if(preset_index = 1):
                                set uiInstance.selected1 = true
                            else if(preset_index = 2):
                                set uiInstance.selected2 = true
                            #Encode the index into the preset switches
                            SetSwitchesFromIndex(Player, preset_switches, preset_index)
                            #Update the stored preset index
                            player_details.SetPresetIndex(option{preset_index})
                            set close = true
                        block:
                            uiInstance.exit_click.Await()
                            set close = true
                else:
                    player_details.ResetCurrentWidget()
                    #Player exited the preset UI - check their index has a value and if give them items
                    maybe_preset_index : ?int = player_details.GetPresetIndex()
                    if(preset_index := maybe_preset_index?):
                        GrantPreset(Player, player_details, preset_index, true)
                    else:
                        GrantCustom(Player, player_details, true)
                    break
    
    OpenCustom(Agent:agent):void=
        #Show UI
        if(Player := player[Agent]):
            newSwitchWidget : uis.switch_to_custom_widget = uis.switch_to_custom_widget{}
            if(player_details := player_list[Player]):
                #Put player in stasis to stop them moving between menus
                ##  NEED TO ADD
                # Check if they're using a preset loadout
                maybe_preset_index : ?int = player_details.GetPresetIndex()
                if(maybe_preset_index <> false):
                    #Show switch UI
                    player_details.SetCurrentWidget(newSwitchWidget)
                    #Await for button events
                    spawn{WaitForPlayerSwitchToCustom(Player, newSwitchWidget)}
                else:
                    #Remove items from inventory
                    loadout_remover.Remove(Player)
                    #Open custom UI
                    newCustomLoadoutWidget : uis.custom_loadout_widget = uis.custom_loadout_widget{}
                    player_details.SetCurrentWidget(newCustomLoadoutWidget)
                    spawn{WaitForPlayerCustom(Player, newCustomLoadoutWidget)}

    WaitForPlayerSwitchToCustom(Player:player, uiInstance:uis.switch_to_custom_widget)<suspends>:void=
        var close : logic = false
        if(player_details := player_list[Player]):
            loop:
                Sleep(0.1)
                if(close = false):
                    race:
                        block:
                            uiInstance.yes_click.Await()
                            #Set preset index to false
                            player_details.SetPresetIndex(false)
                            #Turn off usingPreset switch
                            s_using_preset.TurnOff(Player)
                            #Remove items from inventory
                            loadout_remover.Remove(Player)
                            #Show custom loadout UI
                            newCustomLoadoutWidget : uis.custom_loadout_widget = uis.custom_loadout_widget{}
                            player_details.SetCurrentWidget(newCustomLoadoutWidget)
                            spawn{WaitForPlayerCustom(Player, newCustomLoadoutWidget)}
                            #Close this UI
                            set close = true
                        block:
                            uiInstance.exit_click.Await()
                            player_details.ResetCurrentWidget()
                            set close = true
                else:
                    break
    WaitForPlayerCustom(Player:player, uiInstance:uis.custom_loadout_widget)<suspends>:void=
        if(player_details := player_list[Player]):
            #Set current images
            rweapon_index := player_details.GetRWeaponIndex()
            cweapon_index := player_details.GetCWeaponIndex()
            healing_index := player_details.GetHealingIndex()
            utility_index := player_details.GetUtilityIndex()
            rampage_index := player_details.GetRampageIndex()
            if(rweapon_texture := rweapon_textures[rweapon_index]):
                set uiInstance.rweapon_texture = rweapon_texture
            if(cweapon_texture := cweapon_textures[cweapon_index]):
                set uiInstance.cweapon_texture = cweapon_texture
            if(healing_texture := healing_textures[healing_index]):
                set uiInstance.healing_texture = healing_texture
            if(utility_texture := utility_textures[utility_index]):
                set uiInstance.utility_texture = utility_texture
            if(rampage_texture := rampage_textures[rampage_index]):
                set uiInstance.rampage_texture = rampage_texture
            if(rampage_amount := rampage_amounts[rampage_index]):
                set uiInstance.rampage_elims_amount = StringToMessage("{rampage_amount}")
            var close : logic = false
            loop:
                Sleep(0.1)
                if(close = false):
                    race:
                        block:
                            edit_button_info := uiInstance.select_click.Await()
                            edit_index := edit_button_info(0)
                            if(edit_index = 0 or edit_index = 1):
                                maybeWeaponCategoryWidget := MakeWeaponCategoryWidget(edit_index)
                                if(newWeaponCategoryWidget := maybeWeaponCategoryWidget?):
                                    player_details.SetCurrentWidget(newWeaponCategoryWidget)
                                    spawn{WaitForPlayerWeaponCategory(Player, newWeaponCategoryWidget, edit_index)}
                            else if(edit_index = 2 or edit_index = 3):
                                maybeItemWidget := MakeGenericItemWidget(edit_index, player_details)
                                if(newItemWidget := maybeItemWidget?):
                                    player_details.SetCurrentWidget(newItemWidget)
                                    spawn{WaitForPlayerItem(Player, newItemWidget, edit_index)}
                            else if(edit_index = 4):
                                level := player_details.GetLevel()
                                if(
                                    locked1 := rampage_unlocks[1],
                                    locked2 := rampage_unlocks[2],
                                    locked3 := rampage_unlocks[3],
                                    locked4 := rampage_unlocks[4],
                                    item_level1 := rampage_unlocks[1],
                                    item_level2 := rampage_unlocks[2],
                                    item_level3 := rampage_unlocks[3],
                                    item_level4 := rampage_unlocks[4]
                                ):
                                    newRampageWidget : uis.rampage_widget = uis.rampage_widget{
                                        selected0 := if(rampage_index = 0) then true else false
                                        selected1 := if(rampage_index = 1) then true else false
                                        selected2 := if(rampage_index = 2) then true else false
                                        selected3 := if(rampage_index = 3) then true else false
                                        selected4 := if(rampage_index = 4) then true else false
                                        item_locked_1:=if(level < item_level1) then true else false
                                        item_locked_2:=if(level < item_level2) then true else false
                                        item_locked_3:=if(level < item_level3) then true else false
                                        item_locked_4:=if(level < item_level4) then true else false
                                        locked_text_1 := StringToMessage("Unlocked at:\nLevel {locked1}")
                                        locked_text_2 := StringToMessage("Unlocked at:\nLevel {locked2}")
                                        locked_text_3 := StringToMessage("Unlocked at:\nLevel {locked3}")
                                        locked_text_4 := StringToMessage("Unlocked at:\nLevel {locked4}")
                                    }
                                    player_details.SetCurrentWidget(newRampageWidget)
                                    spawn{WaitForPlayerRampage(Player, newRampageWidget)}
                            set close = true
                        block:
                            uiInstance.exit_click.Await()
                            player_details.ResetCurrentWidget()
                            set close = true
                            GrantCustom(Player, player_details, true)
                else:
                    break

    MakeWeaponCategoryWidget(edit_index:int):?uis.weapon_category_widget=
        var maybeWeaponCategoryWidget : ?uis.weapon_category_widget = false
        var textures : []texture = if(edit_index = 0) then rgeneric_textures else cgeneric_textures
        var names : []string = if(edit_index = 0) then rgeneric_names else cgeneric_names
        if(
            #Category images
            img_0 := textures[0]
            img_1 := textures[1]
            img_2 := textures[2]
            #Category Names
            name_0 := names[0]
            name_1 := names[1]
            name_2 := names[2]
            #Title
            title_text := generic_titles[edit_index]
        ):
            newWeaponCategoryWidget : uis.weapon_category_widget = uis.weapon_category_widget{
                img_0:=img_0
                img_1:=img_1
                img_2:=img_2
                name_0:=StringToMessage("{name_0}")
                name_1:=StringToMessage("{name_1}")
                name_2:=StringToMessage("{name_2}")
                title_text:=StringToMessage("{title_text}")
                is_close_widget:=if(edit_index = 1) then true else false
            }
            set maybeWeaponCategoryWidget = option{newWeaponCategoryWidget}
            
        return maybeWeaponCategoryWidget

    MakeGenericItemWidget(edit_index:int, player_details:PlayerDetails):?uis.generic_item_widget=
        var maybeItemWidget : ?uis.generic_item_widget = false
        var textures : []texture = if(edit_index = 2) then healing_textures else utility_textures
        var names : []string = if(edit_index = 2) then healing_names else utility_names
        var unlocks : [int]int = if(edit_index = 2) then healing_unlocks else utility_unlocks
        level := player_details.GetLevel()
        current_index : int = if(edit_index = 2) then player_details.GetHealingIndex() else player_details.GetUtilityIndex()
        if(
            #Category images
            img_0 := textures[0]
            img_1 := textures[1]
            img_2 := textures[2]
            img_3 := textures[3]
            img_4 := textures[4]
            #Category Names
            name_0 := names[0]
            name_1 := names[1]
            name_2 := names[2]
            name_3 := names[3]
            name_4 := names[4]
            #Weapon level checks
            item1_level := unlocks[1]
            item2_level := unlocks[2]
            item3_level := unlocks[3]
            item4_level := unlocks[4]
            #Title
            title_text := generic_titles[edit_index]
        ):
            newItemWidget : uis.generic_item_widget = uis.generic_item_widget{
                selected0:=if(current_index = 0) then true else false
                selected1:=if(current_index = 1) then true else false
                selected2:=if(current_index = 2) then true else false
                selected3:=if(current_index = 3) then true else false
                selected4:=if(current_index = 4) then true else false
                img_0:=img_0
                img_1:=img_1
                img_2:=img_2
                img_3:=img_3
                img_4:=img_4
                item_text_0:=StringToMessage("{name_0}")
                item_text_1:=StringToMessage("{name_1}")
                item_text_2:=StringToMessage("{name_2}")
                item_text_3:=StringToMessage("{name_3}")
                item_text_4:=StringToMessage("{name_4}")
                title_text:=StringToMessage("{title_text}")
                item_locked_1:=if(level < item1_level) then true else false
                item_locked_2:=if(level < item2_level) then true else false
                item_locked_3:=if(level < item3_level) then true else false
                item_locked_4:=if(level < item4_level) then true else false
                locked_text_1 := StringToMessage("Unlocked at:\nLevel {item1_level}")
                locked_text_2 := StringToMessage("Unlocked at:\nLevel {item2_level}")
                locked_text_3 := StringToMessage("Unlocked at:\nLevel {item3_level}")
                locked_text_4 := StringToMessage("Unlocked at:\nLevel {item4_level}")
            }
            set maybeItemWidget = option{newItemWidget}
            
        return maybeItemWidget
    
    WaitForPlayerWeaponCategory(Player:player, uiInstance:uis.weapon_category_widget, edit_index:int)<suspends>:void=
        var close : logic = false
        var textures : []texture = if(edit_index = 0) then rweapon_textures else cweapon_textures
        var names : []string = if(edit_index = 0) then rweapon_names else cweapon_names
        var unlocks : [int]int = if(edit_index = 0) then rweapon_unlocks else cweapon_unlocks
        var titles : [int]string = if(edit_index = 0) then rweapon_titles else cweapon_titles
        if(player_details := player_list[Player]):
            loop:
                Sleep(0.1)
                if(close = false):
                    race:
                        block:
                            button_info := uiInstance.select_click.Await()
                            index_prefix := button_info(0)
                            current_index := if(edit_index = 0) then player_details.GetRWeaponIndex() else player_details.GetCWeaponIndex()
                            level := player_details.GetLevel()
                            if(
                                #Weapon images
                                weapon_img_0 := textures[0+index_prefix],
                                weapon_img_1 := textures[1+index_prefix],
                                weapon_img_2 := textures[2+index_prefix],
                                weapon_img_3 := textures[3+index_prefix],
                                #Weapon names
                                weapon_name_0 := names[0+index_prefix],
                                weapon_name_1 := names[1+index_prefix],
                                weapon_name_2 := names[2+index_prefix],
                                weapon_name_3 := names[3+index_prefix],
                                #Weapon level checks
                                weapon1_level := unlocks[1+index_prefix]
                                weapon2_level := unlocks[2+index_prefix]
                                weapon3_level := unlocks[3+index_prefix]
                                #Title
                                title_text := titles[index_prefix]
                            ):
                                newGenericRangedWidget : uis.generic_weapon_widget = uis.generic_weapon_widget{
                                    selected0:=if(current_index = 0+index_prefix) then true else false
                                    selected1:=if(current_index = 1+index_prefix) then true else false
                                    selected2:=if(current_index = 2+index_prefix) then true else false
                                    selected3:=if(current_index = 3+index_prefix) then true else false
                                    weapon_img_0:=weapon_img_0
                                    weapon_img_1:=weapon_img_1
                                    weapon_img_2:=weapon_img_2
                                    weapon_img_3:=weapon_img_3
                                    weapon_name_0:=StringToMessage("{weapon_name_0}")
                                    weapon_name_1:=StringToMessage("{weapon_name_1}")
                                    weapon_name_2:=StringToMessage("{weapon_name_2}")
                                    weapon_name_3:=StringToMessage("{weapon_name_3}")
                                    title_text:=StringToMessage("{title_text}")
                                    weapon_locked_1:=if(level < weapon1_level) then true else false
                                    weapon_locked_2:=if(level < weapon2_level) then true else false
                                    weapon_locked_3:=if(level < weapon3_level) then true else false
                                    weapon_locked_text_1 := StringToMessage("Unlocked at:\nLevel {weapon1_level}")
                                    weapon_locked_text_2 := StringToMessage("Unlocked at:\nLevel {weapon2_level}")
                                    weapon_locked_text_3 := StringToMessage("Unlocked at:\nLevel {weapon3_level}")
                                }
                                player_details.SetCurrentWidget(newGenericRangedWidget)
                                spawn{WaitForPlayerGenericWeapon(Player, newGenericRangedWidget, edit_index, index_prefix)}
                            #Close this UI
                            set close = true
                        block:
                            uiInstance.exit_click.Await()
                            set close = true
                            #Re-show custom loadout UI
                            newCustomLoadoutWidget : uis.custom_loadout_widget = uis.custom_loadout_widget{}
                            player_details.SetCurrentWidget(newCustomLoadoutWidget)
                            spawn{WaitForPlayerCustom(Player, newCustomLoadoutWidget)}
                else:
                    break
    WaitForPlayerGenericWeapon(Player:player, uiInstance:uis.generic_weapon_widget, edit_index:int, index_prefix:int)<suspends>:void=
        var close : logic = false
        if(player_details := player_list[Player]):
            loop:
                Sleep(0.1)
                if(close = false):
                    race:
                        block:
                            ar_button_info := uiInstance.select_click.Await()
                            index := ar_button_info(0)

                            var should_swap : logic = false

                            
                            #Check the index to show the right selection
                            if(index = 0):
                                set should_swap = true
                            else if(index = 1 and uiInstance.weapon_locked_1 = false):
                                set should_swap = true
                            else if(index = 2 and uiInstance.weapon_locked_2 = false):
                                set should_swap = true
                            else if(index = 3 and uiInstance.weapon_locked_3 = false):
                                set should_swap = true
                            if(should_swap = true):
                                set uiInstance.selected0 = if(index = 0) then true else false
                                set uiInstance.selected1 = if(index = 1) then true else false
                                set uiInstance.selected2 = if(index = 2) then true else false
                                set uiInstance.selected3 = if(index = 3) then true else false
                                if(edit_index = 0):
                                    SetSwitchesFromIndex(Player, rweapon_switches, index+index_prefix)
                                    player_details.SetRWeaponIndex(index+index_prefix)
                                else if(edit_index = 1):
                                    SetSwitchesFromIndex(Player, cweapon_switches, index+index_prefix)
                                    player_details.SetCWeaponIndex(index+index_prefix)
                                #Auto close back to the custom widget
                                set close = true
                                newCustomLoadoutWidget : uis.custom_loadout_widget = uis.custom_loadout_widget{}
                                player_details.SetCurrentWidget(newCustomLoadoutWidget)
                                spawn{WaitForPlayerCustom(Player, newCustomLoadoutWidget)}

                        block:
                            uiInstance.exit_click.Await()
                            set close = true
                            maybeWeaponCategoryWidget := MakeWeaponCategoryWidget(edit_index)
                                if(newWeaponCategoryWidget := maybeWeaponCategoryWidget?):
                                    player_details.SetCurrentWidget(newWeaponCategoryWidget)
                                    spawn{WaitForPlayerWeaponCategory(Player, newWeaponCategoryWidget, edit_index)}
                else:
                    break
    WaitForPlayerItem(Player:player, uiInstance:uis.generic_item_widget, edit_index:int)<suspends>:void=
        var close : logic = false
        if(player_details := player_list[Player]):
            loop:
                Sleep(0.1)
                if(close = false):
                    race:
                        block:
                            button_info := uiInstance.select_click.Await()
                            new_index := button_info(0)

                            var should_swap : logic = false

                            #Check the index to show the right selection
                            if(new_index = 0):
                                set should_swap = true
                            else if(new_index = 1 and uiInstance.item_locked_1 = false):
                                set should_swap = true
                            else if(new_index = 2 and uiInstance.item_locked_2 = false):
                                set should_swap = true
                            else if(new_index = 3 and uiInstance.item_locked_3 = false):
                                set should_swap = true
                            else if(new_index = 4 and uiInstance.item_locked_4 = false):
                                set should_swap = true
                            if(should_swap = true):
                                set uiInstance.selected0 = if(new_index = 0) then true else false
                                set uiInstance.selected1 = if(new_index = 1) then true else false
                                set uiInstance.selected2 = if(new_index = 2) then true else false
                                set uiInstance.selected3 = if(new_index = 3) then true else false
                                set uiInstance.selected4 = if(new_index = 4) then true else false
                                if(edit_index = 2):
                                    SetSwitchesFromIndex(Player, healing_switches, new_index)
                                    player_details.SetHealingIndex(new_index)
                                else if(edit_index = 3):
                                    SetSwitchesFromIndex(Player, utility_switches, new_index)
                                    player_details.SetUtilityIndex(new_index)
                                #Auto close back to the custom widget
                                set close = true
                                newCustomLoadoutWidget : uis.custom_loadout_widget = uis.custom_loadout_widget{}
                                player_details.SetCurrentWidget(newCustomLoadoutWidget)
                                spawn{WaitForPlayerCustom(Player, newCustomLoadoutWidget)}

                        block:
                            uiInstance.exit_click.Await()
                            set close = true
                            newCustomLoadoutWidget : uis.custom_loadout_widget = uis.custom_loadout_widget{}
                            player_details.SetCurrentWidget(newCustomLoadoutWidget)
                            spawn{WaitForPlayerCustom(Player, newCustomLoadoutWidget)}
                else:
                    break
    WaitForPlayerRampage(Player:player, uiInstance:uis.rampage_widget)<suspends>:void=
        var close : logic = false
        if(player_details := player_list[Player]):
            loop:
                Sleep(0.1)
                if(close = false):
                    race:
                        block:
                            button_info := uiInstance.select_click.Await()
                            new_index := button_info(0)

                            var should_swap : logic = false

                            #Check the index to show the right selection
                            if(new_index = 0):
                                set should_swap = true
                            else if(new_index = 1 and uiInstance.item_locked_1 = false):
                                set should_swap = true
                            else if(new_index = 2 and uiInstance.item_locked_2 = false):
                                set should_swap = true
                            else if(new_index = 3 and uiInstance.item_locked_3 = false):
                                set should_swap = true
                            else if(new_index = 4 and uiInstance.item_locked_4 = false):
                                set should_swap = true
                            if(should_swap = true):
                                set uiInstance.selected0 = if(new_index = 0) then true else false
                                set uiInstance.selected1 = if(new_index = 1) then true else false
                                set uiInstance.selected2 = if(new_index = 2) then true else false
                                set uiInstance.selected3 = if(new_index = 3) then true else false
                                set uiInstance.selected4 = if(new_index = 4) then true else false
                                SetSwitchesFromIndex(Player, rampage_switches, new_index)
                                player_details.SetRampageIndex(new_index)
                                #Auto close back to the custom widget
                                set close = true
                                newCustomLoadoutWidget : uis.custom_loadout_widget = uis.custom_loadout_widget{}
                                player_details.SetCurrentWidget(newCustomLoadoutWidget)
                                spawn{WaitForPlayerCustom(Player, newCustomLoadoutWidget)}
                        block:
                            uiInstance.exit_click.Await()
                            set close = true
                            newCustomLoadoutWidget : uis.custom_loadout_widget = uis.custom_loadout_widget{}
                            player_details.SetCurrentWidget(newCustomLoadoutWidget)
                            spawn{WaitForPlayerCustom(Player, newCustomLoadoutWidget)}
                else:
                    break
    
    
    ShowMainPerks(Agent:agent):void=
        #Show UI
        if(Player := player[Agent]):
            if(player_details := player_list[Player]):
                #Remove items from inventory
                loadout_remover.Remove(Player)
                #Open main perks UI
                newMainPerksWidget : uis.main_perks_widget = uis.main_perks_widget{}
                player_details.SetCurrentWidget(newMainPerksWidget)
                spawn{WaitForPlayerMainPerks(Player, newMainPerksWidget)}

    WaitForPlayerMainPerks(Player:player, uiInstance:uis.main_perks_widget)<suspends>:void=
        var close : logic = false
        if(player_details := player_list[Player]):
            loop:
                Sleep(0.1)
                if(close = false):
                    race:
                        block:
                            button_info := uiInstance.select_click.Await()
                            index_prefix := button_info(0)
                            level := player_details.GetLevel()
                            var selected0 : logic = false
                            var selected1 : logic = false
                            var selected2 : logic = false
                            maybe_current_index := if(index_prefix = 0) then player_details.GetPerk1Index() else player_details.GetPerk2Index()
                            if(current_index := maybe_current_index?):
                                set selected0 = if(current_index = 0) then true else false
                                set selected1 = if(current_index = 1) then true else false
                                set selected2 = if(current_index = 2) then true else false
                            if(
                                #images
                                img_0 := perk_textures[0+index_prefix],
                                img_1 := perk_textures[1+index_prefix],
                                img_2 := perk_textures[2+index_prefix],
                                #names
                                perk_name_0 := perk_name_info[0+index_prefix][0],
                                perk_name_1 := perk_name_info[1+index_prefix][0],
                                perk_name_2 := perk_name_info[2+index_prefix][0],
                                #descriptions 
                                perk_desc_0 := perk_name_info[0+index_prefix][1],
                                perk_desc_1 := perk_name_info[1+index_prefix][1],
                                perk_desc_2 := perk_name_info[2+index_prefix][1],
                                #level checks
                                perk0_level := perk_unlocks[0+index_prefix]
                                perk1_level := perk_unlocks[1+index_prefix]
                                perk2_level := perk_unlocks[2+index_prefix]
                                #title and title description
                                title_text := if(index_prefix = 0) then "1st Perk" else "2nd Perk"
                                title_description := if(index_prefix = 0) then "Item buffs" else "Building buffs"
                            ):
                                newGenericPerkWidget : uis.generic_perk_widget = uis.generic_perk_widget{
                                    selected0:=selected0
                                    selected1:=selected1
                                    selected2:=selected2
                                    weapon_img_0:=img_0
                                    weapon_img_1:=img_1
                                    weapon_img_2:=img_2
                                    weapon_name_0:=StringToMessage("{perk_name_0}")
                                    weapon_name_1:=StringToMessage("{perk_name_1}")
                                    weapon_name_2:=StringToMessage("{perk_name_2}")
                                    description0:=StringToMessage("{perk_desc_0}")
                                    description1:=StringToMessage("{perk_desc_1}")
                                    description2:=StringToMessage("{perk_desc_2}")
                                    title_text:=StringToMessage("{title_text}")
                                    title_description:=StringToMessage("{title_description}")
                                    weapon_locked_0:=if(level < perk0_level) then true else false
                                    weapon_locked_1:=if(level < perk1_level) then true else false
                                    weapon_locked_2:=if(level < perk2_level) then true else false
                                    weapon_locked_text_0 := StringToMessage("Unlocked at:\nLevel {perk0_level}")
                                    weapon_locked_text_1 := StringToMessage("Unlocked at:\nLevel {perk1_level}")
                                    weapon_locked_text_2 := StringToMessage("Unlocked at:\nLevel {perk2_level}")
                                }
                                player_details.SetCurrentWidget(newGenericPerkWidget)
                                spawn{WaitForPlayerGenericPerk(Player, newGenericPerkWidget, index_prefix)}
                                #Close this UI
                            set close = true
                        block:
                            uiInstance.exit_click.Await()
                            player_details.ResetCurrentWidget()
                            set close = true
                            #Player exited the preset UI - check if they are using
                            #   a preset and grant the preset/custom loadout
                            maybe_preset_index : ?int = player_details.GetPresetIndex()
                            if(preset_index := maybe_preset_index?):
                                GrantPreset(Player, player_details, preset_index, true)
                            else:
                                GrantCustom(Player, player_details, true)
                else:
                    break

    WaitForPlayerGenericPerk(Player:player, uiInstance:uis.generic_perk_widget, index_prefix:int)<suspends>:void=
        var close : logic = false
        if(player_details := player_list[Player]):
            loop:
                Sleep(0.1)
                if(close = false):
                    race:
                        block:
                            perk_button_info := uiInstance.select_click.Await()
                            index := perk_button_info(0)

                            var should_swap : logic = false

                            #Check the index to show the right selection
                            if(index = 0 and uiInstance.weapon_locked_0 = false):
                                set should_swap = true
                            else if(index = 1 and uiInstance.weapon_locked_1 = false):
                                set should_swap = true
                            else if(index = 2 and uiInstance.weapon_locked_2 = false):
                                set should_swap = true
                            if(should_swap = true):
                                set uiInstance.selected0 = if(index = 0) then true else false
                                set uiInstance.selected1 = if(index = 1) then true else false
                                set uiInstance.selected2 = if(index = 2) then true else false
                                if(index_prefix = 0):
                                    SetSwitchesFromIndex(Player, perk1_switches, index)
                                    player_details.SetPerk1Index(option{index})
                                    if(new_img := perk_textures[index+index_prefix]):
                                        player_details.UpdateCurrentPerksWidget(true, new_img)
                                else if(index_prefix = 3):
                                    SetSwitchesFromIndex(Player, perk2_switches, index)
                                    player_details.SetPerk2Index(option{index})
                                    if(new_img := perk_textures[index+index_prefix]):
                                        player_details.UpdateCurrentPerksWidget(false, new_img)

                                #Auto close back to the perks widget
                                set close = true
                                #Open main perks UI
                                newMainPerksWidget : uis.main_perks_widget = uis.main_perks_widget{}
                                player_details.SetCurrentWidget(newMainPerksWidget)
                                spawn{WaitForPlayerMainPerks(Player, newMainPerksWidget)}
                                

                        block:
                            uiInstance.exit_click.Await()
                            set close = true
                            newMainPerksWidget : uis.main_perks_widget = uis.main_perks_widget{}
                            player_details.SetCurrentWidget(newMainPerksWidget)
                            spawn{WaitForPlayerMainPerks(Player, newMainPerksWidget)}
                            
                else:
                    break

    CalcMasteryProgress(player_details:PlayerDetails):[int]int=
        rweapon_progress := player_details.GetRWeaponProgress()
        cweapon_progress := player_details.GetCWeaponProgress()

        var c_total : int = 0
        var r_total : int = 0
        var ar_total : int = 0
        var sn_total : int = 0
        var smg_total : int = 0
        var sg_total : int = 0
        var pis_total : int = 0

        for(r_index -> r_elims : rweapon_progress):
            if(r_elims = 10):
                set r_total += 1
                #Ar
                if(r_index < 4):
                    set ar_total += 1
                #Sniper
                else:
                    set sn_total += 1
        for(c_index -> c_elims : cweapon_progress):
            if(c_elims = 10):
                set c_total += 1
                #Shogtun
                if(c_index < 4):
                    set sg_total += 1
                #Pistol
                else if(c_index >= 8):
                    set pis_total += 1
                #Smg
                else:
                    set smg_total += 1

        #Check for any 2 weapons -- (total < 2) then total else 2
        #Check if all of one type
        #Check if all c -- c_total
        #Check if all r -- r_total
        #Check if all -- (c_total + r_total)

        total : int = c_total + r_total
        var gold_result : int = 0
        if:
            ar_total = 4 or
            sn_total = 4 or
            sg_total = 4 or
            smg_total = 4 or
            pis_total = 4
        then:
            set gold_result = 1
        var calc_result : [int]int = map{
            0 => if(total >= 2) then 2 else total
            1 => gold_result
            2 => r_total
            3 => c_total
            4 => total
        }

        return calc_result
    ShowMasteryReward(Agent:agent):void=
        #Show UI
        if(Player := player[Agent]):
            if(player_details := player_list[Player]):
                mastery_progress : [int]int = CalcMasteryProgress(player_details)
                var selected0 : logic = false
                var selected1 : logic = false
                var selected2 : logic = false
                var selected3 : logic = false
                maybe_vfx_index : ?int = player_details.GetVFXIndex()
                if(vfx_index := maybe_vfx_index?):
                    set selected0 = if(vfx_index = 0) then true else false
                    set selected1 = if(vfx_index = 1) then true else false
                    set selected2 = if(vfx_index = 2) then true else false
                    set selected3 = if(vfx_index = 3) then true else false
                if:
                    camo_master := mastery_progress[0]
                    gold_master := mastery_progress[1]
                    champ_master0 := mastery_progress[2]
                    champ_master1 := mastery_progress[3]
                    unreal_master := mastery_progress[4]
                    progress0 := (camo_master * 1.0) / 2.0
                    progress1 := (gold_master * 1.0) / 1.0
                    progress2p1 := (champ_master0 * 1.0) / 8.0
                    progress2p2 := (champ_master1 * 1.0) / 12.0
                    progress3 := (unreal_master * 1.0) / 20.0
                    locked0 := if(progress0 < 1.0) then true else false
                    locked1 := if(progress1 < 1.0) then true else false
                    locked2 := if(progress2p1 < 1.0 and progress2p2 < 1.0) then true else false
                    locked3 := if(progress3 < 1.0) then true else false
                then:
                    newWidget : uis.mastery_reward_widget = uis.mastery_reward_widget{
                        selected0:=selected0
                        selected1:=selected1
                        selected2:=selected2
                        selected3:=selected3
                        progress0 := progress0
                        progress1 := progress1
                        progress2p1 := progress2p1
                        progress2p2 := progress2p2
                        progress3 := progress3
                        locked0 := locked0
                        locked1 := locked1
                        locked2 := locked2
                        locked3 := locked3
                        btntxt0 := StringToMessage("{if(locked0?) then "Locked" else "Select"}")
                        btntxt1 := StringToMessage("{if(locked1?) then "Locked" else "Select"}")
                        btntxt2 := StringToMessage("{if(locked2?) then "Locked" else "Select"}")
                        btntxt3 := StringToMessage("{if(locked3?) then "Locked" else "Select"}")
                        camo_master := StringToMessage("{camo_master}")
                        gold_master := StringToMessage("{gold_master}")
                        champ_master0 := StringToMessage("{champ_master0}")
                        champ_master1 := StringToMessage("{champ_master1}")
                        unreal_master := StringToMessage("{unreal_master}")
                    }
                    player_details.SetCurrentWidget(newWidget)
                    #Await for button events
                    spawn{WaitForPlayerMasteryReward(Player, newWidget)}

    WaitForPlayerMasteryReward(Player:player, uiInstance:uis.mastery_reward_widget)<suspends>:void=
        
        var close : logic = false
        if(player_details := player_list[Player]):
            loop:
                Sleep(0.1)
                if(close = false):
                    race:
                        block:
                            vfx_button_info := uiInstance.select_click.Await()
                            index := vfx_button_info(0)

                            var should_swap : logic = false

                            #Check the index to show the right selection
                            if(index = 0 and uiInstance.locked0 = false):
                                set should_swap = true
                            else if(index = 1 and uiInstance.locked1 = false):
                                set should_swap = true
                            else if(index = 2 and uiInstance.locked2 = false):
                                set should_swap = true
                            else if(index = 3 and uiInstance.locked3 = false):
                                set should_swap = true
                            if(should_swap = true):
                                s_vfx_active.TurnOn(Player)
                                set uiInstance.selected0 = if(index = 0) then true else false
                                set uiInstance.selected1 = if(index = 1) then true else false
                                set uiInstance.selected2 = if(index = 2) then true else false
                                set uiInstance.selected3 = if(index = 3) then true else false
                                SetSwitchesFromIndex(Player, vfx_switches, index)
                                player_details.SetVFXIndex(option{index})
                                set close = true

                        block:
                            uiInstance.exit_click.Await()
                            set close = true

                else:
                    player_details.ResetCurrentWidget()
                    #Spawn VFX on players
                    var index : ?int = false
                    if(uiInstance.selected0 = true):
                        set index = option{0}
                    if(uiInstance.selected1 = true):
                        set index = option{1}
                    else if(uiInstance.selected2 = true):
                        set index = option{2}
                    else if(uiInstance.selected3 = true):
                        set index = option{3}
                    if(new_index := index?):
                        for(i := 0..3):
                            if(vfx_creator := vfx_creators[i]):
                                if(i = new_index):
                                    vfx_creator.SpawnAt(Player)
                                else:
                                    vfx_creator.Remove(Player)
                    break

    RemoveVFX(Agent:agent):void=
        if(player_details := player_list[player[Agent]]):
            player_details.SetVFXIndex(false)

    StopRampage(Agent:agent):void=
        if(player_details := player_list[player[Agent]]):
            player_details.GiveBoss()
    AgentElimination(MaybeAgent:?agent):void=
        if:
            Agent := MaybeAgent?
            Player := player[Agent]
            player_details := player_list[Player]
        then:
            #give elim xp
            GivePlayerXP(Agent, 0)

            current_elims := player_details.IncrementCurrentElims()
            is_boss := player_details.GetBossStatus()
            if(is_boss = false):
                var rampage_index : int = player_details.GetRampageIndex()
                maybe_preset_index : ?int = player_details.GetPresetIndex()
                if:
                    preset_index := maybe_preset_index?
                    preset_rampage := preset_item_indexes[preset_index][4]
                then:
                    set rampage_index = preset_rampage
                if(rampage_elims := rampage_amounts[rampage_index]):
                    if(current_elims <= rampage_elims):
                        player_details.UpdateRampageWidget()
                        if:
                            current_elims = rampage_elims
                            rampage_granter := rampage_granters[rampage_index]
                        then:
                            rampage_granter.GrantItem(Agent)
                            player_details.CompleteRampageWidget()
                            #give rampage xp
                            GivePlayerXP(Agent, 1)

    BowWeaponCheck(Agent:agent):void=
        if(bow_conbut.IsHoldingItem[Agent]):
            RWeaponElim(Agent)
    RWeaponElim(Agent:agent):void=
        if:
            Player := player[Agent]
            player_details := player_list[Player]
        then:
            rweapon_progress := player_details.GetRWeaponProgress()
            var rweapon_index : int = player_details.GetRWeaponIndex()
            maybe_preset_index : ?int = player_details.GetPresetIndex()
            if:
                preset_index := maybe_preset_index?
                preset_rweapon := preset_item_indexes[preset_index][0]
            then:
                set rweapon_index = preset_rweapon
            #Check they haven't already mastered their current rweapon (prevents further procesing)
            if(current_progress := rweapon_progress[rweapon_index]):
                if:
                    current_progress < 10
                    tracker := rweapon_trackers[rweapon_index]
                then:
                    #Call method in player_details to increment the amount in rweapon_progress
                    maybe_rweapon_elims := player_details.IncrementRWeaponProgress(rweapon_index)
                    #Set tracker value
                    if(rweapon_elims := maybe_rweapon_elims?):
                        tracker.SetValue(Agent, rweapon_elims)
                        if(rweapon_elims = 10):
                            GivePlayerXP(Agent, 3)
    CWeaponElim(Agent:agent):void=
        if:
            Player := player[Agent]
            player_details := player_list[Player]
        then:
            cweapon_progress := player_details.GetCWeaponProgress()
            var cweapon_index : int = player_details.GetCWeaponIndex()
            maybe_preset_index : ?int = player_details.GetPresetIndex()
            if:
                preset_index := maybe_preset_index?
                preset_cweapon := preset_item_indexes[preset_index][1]
            then:
                set cweapon_index = preset_cweapon
            #Check they haven't already mastered their current rweapon (prevents further procesing)
            if(current_progress := cweapon_progress[cweapon_index]):
                if:
                    current_progress < 10
                    tracker := cweapon_trackers[cweapon_index]
                then:
                    #Call method in player_details to increment the amount in rweapon_progress
                    maybe_cweapon_elims := player_details.IncrementCWeaponProgress(cweapon_index)
                    #Set tracker value
                    if(cweapon_elims := maybe_cweapon_elims?):
                        tracker.SetValue(Agent, cweapon_elims)
                        if(cweapon_elims = 10):
                            GivePlayerXP(Agent, 3)


