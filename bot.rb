include Facebook::Messenger

@log ||= Hash.new { |h, k| h[k] = [] }

def log(friend, message)
  @log[friend] << message
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
    message = "Hi again, #{friend}"
  else
    message = "Hello, friend..."
  end

  Bot.deliver(
    recipient: friend,
    message: {
      text: message
    }
  )

  log(message.sender, message)
end

Facebook::Messenger.configure do |config|
  config.access_token = 'EAAJmZAsyf5M8BAJzDyBu6KKI5X3VARSP5VARSNnyfPxFOWDnulZCL2AM71CBzXQ3snD69ZAZC1AXZBLY7SVHHWuYq9cFYTg1yWMoZAHBoi0H4OBQBtgjgSYFf5bqN7eFAGaglQpZAWV2u96XCV6eC6GUEkzriy56TmvTrQ63jgHlwZDZD'
  config.verify_token = 'snapekillsdumbledore'
end

Facebook::Messenger::Subscriptions.subscribe
