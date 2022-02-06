require_relative './user'

class Dealer < Player
  
  # Dealer must stop at 17
  STOP = 17

  def initialize
    super( name = 'Dealer' )
  end

  def soft_17?
    hand.points >= STOP
  end
end