class Hand
  attr_reader :points

  def initialize
    @cards = []
    @points = 0
  end

  def take_card(card)
    @cards.concat(card)
    scoring
    change_ace_as_1
  end

  def show
    @cards.map(&:show) * ', '
  end

  def hide
    @cards.map(&:hide) * ', '
  end

  def three_cards?
    @cards.count == 3
  end

  private

  def scoring
    @points = @cards.map(&:value).inject(:+)
  end

  def change_ace_as_1
    @points -= 10 if ace? && goes_bust?
  end

  def ace?
    @cards.map(&:face).include?( 'A' )
  end

  def goes_bust?
    @points > 21
  end
end
