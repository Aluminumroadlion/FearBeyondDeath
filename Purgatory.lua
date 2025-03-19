
-- Purgatory
  SMODS.Joker{
    key='purgatory',
    loc_txt = {
      name = 'The Gates of Limbo',
      text={
        "Prevents Death",
        "Enter {C:red}Hell{} when you die",
        "If you win, win the blind",
        "{S:1.1,C:red,E:2}self destructs{}",
      },
    },
    loc_vars = function(self, info_queue, card)
      info_queue[#info_queue+1] = {key = "fear_beyond_death_hellinfo", set = "Other"}
    end,
    atlas = 'gates_of_limbo',
    pos = {x=0,y=0},
    rarity = 3,
    cost = 8,
    blueprint_compat = false,
    eternal_compat = false,
    config = {},
    calculate = function(self, card, context)
      if context.end_of_round and not context.blueprint and G.GAME.returned_from_hell == true then
        G.GAME.returned_from_hell = false
        G.E_MANAGER:add_event(Event({
          func = function()
              card:start_dissolve()
              return true
          end
        }))
      end
    end,
    add_to_deck = function(self, card, from_debuff)
      G.GAME.purgatory_check = true
    end,
    remove_from_deck = function(self, card, from_debuff)
      G.GAME.purgatory_check = false
    end,
  }
  
  -- hell deck
  SMODS.Challenge{
    key = "purgatorychallenge",
    name = "Hell",
    loc_txt = {
      name = 'Hell',
    },
    rules = {
      custom = {
        -- {id = 'starting_ante_zero', value = true},
        {id = 'win_ante', value = 3},
        {id = 'stake', value = 8},
        {id = 'all_boss_blinds', value = true},
      },
      modifiers = {
        -- {id = 'hands', value = 3},
        -- {id = 'hand_size', value = 6},
        -- {id = 'joker_slots', value = 6},
      },
    },
    restrictions = {
      banned_cards = {
        {id = "j_fear_beyond_death_purgatory"}
      },
    },
    consumeables = {
      {id = 'c_judgement'},
    },
    unlocked = function(self)
      for k, v in pairs(G.PROFILES[1].challenge_progress.completed) do
        if k == 'c_fear_beyond_death_purgatorychallenge' and v then return true end
      end
      return false
    end,
  }
  
-- 
-- PURGATORY FUNCTIONS
-- 
  -- when you lose, instead give the option to enter purgatory
  FBD_Purgatory = function()
    G.GAME.purgatorytext = "Enter Hell"
    G.GAME.OLDGAME = STR_UNPACK(get_compressed(G.SETTINGS.profile..'/'..'save.jkr'))
    G.GAME.OLDGAME.GAME.chips = G.GAME.blind.chips
    G.GAME.OLDGAME.GAME.purgatory_check = false
    G.GAME.OLDGAME.GAME.returned_from_hell = true
  end
  
  -- what happens when you press the "enter purgatory" button
  G.FUNCS.enter_purgatory_run = function(e)
    local found = nil
    for i=1,#G.CHALLENGES do
      if G.CHALLENGES[i].name == "Hell" then
        found = i
        break
      end
    end
    G.FUNCS.start_run(e, {challenge = G.CHALLENGES[found], oldgame = G.GAME.OLDGAME})
  end
  
  -- what happens when you return from purgatory
  G.FUNCS.return_from_hell = function(e)
    G.FUNCS.start_run(e, {savetext = G.GAME.OLDGAME})
    G.GAME.OLDGAME = nil
    G.GAME.purgatorytext = nil
  end

  -- override get_type for hell challenge, where all blinds are boss blinds
  function Blind:get_type()
    if G.GAME.round_resets.blind_states.Small == 'Current' then
      return 'Small'
    end
    if G.GAME.round_resets.blind_states.Big == 'Current' then
      return 'Big'
    end
    if G.GAME.round_resets.blind_states.Boss == 'Current' then
      return 'Boss'
    end
  end
-- 
-- END PURGATORY FUNCTIONS
-- 

-- Localization
SMODS.current_mod.process_loc_text = function()
  G.localization.misc.v_text.ch_c_all_boss_blinds = {"All {C:attention}Blinds{} are {C:attention}Boss Blinds{}"}
  G.localization.misc.v_text.ch_c_stake = {"Play on Gold Stake"}
  -- G.localization.misc.v_text.ch_c_starting_ante_zero = {"Start on Ante {C:attention}0{}"}
  G.localization.misc.v_text.ch_c_win_ante = {"Win on Ante {C:attention}3{}"}
  G.localization.descriptions.Other.fear_beyond_death_hellinfo = {
    name = "Hell",
    text = {
      "Play a Balatro {C:attention}subgame{}",
      "with the {C:red}Hell{} challenge",
    }
  }
end