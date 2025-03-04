
-- atlas
SMODS.Atlas { key = 'Jokers', path = 'Jokers.png', px = 71, py = 95 }
SMODS.Atlas { key = 'crystalball', path = 'crystalball.png', px = 71, py = 95 }
SMODS.Atlas { key = 'ancienthourglass', path = 'ancienthourglass.png', px = 71, py = 95 }

-- yoink the vanilla mr bones
SMODS.Joker:take_ownership('j_mr_bones',{
      calculate = function(self, card, context)
        if context.end_of_round and not context.blueprint and not context.repetition and not context.individual and 
        G.GAME.chips/G.GAME.blind.chips >= 0.25 and SMODS.saved == "lose_the_game" then
            G.E_MANAGER:add_event(Event({
                func = function()
                    G.hand_text_area.blind_chips:juice_up()
                    G.hand_text_area.game_chips:juice_up()
                    play_sound('tarot1')
                    card:start_dissolve()
                    return true
                end
            })) 
            return {
                message = localize('k_saved_ex'),
                saved = "true",
                colour = G.C.RED
            }
        end
      end
    },
    true -- silent | suppresses mod badge
)

-- Cultist
SMODS.Joker{
    key = 'cultist',
    loc_txt = {
      name = 'Cultist',
      text={
        "{X:mult,C:white} X#1# {} Mult",
        "{C:green}#2# in #3#{} chance you {C:red}die{}",
        "This chance {C:attention}doubles{}",
        "at end of round",
      }
    },
    config = {
      extra = {
        Xmult = 3,
        rounds_passed = 0,
        odds = 1000,
      }
    },
    loc_vars = function(self, info_queue, card)
      return { vars = {
        card.ability.extra.Xmult,
        ''..(G.GAME and G.GAME.probabilities.normal or 1)*2^(card.ability.extra.rounds_passed or 0),
        card.ability.extra.odds,
      }}
    end,
    rarity = 3,
    cost = 6,
    blueprint_compat = false,
    eternal_compat = true,
    atlas = 'Jokers',
    pos = {x=0, y=0},
    calculate = function(self, card, context)
      if context.cardarea == G.jokers and context.joker_main then
        return {
          message = localize{type='variable',key='a_xmult',vars={card.ability.extra.Xmult}},
          Xmult_mod = card.ability.extra.Xmult,
        }
      elseif context.end_of_round and not context.blueprint and not context.repetition and not context.individual then
        card.ability.extra.rounds_passed = card.ability.extra.rounds_passed + 1
        if pseudorandom('Cultist') < ((G.GAME and G.GAME.probabilities.normal or 1)*2^(card.ability.extra.rounds_passed or 0))/card.ability.extra.odds then
          return {saved = "lose_the_game"}
        end
      end
    end,
}

-- Propaganda
SMODS.Joker{
  key = 'propaganda',
  name = "Propaganda",
  loc_txt = {
    name = 'Propaganda',
    text={
      "Your hand size is always {C:attention}#1#{}",
      "{C:inactive}(It cannot change){}"
    },
  },
  config = {
    extra = {
      handsize = 3
    }
  },
  loc_vars = function(self, info_queue, card)
    return { vars = {
      card.ability.extra.handsize
    }}
  end,
  rarity = 2,
  cost = 6,
  blueprint_compat = false,
  eternal_compat = true,
  atlas = 'Jokers',
  pos = {x=0, y=0},
  -- when added, set current hand size to 3
  add_to_deck = function(self, card, from_debuff)
    G.GAME.saved_hand_size = G.hand.config.card_limit
    G.hand:change_size(3-G.hand.config.card_limit)
  end,
  -- when removed, revert hand size change
  remove_from_deck = function(self, card, from_debuff)
    G.hand:change_size((G.GAME.saved_hand_size or 8)-3)
  end,
}

-- Crystal Ball
SMODS.Joker{
  key='crystalball',
  loc_txt = {
    name = 'Crystal Ball',
    text={
      "{C:green}#1# in #2#{} chance for each",
      "played {C:attention}6{} to create a",
      "{C:spectral}Spectral{} card when scored",
      "{C:inactive}(Must have room)",
    },
  },
  atlas = 'crystalball',
  pos = {x=0,y=0},
  rarity = 2,
  cost = 6,
  blueprint_compat = true,
  eternal_compat = true,
  config = {
    extra = {
      odds = 6
    }
  },
  loc_vars = function(self, info_queue, card)
    return { vars = {''..(G.GAME and G.GAME.probabilities.normal or 1),card.ability.extra.odds}}
  end,
  calculate = function(self, card, context)
    if context.cardarea == G.play and context.individual and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
      if (context.other_card:get_id() == 6) and (pseudorandom('8ball') < G.GAME.probabilities.normal/card.ability.extra.odds) then
          G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
          return {
              extra = {focus = card, message = localize('k_plus_spectral'), func = function()
                  G.E_MANAGER:add_event(Event({
                      trigger = 'before',
                      delay = 0.0,
                      func = (function()
                              local card = create_card('Spectral',G.consumeables, nil, nil, nil, nil, nil, 'sixth')
                              card:add_to_deck()
                              G.consumeables:emplace(card)
                              G.GAME.consumeable_buffer = 0
                          return true
                      end)}))
              end},
              colour = G.C.SECONDARY_SET.Spectral,
              card = card
          }
      end
    end
  end,
}

-- Ancient Hourglass
SMODS.Joker{
  key = 'timeglass',
  loc_txt = {
    name = 'Ancient Hourglass',
    text={
      "{C:attention}-1 Ante{} when this card is purchased",
      "{C:attention}+1 Ante{} when this card is sold",
    }
  },
  rarity = 3,
  cost = 8,
  blueprint_compat = false,
  eternal_compat = true,
  atlas = 'ancienthourglass',
  pos = {x=0, y=0},
  soul_pos = {x=0, y=1},
  add_to_deck = function(self, card, from_debuff)
    if not from_debuff then ease_ante(-1) end
  end,
  remove_from_deck = function(self, card, from_debuff)
    if not from_debuff then ease_ante(1) end
  end,
}

-- Purgatory Package
assert(SMODS.load_file('/Purgatory.lua'))()