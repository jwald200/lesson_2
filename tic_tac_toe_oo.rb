class Board
  WINNING_LINES = [
    [1,2,3],[4,5,6],[7,8,9],
    [1,4,7],[2,5,8],[3,6,9],
    [1,5,9],[3,5,7]
  ]
  EMPTY_SQUARE = '-'

  attr_accessor :squares
  def initialize
    @squares = {}
    (1..9).each { |position| @squares[position] = EMPTY_SQUARE }
  end

  def draw
    system 'clear'
    squares.values.each_slice(3).with_index do |line, i|
      puts line.join(' | ')
      puts '-' * 10 unless i == 2
    end
  end

  def free_squares
    squares.select { |_, square| square == EMPTY_SQUARE }.keys
  end

  def two_in_a_row(marker)
    WINNING_LINES.detect do |line|
      board_line = squares.values_at(*line)
      (board_line.count(marker) == 2) && board_line.include?(EMPTY_SQUARE)
    end
  end

  def three_in_a_row?(marker)
    WINNING_LINES.any? do |line|
      squares.values_at(*line).count(marker) == 3
    end
  end
end

class Player
  attr_accessor :score
  attr_reader :marker, :name

  def initialize(name, marker)
    @name = name
    @marker = marker
    @score = 0
  end
end

class Human < Player
  def pick_square(board)
    free_squares = board.free_squares
    choice = ''
    loop do
      puts "Please choose one of the avaliable squares #{free_squares}"
      choice = gets.chomp.to_i
      break if free_squares.include?(choice)
      puts "oops #{choice} is not an empty square."
    end
    board.squares[choice] = marker
  end
end

class Robot < Player
  def pick_square(board)
    @board = board
    player = board.two_in_a_row(opponent_marker)
    robot = board.two_in_a_row(marker)
    if robot
      smart_pick(robot)
    elsif player
      smart_pick(player)
    else
      random_pick
    end
  end

  private

  def opponent_marker
    (marker == 'x') ? 'o' : 'x'
  end

  def smart_pick(line)
    position = line.detect do |square|
                 @board.squares[square] == Board::EMPTY_SQUARE
               end
    @board.squares[position] = marker
  end

  def random_pick
    position = @board.free_squares.sample
    @board.squares[position] = marker
  end
end

class Game
  def initialize
    @human = Human.new('mike', 'x')
    @robot = Robot.new('KX90', 'o')
    @current_player = @human
  end

  private

  def game_over?
    @board.free_squares.empty? || winner?
  end

  def winner?
    @board.three_in_a_row?(@current_player.marker)
  end

  def winner_name
    @current_player.name
  end

  def scores
    "#{@robot.name}'s score: #{@robot.score}" \
    " | #{@human.name}'s score: #{@human.score}"
  end

  def display_outcome
    if winner?
      puts "#{@current_player.name} won!"
    else
      puts "It's a tie!"
    end
    puts scores
  end

  def update_score
    @current_player.score += 1 if winner?
  end

  def altarnate_player
    if @current_player == @human
      @current_player = @robot
    else
      @current_player = @human
    end
  end

  def play
    loop do
      @current_player.pick_square(@board)
      @board.draw
      break if game_over?
      altarnate_player
    end
  end

  public

  def run
    loop do
      @board = Board.new
      @board.draw
      play
      update_score
      display_outcome
      puts 'Play again? (Y/N)'
      break if gets.chomp.downcase == 'n'
    end
    puts 'Goodbye!'
  end
end

Game.new.run
