class Card
  attr_reader :face_value

  def initialize(suit, face_value)
    @suit = suit
    @face_value = face_value
  end

  private

  def format_card
    "|#{face_value} - #{find_suit}|"
  end

  def find_suit
    case @suit
    when 'H' then 'Hearts'
    when 'D' then 'Diamonds'
    when 'S' then 'Spades'
    when 'C' then 'Clubs'
    end
  end

  def to_s
    format_card
  end
end

class Deck
  def initialize
    @cards = init_cards
  end

  def deal_card
    @cards.pop
  end

  def reset
    @cards = init_cards
  end

  private

  def init_cards
    suits = %w(H D S C)
    face_value = %w(2 3 4 5 6 7 8 9 10 J Q K A)

    suits.product(face_value).map { |card| Card.new(*card) }.shuffle
  end
end

module Hand
  attr_accessor :name, :cards

  def add_card(new_card)
    cards << new_card
  end

  def busted?
    total > Blackjack::BLACKJACK_AMOUNT
  end

  def blackjack?
    total == Blackjack::BLACKJACK_AMOUNT
  end

  def total
    face_values = cards.map(&:face_value)

    total = face_values.reduce(0) do |sum, face|
              if face == 'A'
                sum + 11
              else
                sum + (face.to_i == 0 ? 10 : face.to_i)
              end
            end

    face_values.reduce(total) do |sum, face|
      if face == 'A' && sum > Blackjack::BLACKJACK_AMOUNT
        sum - 10
      else
        sum
      end
    end
  end

  def reset
    self.cards = []
  end
end

class Player
  include Hand

  def initialize(name)
    @name = name
    @cards = []
  end

  def hit_or_stay
    loop do
      puts "#{name} What would you like to do? Hit(h) or Stay(s)"
      answer = gets.chomp.downcase
      return  answer if %(h s).include?(answer)
      puts "#{answer} is not a valid option."
    end
  end

  def show_hand
    puts "#{name}'s hand:"
    puts cards.join
    puts "Total: #{total}"
  end
end

class Dealer
  include Hand

  def initialize
    @name = 'Dealer'
    @cards = []
  end

  def show_hand(state='')
    puts "#{name}'s hand:"
    if state == :initial
      puts "| -- | #{cards[1]}"
    else
      puts cards.join
      puts "Total #{total}"
    end
  end
end

class Blackjack
  attr_reader :player, :dealer, :deck

  BLACKJACK_AMOUNT = 21
  DEALER_HIT_MIN = 17

  def initialize
    @deck = Deck.new
    @player = Player.new('joe')
    @dealer = Dealer.new
  end

  def start
    ask_name
    deal_cards
    display_table(:initial)
    player_turn
    dealer_turn if player.total < BLACKJACK_AMOUNT
    say 'Game over'
    display_table(:game_over)
    play_again
  end

  private

  def player_turn
    while player.total < BLACKJACK_AMOUNT
      break if player.hit_or_stay == 's'
      player.add_card(deck.deal_card)
      system 'clear'
      player.show_hand
    end
  end

  def dealer_turn
    say "You've chosen to stay. Turning to dealer"
    while dealer.total < DEALER_HIT_MIN
      say "#{dealer.name} has #{dealer.total} and will hit..."
      dealer.add_card(deck.deal_card)
    end
  end

  def display_table(state='')
    system 'clear'
    dealer.show_hand(state)
    puts '-' * 10
    player.show_hand
    puts game_over_msg if state == :game_over
  end

  def game_over_msg
    case
    when dealer.total == player.total
      "It's a tie!"
    when dealer.busted?
      "#{player.name} won! dealer has busted"
    when player.busted?
      "oops! You've busted"
    when dealer.blackjack?
      "#{player.name}, You lost. dealer hit blacjack"
    when player.blackjack?
      "#{player.name}, You've hit blackjack"
    when dealer.total > player.total
      "#{player.name}, you lost"
    else
      "#{player.name} won!"
    end
  end

  def say(msg)
    puts msg
    sleep 1.5
  end

  def ask_name
    puts 'Welcome to blackjack'
    puts "What's your name?"
    player.name = gets.chomp
  end

  def deal_cards
    say 'Preparing the game...'
    2.times do
      player.add_card(deck.deal_card)
      dealer.add_card(deck.deal_card)
    end
  end

  def play_again
    puts 'Play again? (Y/N)'
    answer = gets.chomp.downcase
    if !answer == 'n'
      reset_game
      start
    else
      puts 'Thanks for playing!'
    end
  end

  def reset_game
    deck.reset
    player.reset
    dealer.reset
  end
end

game = Blackjack.new
game.start
