# frozen_string_literal: true

module NominationTypes
  extend ActiveSupport::Concern

  included do
    enum(:nomination_type, {
           gotm: 'gotm',
           rpg: 'rpg',
           retro: 'retro',
           goty: 'goty',
           gotwoty: 'gotwoty'
         })
  end
end
