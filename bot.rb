include Facebook::Messenger

Facebook::Messenger.configure do |config|
  config.access_token = 'EAAJmZAsyf5M8BAJzDyBu6KKI5X3VARSP5VARSNnyfPxFOWDnulZCL2AM71CBzXQ3snD69ZAZC1AXZBLY7SVHHWuYq9cFYTg1yWMoZAHBoi0H4OBQBtgjgSYFf5bqN7eFAGaglQpZAWV2u96XCV6eC6GUEkzriy56TmvTrQ63jgHlwZDZD'
  config.verify_token = 'snapekillsdumbledore'
end

Facebook::Messenger::Subscriptions.subscribe
