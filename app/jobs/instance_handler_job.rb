class InstanceHandlerJob < ApplicationJob
  iam_policy "lambda"
  def create
    m = Instance.start
    SlackClient.notify(m)
  end

  iam_policy "lambda"
  def destroy
    m = Instance.stop
    SlackClient.notify(m)
  end
end
