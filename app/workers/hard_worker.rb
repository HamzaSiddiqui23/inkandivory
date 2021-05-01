class HardWorker
  include Sidekiq::Worker

  def perform(type, task_id, task_title)
    Slack.configure do |config|
      config.token = ENV['SLACK_TOKEN']
      raise 'Missing ENV[SLACK_TOKEN]!' unless config.token
    end
    client = Slack::Web::Client.new
    client.auth_test
    u = writer
    m = User.find(u.manager_id)
    t = ClientTask.find(task_id)
    if t.status == "In Progress" || t.status == "In Review"
      case type
      when "6 hours"
        client.chat_postMessage(channel: u.slack_id, text: "/n :bell: Deadline in 6 hours for task <http://127.0.0.1:3000/admin/client_tasks/#{task_id}|#{task_title}>! :clock6: /n") 
      when "1 hour"
        client.chat_postMessage(channel: u.slack_id, text: "/n :bell: Deadline in 1 hours for task <http://127.0.0.1:3000/admin/client_tasks/#{task_id}|#{task_title}>! :clock1: /n")
        client.chat_postMessage(channel: m.slack_id, text: "/n :bell: Deadline in 1 hours for task <http://127.0.0.1:3000/admin/client_tasks/#{task_id}|#{task_title}>! :clock1: /n") 
      when "10 mins"
        client.chat_postMessage(channel: u.slack_id, text: "/n :bell: Deadline in 10 minutes for task <http://127.0.0.1:3000/admin/client_tasks/#{task_id}|#{task_title}>! :clock12: /n")
        client.chat_postMessage(channel: m.slack_id, text: "/n :bell: Deadline in 10 minutes for task <http://127.0.0.1:3000/admin/client_tasks/#{task_id}|#{task_title}>! :clock12: /n") 
    end
  end
end