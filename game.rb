require_relative './deck'
require_relative './user'
require_relative './dealer'
require_relative './hand'
require_relative './bank'

class Game

  BET = 10

  attr_accessor :user, :dealer, :deck, :bank, :wins
  attr_reader   :bet

  def initialize
    @user = Player.new
    @dealer = Dealer.new
    @deck = Deck.new
    @bank = Bank.new
    @bet = BET
    @end_of_round = false
    @wins = { user: 0, dealer: 0 }
    start_game
  end

  private

  def start_game
    puts 'Hello! Welcome to Casino Black jack!'
    user.name = input_str('What is your name?')
    puts "\nWe start the game. Place your bets gentlemen!"
    play
  end

  def play
    first_deal
    next_deal until open_cards?
    round_result
    choice(NEW_ROUND)
  end

  def first_deal
    bets
    deal_cards
    game_screen
  end

  def bets
    user.place_bet( bet )
    dealer.place_bet( bet )
    bank.accept_bets( 2*bet )
  end

  def deal_cards
    user.take_card(deck.deal(2))
    dealer.take_card(deck.deal(2))
    puts "\nCards Dealt!"
  end

  def game_screen
    puts
    bold_line
    puts "#{bank_status.center 50}"
    line
    puts player_status
    bold_line
    puts
  end
    
  def next_deal
    choice(USER_CHOICE)
    dealer_choice
    game_screen
  end

  USER_CHOICE = [
    { key: 1, title: 'Stand!', action: :user_stand },
    { key: 2, title: 'Hit me!', action: :user_hit },
    { key: 3, title: 'Open cards!', action: :open_cards }
  ].freeze

  def choice( menu )
      puts "Enter your choice: "
      menu.each { |item| puts "#{item[:key].to_s.rjust 15} -  #{item[:title]}" }
    loop do
      print '-> '
      choice = gets.chomp.to_i
      choice_item = menu.find { |item| item[:key] == choice }
      unless choice_item.nil?
        send(choice_item[:action]) 
        break
      end
    end
  end

  def user_stand
    if user.pass?
      puts 'You already missed a turn! Make a different choice!'
      choice(USER_CHOICE)
    else
      user.pass = true
      puts 'You stand!'
    end
  end

  def user_hit
    return if user.hand.three_cards?
    user.take_card(deck.deal(1))
    puts 'You taken card!'
  end

  def dealer_stand
      dealer.pass = true
      puts 'Dealer stand!'
  end

  def dealer_hit
    return if dealer.hand.three_cards?
    dealer.take_card(deck.deal(1))
    puts 'Dealer take card!'
  end

  def open_cards
    puts 'You chosen to open cards!'
    @end_of_round = true
  end

  def open_cards?
    return true if ( players_three_cards? || @end_of_round )
    false
  end

  def players_three_cards?
    user.hand.three_cards? && dealer.hand.three_cards?
  end

  def bank_status
    "Game bank: #{bank.bankroll}"
  end

  # def player_status
  #   <<-STATUS
  #     Player   : #{(user.name.center 20)} | #{(dealer.name.center 20)}
  #     Bankroll : #{(user.bankroll.to_s.center 20)} | #{(dealer.bankroll.to_s.center 20)}
  #     Cards    : #{(user.hand.show.center 20)} | #{(dealer.hand.show.center 20)}
  #     Points   : #{(user.hand.points.to_s.center 20)} | #{(dealer.hand.points.to_s.center 20)}
  #     Wins     : #{(wins[:user].to_s.center 20)} | #{(wins[:dealer].to_s.center 20)}      
  #   STATUS
  # end

  def player_status
    str = [
            "Player   : "\
            "#{(user.name.center 20)} | #{(dealer.name.center 20)}\n",
            "Bankroll : "\
            "#{(user.bankroll.to_s.center 20)} | #{(dealer.bankroll.to_s.center 20)}\n",
            "Cards    : #{(user.hand.show.center 20)} | "\
            "#{open_cards? ? (dealer.hand.show.center 20) : (dealer.hand.hide.center 20)}\n",
            "Points   : #{(user.hand.points.to_s.center 20)} | "\
            "#{open_cards? ? (dealer.hand.points.to_s.center 20) : ('*****'.center 20)}\n",
            "Wins     : "\
            "#{(wins[:user].to_s.center 20)} | #{(wins[:dealer].to_s.center 20)}\n"
    ]
  end

  def dealer_choice
    if dealer.soft_17? && dealer.pass? == false
      dealer_stand
    else
      dealer_hit
    end
  end

  def round_result
    if users_bust? && dealers_bust?
      push
    elsif users_bust?
      dealer_won 
    elsif dealers_bust?
      user_won
    elsif user_points > dealer_points 
      user_won
    elsif dealer_points > user_points
      dealer_won
    else
      push
    end
    game_screen
  end

  def dealer_won
    puts "#{dealer.name}! Unfortunately, you lost!  Dealer won."
    winning_amount(dealer)
    wins[:dealer] += 1
  end

  def user_won
    puts "#{user.name}! Congratulations, you've won!"
    winning_amount(user)
    wins[:user] += 1
  end

  def game_results
      "#{(user.name.rjust 15)} won #{wins[:user]} rounds.\n"\
      "#{(dealer.name.rjust 15)} won #{wins[:dealer]} rounds.\n"\
  end

  def push
    puts 'The round is over. Push!'
    push_amount
  end

  def winning_amount(player)
    prize = bank.prize
    player.bankroll += prize
    bank.bankroll -= prize
  end

  def push_amount
    prize = bank.prize / 2
    user.bankroll += prize
    dealer.bankroll += prize
    bank.bankroll -= 2 * prize
  end

  def user_points
    user.hand.points
  end

  def dealer_points
    dealer.hand.points
  end

  def users_bust?
    user_points > 21
  end

  def dealers_bust?
    dealer_points > 21
  end

  NEW_ROUND = [
    { key: 1, title: 'Play?', action: :new_game },
    { key: 2, title: 'Surrender?', action: :stop }
  ].freeze  

  def new_game
    init_new_round
    play
  end

  def stop
    puts game_results
    puts 'Good buy!'
    exit(0)
  end  

  def init_new_round
    @deck = Deck.new
    user.pass = false
    user.hand = Hand.new
    dealer.pass = false
    dealer.hand = Hand.new
    @end_of_round = false
  end

  def input_str( instruction )
    print "#{instruction}: "
    gets.chomp.to_s
  end

  def bold_line
    puts '=' * 55
  end

  def line
    puts '-' * 55
  end
end
