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
    when /\bslov/i
      VocabResponse.new(message)
    else
      DefaultResponse.new(message)
    end
  end

  def self.respond_to_postback(postback)
    case postback.payload
    when /VOCAB_ALL/
      index = postback.payload.match(/#(\d+)/)
      response = AllVocabResponse.new(postback)
      response.index = index[1].to_i if index
      response
    when "VOCAB_NEW"
      NewVocabResponse.new(postback)
    when "VOCAB_ONE"
      OneVocabResponse.new(postback)
    end
  end

  def self.user_data(person)
    id = person["id"]
    UserData.fetch(id)
  end

  class UserData
    include HTTParty

    base_uri Bot.base_uri.sub(/\/me$/, '')

    FIELDS = %i{ first_name last_name profile_pic locale timezone gender }

    def self.fetch(id)
      query = Bot.default_options[:query].merge(fields: FIELDS.join(","))
      response = get "/#{id}", query: query, format: :json

      CzechBot.log("Got data for user: #{id}, data: #{response.inspect}")

      new(response)
    end

    attr_reader *FIELDS

    def initialize(data)
      @first_name = data["first_name"]
      @last_name = data["last_name"]
      @profile_pic = data["profile_pic"]
      @locale = data["locale"]
      @timezone = data["timezone"]
      @gender = data["gender"]
    end
  end

  class DefaultResponse

    attr_reader :sender
    def initialize(message)
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

    def user
      @user ||= CzechBot.user_data(sender)
    end

    private
    def text
      "Ahoj, #{user.first_name}!"
    end
  end

  class LatestHomeworkResponse < DefaultResponse
    private
    def text
      file = open('https://gist.githubusercontent.com/jphager2/2654911ba1ddf3eef28a403ad9b3f563/raw/Homework')
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
          text: 'Co se chceš učit?',
          buttons: [
            { type: 'postback', title: 'Všechno', payload: 'VOCAB_ALL' },
            { type: 'postback', title: 'Jedno', payload: 'VOCAB_ONE' },
            { type: 'postback', title: 'Nové', payload: 'VOCAB_NEW' }]}}
    end
  end

  module VocabList
    def vocab_list
      @vocab_list ||= fetch_vocab_list
    end

    def fetch_vocab_list
      file = open('https://gist.githubusercontent.com/jphager2/2654911ba1ddf3eef28a403ad9b3f563/raw/Vocabulary')
      file.each_line.to_a
    end

    def words_at(index_or_range)
      lines = Array(vocab_list[index_or_range])
      lines.map { |line| line.strip.split("|") }.flatten
    end

    def display_at(i)
      words_at(i).map { |word| display_vocab(word) }.join("\n\n")
    end

    def display_vocab(word)
      word
    end
  end

  class AllVocabResponse < DefaultResponse
    include VocabList

    attr_writer :index

    def message
      { attachment: attachment }
    end

    def deliver?
      vocab_list[index]
    end

    private
    def index
      @index || 0
    end

    def attachment
      { type: 'template',
        payload: {
          template_type: 'button',
          text: text,
          buttons: [{ 
            type: 'postback', 
            title: 'Další', 
            payload: "VOCAB_ALL##{index + 1}" }]}}
    end

    def text
      display_at(index)
    end
  end

  class NewVocabResponse < DefaultResponse
    include VocabList

    private
    def text
      display_at(0)
    end
  end

  class OneVocabResponse < DefaultResponse
    include VocabList

    private
    def new_vocab_word
      words_at(0).shuffle.first
    end

    def old_vocab_word
      words_at(1..-1).shuffle.first
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
