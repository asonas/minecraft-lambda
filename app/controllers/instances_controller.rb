require 'net/http'
require 'json'
class InstancesController < ApplicationController
  def create
    notify_slack

    # instance_id
    # execute shell
    # return ip_address
    #
    render plain: :ok
  end

  def notify_slack
    p ENV["SLACK_WEBHOOK_URL"]
    uri = URI.parse(ENV["SLACK_WEBHOOK_URL"])
    params = { text: "test from lambda" }
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.start do
      req = Net::HTTP::Post.new(uri.path)
      req.set_form_data(payload: params.to_json)
      http.request(req)
    end
  end
end
