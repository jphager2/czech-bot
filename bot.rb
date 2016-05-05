include Facebook::Messenger

puts "Bot Coming online"

def puts(string)
  $stderr.puts(string)
end

Bot.on(:message) do |message|

  Bot.deliver(
    recipient: message.sender,
    message: {
      text: "Ahoj!"
    }
  )
end


Facebook::Messenger.configure do |config|
  config.access_token = 'EAAYqja1OZBYkBAAx3Dd2jcsvpAa2QUPHVNrzqTui4PMtmlxFkS83kyagKokSYNVgBnrS1quxCEyxSQXVZA2vCxWq6k0KclfS36CfREQLkF38uhgVYrtQeioPZAcBWWBW0AnwSnqC2OI96b0P5pDEOXpWKymEcPmu1VDYWpiwwZDZD'
  config.verify_token = 'ceskeretardy'
end

Facebook::Messenger::Subscriptions.subscribe
