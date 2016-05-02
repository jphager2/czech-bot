include Facebook::Messenger

puts "Bot Coming online"

def puts(string)
  $stderr.puts(string)
end

@log ||= Hash.new { |h, k| h[k] = [] }

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

  if friends?(friend)
    text = "Hi again, #{friend}"
  else
    text = "Hello, friend..."
  end

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
