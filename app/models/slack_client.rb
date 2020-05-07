class SlackClient
  def self.notify(message)
    uri = URI.parse(ENV["SLACK_WEBHOOK_URL"])
    params = { text: message }
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.start do
      req = Net::HTTP::Post.new(uri.path)
      req.set_form_data(payload: params.to_json)
      http.request(req)
    end
  end
end
