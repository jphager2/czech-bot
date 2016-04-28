class App

  attr_reader :params
  def call(env)
    request = Rack::Request.new(env)
    @params = request.params
    if request.post?
      status, body = post
    elsif request.get?
      status, body = get
    else
      status, body = [400, ""]
    end
    [status, {'Content-Type'=>'text/plain'}, StringIO.new(body)]
  end

  def get
    if subscribe? && token?
      return 200, params["hub.challenge"]
    else
      return 400, "Don't know that one..."
    end
  end

  def post
    return 200, params.inspect
  end

  private
  def subscribe?
    params["hub.mode"] == "subscribe"
  end

  def token?
    params["hub.verify_token"] == "token"
  end
end

run App.new
