Player = Struct.new(:number, :name, :marker)

class ConnectFour
  attr_reader :board, :player1, :player2
  
  def initialize
    @board = Array.new(6) { Array.new(7) { "_" } }
    @player1 = Player.new(1, "Player 1", "X")
    @player2 = Player.new(2, "Player 2", "O")
  end
  
  def show_board
    @board.reverse.each { |row| puts row.join }
  end
  
  def game
    player_number = 1
    game_end_indicator = 0
    until game_end_indicator > 0
      show_board
      puts "*** #{current_player(player_number).name}, which column will you drop into? ***"
      input = gets.chomp
      check_input(input)
      drop_marker(input, player_number)
      if win?(player_number)
        game_end_indicator = 1
      elsif board_full?
        game_end_indicator = 2
      else
        player_number = switch_player(player_number)
      end     
    end
    if game_end_indicator == 1
      show_board
      puts "*** #{current_player(player_number).name} wins! Play again? ***"
      play_again?
    else
      puts "*** The game is a draw! Play again? ***"
      play_again?
    end
  end
  
  def check_input(input)
    if ( input =~ /\D/ || input.to_i < 1 || input.to_i > 8 )
      puts "Invalid input. Please enter a single digit."
      new_input = gets.chomp
      check_input(new_input)
    else
      input
    end
  end
  
  def drop_marker(input, player_number, row_counter = 0)
    if row_counter == 6
      row_counter = 0
      puts "This column is full already. Select another column."
      new_input = gets.chomp
      drop_marker(check_input(new_input), player_number, row_counter)
    elsif @board[row_counter][input.to_i - 1] == "_" 
      @board[row_counter][input.to_i - 1] = current_player(player_number).marker
    else
      row_counter += 1
      drop_marker(input, player_number, row_counter)
    end
  end
  
  def current_player(player_number)
    player_number == 1 ? @player1 : @player2
  end
  
  def switch_player(player_number)
    player_number == 1 ? 2 : 1
  end
  
  def board_full?
    @board.flatten.!include? "_" ? true : false
  end
  
  def win?(player_number)
    # join board elements into a string, then check for 4 of the current player's marker
    winning_string = ""
    4.times { winning_string << current_player(player_number).marker }
    if (check_columns(winning_string, 7, @board) ||
       check_rows(winning_string, 6, @board) ||
       check_diagonals(winning_string) )
      true
    else
      false
    end
  end
  
  def check_columns(string, number_of_columns, board, row_counter = 0)  
    transpose = board.transpose
    check_rows(string, number_of_columns, transpose, row_counter)
  end
  
  def check_rows(string, number_of_rows, board, row_counter = 0)
    #taking 'board' as a variable allows for checking for diagonals (below) easier
    if row_counter > number_of_rows - 1
      false
    elsif board[row_counter].join.include? string.to_s
      true
    else
      row_counter += 1
      check_rows(string, number_of_rows, board, row_counter)
    end

  end
  
  def check_diagonals(string)
    #here we create a new 'diagonal_board' array that takes all of the cells in the original board
    #that can make a diagonal win
    diagonal_board = [
      @board[0].slice(0..3),
      @board[1].slice(0..4),
      @board[2].slice(0..5),
      @board[3].slice(1..6),
      @board[4].slice(2..6),
      @board[5].slice(3..6)
    ]
    
    #then, we shift the elements in the first and second rows TO THE RIGHT, using unshift, by 2 and 1, respectively
    2.times { diagonal_board[0].unshift("_") }
    diagonal_board[1].unshift("_")
    
    #next, append 1 and 2 empty cells to the fifth and sixth rows, respectively
    diagonal_board[4] << "_"
    2.times { diagonal_board[5] << "_" }
    
    #now, checking for diagonals amounts to checking rows and columns in the 'diagonal_board' array, 
    #which is now a 6-element array, whose elements each contain 6 elements
    if check_rows(string, 6, diagonal_board, row_counter = 0) 
      true
    else 
      check_columns(string, 6, diagonal_board, row_counter = 0) ? true : false
    end
  end
  
  def play_again?
    response = gets.chomp.downcase
    case response
    when "yes" then ConnectFour.new.game
    when "no" then exit
    else puts "*** Invalid entry.  Enter 'yes' or 'no'. ***"
      play_again?
    end
  end
  
end

ConnectFour.new.game

