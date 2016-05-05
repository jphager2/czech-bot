include Facebook::Messenger

puts "Bot Coming online"

module CzechBot
  def self.log(string)
    $stderr.puts(string)
  end

  class Response

    attr_reader :message, :sender
    def initialize(message)
      @message = message.text
      @sender = message.sender
    end

    def recipient
      @sender
    end

    def text
      "Ahoj!"
    end
  end
end

Bot.on(:message) do |message|
  CzechBot.log "Got a message from: #{message.sender}"

  response = CzechBot::Response.new(message)

  Bot.deliver(
    recipient: response.recipient,
    message: {
      text: response.text
    }
  )

  CzechBot.log "Saying: #{response.text.inspect}"
end


Facebook::Messenger.configure do |config|
  config.access_token = 'EAAYqja1OZBYkBAAx3Dd2jcsvpAa2QUPHVNrzqTui4PMtmlxFkS83kyagKokSYNVgBnrS1quxCEyxSQXVZA2vCxWq6k0KclfS36CfREQLkF38uhgVYrtQeioPZAcBWWBW0AnwSnqC2OI96b0P5pDEOXpWKymEcPmu1VDYWpiwwZDZD'
  config.verify_token = 'ceskeretardy'
end

Facebook::Messenger::Subscriptions.subscribe
