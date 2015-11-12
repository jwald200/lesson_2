class Player
  attr_accessor :hand, :score
  def initialize
    @score = 0
  end
end

class Human < Player
  def pick
    loop do
      puts "please choose (r) Rock, (p) Paper, (s) Scissors"
      choice = gets.chomp.downcase
      self.hand = choice
      break if Game::CHOICES.keys.include?(choice)
      puts "#{choice} is not a valid option. please try again."
    end
  end
end

class Computer < Player
  def pick
    self.hand = Game::CHOICES.keys.sample
  end
end

class Game
  CHOICES = { 'r' => 'Rock', 'p' => 'Paper', 's' => 'Scissors' }
  WINNING_SCENARIOS = { 'r' => ['r', 's'], 'p' => ['p', 'r'], 's' => ['p', 's'] }
  def initialize
    @human = Human.new
    @computer = Computer.new
  end

  def win_hand
    game = [@human.hand, @computer.hand]
    WINNING_SCENARIOS.each do |hand, scenario|
      return hand if (scenario & game).size == 2
    end
    false
  end

  def win_message
    case win_hand
    when 'r'
      'Rock breaks scissors!'
    when 'p'
      'Paper wraps rock!'
    when 's'
      'Scissors cuts paper!'
    end
  end

  def players_hands
    "You chose #{CHOICES[@human.hand]} " \
    "| Computer chose #{CHOICES[@computer.hand]}"
  end

  def scores
    "Your score: #{@human.score} | Computer score #{@computer.score}"
  end

  def winner
    if @computer.hand == win_hand
      'Computer won!'
    else
      'You won!'
    end
  end

  def update_score
    @computer.score += 1 if @computer.hand == win_hand
    @human.score += 1 if @human.hand == win_hand
  end

  def display_outcome
    puts players_hands
    if win_hand
      puts win_message
      puts winner
    else
      puts "It's a tie."
    end
    puts scores
  end

  def run
    loop do
      system 'clear'
      puts 'welcome to rps'
      @human.pick
      @computer.pick
      update_score
      system 'clear'
      display_outcome
      puts 'Play again (Y/N)'
      break if gets.chomp.downcase == 'n'
    end
    puts 'Thanks for playing.'
  end
end

Game.new.run
