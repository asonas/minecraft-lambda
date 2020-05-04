require 'net/http'
require 'json'
class Instance
  INSTANCE_ID = "i-06166d9bef1a08ae0"

  def self.start
    new.start
  end

  def self.stop
    new.stop
  end

  def self.backup
  end

  def initialize
    client = Aws::EC2::Resource.new
    @instance = client.instance(INSTANCE_ID)
    unless @insatance.exists?
      raise "Do not exists instance: #{INSTANCE_ID}"
    end
  end

  def start
    case @instance.state.code
    when 0 # stopped
      "#{INSTANCE_ID} is pending, so it will be running in a bit"
    when 16 # started
      "#{INSTANCE_ID} is already started"
    when 48 # terminated
      "#{INSTANCE_ID} is terminated, so you cannot start it"
    else
      @instance.start

      count = 0
      while @instance.network_interfaces.first.data.association.nil? do
        ip_address = @instance.network_interfaces.first.data.association.public_ip
        if count > 20
          raise "Error"
        else
          cont += 1
          @instance.reload
          sleep 1
        end
      end
      "#{INSTANCE_ID} is started. IP Address is #{ip_address}"
    end
  end

  def stop
    case @instance.state.code
    when 48
      "#{INSTANCE_ID} is terminated, so you cannot stop it"
    when 64
      "#{INSTANCE_ID} is stopping, so will be stopped in a bit"
    when 89
      "#{INSTANCE_ID} is already stopped"
    else
      @instance.stop

      count = 0
      while true do
        if @instance.state.code == 89 || @instance.state.code == 48
          break
        else
          if count > 10
            raise "Error" # TODO
          else
            count += 1
            sleep
          end
        end
      end
      "#{INSTANCE_ID} has been stopped."
    end
  end
end

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
    Instance.start
  end

  def destroy
    notify_slack("destroy")
    Instance.start
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
