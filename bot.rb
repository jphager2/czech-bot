require 'ruby-go'
require 'stringio'

include Facebook::Messenger

puts "Bot Coming online"

def puts(string)
  $stderr.puts(string)
end

@log ||= Hash.new { |h, k| h[k] = [] }
@games ||= {}

def games
  @games
end

def new_game(friend)
  @games[friend] = Game.new(board: 9)
end

def play(friend, x, y, text)
  x = 1 if x < 1 || x > 9
  y = 1 if y < 1 || y > 9
  x -= 1
  y -= 1
  game = @games[friend]
  game.white(x, y)
  random_bot_move(friend, text)
end

def random_bot_move(friend, text)
  game = @games[friend]
  possible_moves = Array.new(2, (0..8).to_a).flatten.combination(2).uniq

  possible_moves.shuffle.each do |x, y|
    begin
      game.black(x, y)
      return
    rescue Game::IllegalMove
    end
  end
  new_game(friend)
  text.puts "No where else to go...starting a new game =p"
end

def log(friend, message)
  @log[friend] << message

  puts "New message from Friend: #{friend}"
end

def friends
  @log.keys
end

def friends?(friend)
  @log.key?(friend)
end

def messages(friend)
  @log[friend]
end

Bot.on(:message) do |message|
  friend = message.sender
  said = message.text

  text = StringIO.new

  if friends?(friend)
    if said =~ /resign/
      new_game(friend, text)
    elsif said =~ /(\d),(\d)/
      x, y = said.match(/(\d),(\d)/)[1..2]
      play(friend, x, y, text)
    else
      text.puts "Sorry, I don't know that one..."
    end
  else
    text.puts <<-TEXT
Hi friend! Lets play Go! 
Just send me a move like this: 3,3 OR 1,1 OR 9,9
If you want to start a new game, just say "resign" ^^
I'll go first =).
    TEXT

    new_game(friend)
  end
  text.puts games[friend].board.to_s
  text = text.string

  log(message.sender, message)

  Bot.deliver(
    recipient: friend,
    message: {
      text: text
    }
  )

  puts "Bot sending message: #{text}"
end

Facebook::Messenger.configure do |config|
  config.access_token = 'EAAJmZAsyf5M8BAJzDyBu6KKI5X3VARSP5VARSNnyfPxFOWDnulZCL2AM71CBzXQ3snD69ZAZC1AXZBLY7SVHHWuYq9cFYTg1yWMoZAHBoi0H4OBQBtgjgSYFf5bqN7eFAGaglQpZAWV2u96XCV6eC6GUEkzriy56TmvTrQ63jgHlwZDZD'
  config.verify_token = 'snapekillsdumbledore'
end

Facebook::Messenger::Subscriptions.subscribe
