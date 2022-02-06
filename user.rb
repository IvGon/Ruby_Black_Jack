require_relative './hand'

class Player

  attr_accessor :name, :hand, :bankroll
  attr_writer :pass

  def initialize(name = 'User', bankroll = 100)
    @name = name
    @bankroll = bankroll
    @hand = Hand.new
    @pass = false
  end

  def place_bet( bet_size )
    @bankroll -= bet_size unless bankrupt?
    bet_size
  end

  def pass?
    @pass
  end

  def take_card(card)
    hand.take_card(card)
  end

  private

  def bankrupt?
    @bankroll.zero?
  end
end
