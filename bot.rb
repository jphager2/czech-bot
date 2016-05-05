require 'active_support/inflector'
require 'open-uri'

include Facebook::Messenger

puts "Bot Coming online"

module CzechBot
  extend ActiveSupport::Inflector

  def self.log(string)
    $stderr.puts(string)
  end

  def self.respond_to(message)
    case transliterate(message.text.to_s)
    when /domaci ukol/i
      LatestHomeworkResponse.new(message)
    else
      DefaultResponse.new(message)
    end
  end

  class DefaultResponse

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

  class LatestHomeworkResponse < DefaultResponse
    def text
      file = open('https://gist.githubusercontent.com/jphager2/dd316998b9988fcca00f1e3068165bc5/raw/2a12985b7b7ededce6f0a3f0c30244d58c80bc04/Homework')
      file.readline
    end
  end
end

Bot.on(:message) do |message|
  CzechBot.log "Got a message from: #{message.sender}"

  response = CzechBot.respond_to(message)

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
