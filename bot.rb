require 'active_support/inflector'
require 'open-uri'

include Facebook::Messenger

puts "Bot Coming online"

module CzechBot
  extend ActiveSupport::Inflector

  def self.log(string)
    $stderr.puts(string)
  end

  def self.respond_to_message(message)
    case transliterate(message.text.to_s)
    when /\bdomaci\b\s*ukol\b/i, /\bh(ome)?\b*\s*w(ork)\b/i
      LatestHomeworkResponse.new(message)
    when /\bslov/
      VocabResponse.new(message)
    else
      DefaultResponse.new(message)
    end
  end

  def self.respond_to_postback(postback)
    case postback.payload
    when "VOCAB_ALL"
      AllVocabResponse.new(postback)
    when "VOCAB_NEW"
      NewVocabResponse.new(postback)
    when "VOCAB_ONE"
      OneVocabResponse.new(postback)
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

    def message
      { text: text }
    end

    def deliver?
      message && !message.empty?
    end

    private
    def text
      "Ahoj!"
    end
  end

  class LatestHomeworkResponse < DefaultResponse
    private
    def text
      file = open('https://gist.githubusercontent.com/jphager2/dd316998b9988fcca00f1e3068165bc5/raw/2a12985b7b7ededce6f0a3f0c30244d58c80bc04/Homework')
      file.readline
    end
  end

  class VocabResponse < DefaultResponse
    def message
      { attachment: attachment }
    end

    private
    def attachment
      { type: 'template',
        payload: {
          template_type: 'button',
          text: '',
          buttons: [
            { type: 'postback', title: 'Všechno', payload: 'VOCAB_ALL' },
            { type: 'postback', title: 'Jedno', payload: 'VOCAB_ONE' },
            { type: 'postback', title: 'Nové', payload: 'VOCAB_NEW' }]}}
    end
  end

  class AllVocabResponse < DefaultResponse
    private
    def vocab_list
      [["cesta", "robot"], ["spisovatel"]]
    end

    def text
      vocab_list.flatten.map { |word| display_vocab(word) }.join("\n\n")
    end

    def display_vocab(word)
      word
    end
  end

  class NewVocabResponse < AllVocabResponse
    private
    def text
      vocab_list.first.map { |word| display_vocab(word) }.join("\n\n")
    end
  end

  class OneVocabResponse < AllVocabResponse
    private
    def new_vocab_word
      vocab_list.first.shuffle.first
    end

    def old_vocab_word
      vocab_list.drop(1).flatten.shuffle.first
    end

    def text
      if rand > 0.5
        word = old_vocab_word
      end

      word ||= new_vocab_word

      display_vocab(word)
    end
  end
end

Bot.on(:message) do |message|
  CzechBot.log "Got a message from: #{message.sender}"

  response = CzechBot.respond_to_message(message)

  if response.deliver?
    Bot.deliver(
      recipient: response.recipient,
      message: response.message
    )
  end

  CzechBot.log "Sending: #{response.message.inspect}, To: #{response.recipient}"
end

Bot.on(:postback) do |postback|
  CzechBot.log "Got a postback from: #{postback.sender}"

  response = CzechBot.respond_to_postback(postback)

  if response.deliver?
    Bot.deliver(
      recipient: response.recipient,
      message: response.message
    )
  end

  CzechBot.log "Sending: #{response.message.inspect}, To: #{response.recipient}"
end

Facebook::Messenger.configure do |config|
  config.access_token = 'EAAYqja1OZBYkBAAx3Dd2jcsvpAa2QUPHVNrzqTui4PMtmlxFkS83kyagKokSYNVgBnrS1quxCEyxSQXVZA2vCxWq6k0KclfS36CfREQLkF38uhgVYrtQeioPZAcBWWBW0AnwSnqC2OI96b0P5pDEOXpWKymEcPmu1VDYWpiwwZDZD'
  config.verify_token = 'ceskeretardy'
end

Facebook::Messenger::Subscriptions.subscribe
