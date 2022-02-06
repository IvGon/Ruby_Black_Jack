class Bank
  attr_accessor :bankroll

  def initialize
    @bankroll = 0
  end

  def accept_bets(bet)
    @bankroll += bet
  end

  def prize
    @bankroll
  end
end
