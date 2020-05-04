require 'net/http'
require 'json'
class InstancesController < ApplicationController
  def index
    p params
    case params["text"]
    when "create"
      create
    when "destroy"
      destroy
    when "upload"
      upload
    end
    render plain: :ok
  end

  def create
    notify_slack("create")
    # instance_id
    # execute shell
    # return ip_address
    #
  end

  def destroy
    notify_slack("destroy")
  end

  def notify_slack(message)
    p ENV["SLACK_WEBHOOK_URL"]
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
