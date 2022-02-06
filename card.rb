class Card
  attr_reader :face, :suit
  attr_accessor :value
  
  def initialize(face, suit, value)
    @face = face
    @suit = suit
    @value = value
  end

  def show
    "#{@face}#{@suit}"
  end

  def hide
    '***'
  end
end