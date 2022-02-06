require_relative './card'

# Deck - create a random deck of 52 cards
# J - Jack, Q - Queen, K - King, A - Ace

class Deck
  FACES = [*(2..10), 'J', 'Q', 'K', 'A'].freeze
  SUITS = ['♣', '♥', '♠', '♦'].freeze
  
  attr_reader :cards

  def initialize
    @cards = []
    form_deck_of_cards
    @cards.shuffle!
  end

  def deal(count = 1)
    @cards.pop(count)
  end

  private

  # Loop thgrogh each face
  # Then loop thgrogh each suit for that face to generate 1 of every combo

  def form_deck_of_cards
    FACES.each do |face|
      if face.is_a? Integer
        value = face
      elsif face == 'A'
        value = 11
      else
        value = 10
      end

      SUITS.each do |suit|
        @cards << Card.new(face, suit, value)
      end
    end
  end
end
