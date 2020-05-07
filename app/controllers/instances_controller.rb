require 'net/http'
require 'json'

class InstancesController < ApplicationController
  def index
    case params["text"]
    when "create"
      SlackClient.notify ":robot_face: Creating server... :sunrise:"
      InstanceHandlerJob.perform_later(:create)
    when "destroy"
      SlackClient.notify ":robot_face: Shutdown server... :wave:"
      InstanceHandlerJob.perform_later(:destroy)
    when "upload"
      upload
    end
    render plain: :ok
  end
end
