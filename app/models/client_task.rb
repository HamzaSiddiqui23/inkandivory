require 'slack-ruby-client'
class ClientTask < ApplicationRecord 
    after_commit :upload_instructions_file, :upload_submission_file
    before_update :status_change_notifier
  	before_create :set_pending
    before_validation :set_team
    after_commit :send_assigned_notification, :schedule_deadline_notifications

    belongs_to :client
    belongs_to :team
    belongs_to :writer, class_name: 'User', foreign_key: 'writer_id'

  	validates :writer, presence: true
  	validates :task_title, presence: true
  	validates :client_id, presence: true
  	validates :required_word_count, presence: true
  	validates :pay_rate, presence: true
  	validates :due_date_time, presence: true
    validate :due_date_validate

    scope :in_progress, lambda { where.not(status: ['Approved', 'Rejected', 'Rejected With Pay'])}
    scope :invoice_client, lambda { where(client_payment_status: 'Due', status: "Approved") }
    scope :invoice_writer, lambda { where(writer_payment_status: 'Due', status: ["Approved", "Rejected With Pay"]) }
    scope :invoice_manager, lambda { where(manager_payment_status: 'Due', status: "Approved") }
    scope :my_active_tasks, lambda { where(writer: current_user.id).and(where.not(status: ['Approved', 'Rejected', 'Rejected With Pay']))}
    scope :all_my_tasks, lambda { where(writer: current_user.id).and(where.not(status: ['Approved', 'Rejected', 'Rejected With Pay']))}

    def due_date_validate
      if due_date_time.nil? || due_date_time < Date.current
        errors.add("Due Date Time", "is invalid.")
      end
    end

    def schedule_deadline_notifications
      HardWorker.perform_at(due_date_time - 6.hours, id, task_title)
      HardWorker.perform_at(due_date_time - 1.hours, id, task_title)
      HardWorker.perform_at(due_date_time - 10.minutes, id, task_title)
    end

    def status_change_notifier
      if status_was != status
        Slack.configure do |config|
          config.token = ENV['SLACK_TOKEN']
          raise 'Missing ENV[SLACK_TOKEN]!' unless config.token
        end
        client = Slack::Web::Client.new
        client.auth_test
        u = writer
        m = User.find(u.manager_id)
        case status
        when "Approved"
          client.chat_postMessage(channel: u.slack_id, text: "\n :bell: Your task  <http://127.0.0.1:3000/admin/client_tasks/#{id}|#{task_title}> has been Approved! :tada: \n")    
        when "Rejected"
          client.chat_postMessage(channel: u.slack_id, text: "\n :bell: Your task  <http://127.0.0.1:3000/admin/client_tasks/#{id}|#{task_title}> has been Rejected! :x: \n")
        when "Pending Manager Approval"
          client.chat_postMessage(channel: m.slack_id, text: "\n :bell: The task  <http://127.0.0.1:3000/admin/client_tasks/#{id}|#{task_title}> has been submitted and is pending your approval, please take a look! :clock1: \n")
        when "In Revision"
          client.chat_postMessage(channel: u.slack_id, text: "\n:bell: You have been asked to do a revision for the task  <http://127.0.0.1:3000/admin/client_tasks/#{id}|#{task_title}> :writing_hand: \n")
          when "In Progress"
            client.chat_postMessage(channel: m.slack_id, text: "\n:bell: #{u.full_name} has started working on the task  <http://127.0.0.1:3000/admin/client_tasks/#{id}|#{task_title}> :writing_hand: :tada: \n")  
          when "Rejected with Pay"
          client.chat_postMessage(channel: u.slack_id, text: "\n:bell: Your task  <http://127.0.0.1:3000/admin/client_tasks/#{id}|#{task_title}> has been Rejected With Pay! :x: :tada: \n")
        end
      end
    end
    
    def set_team
      self.team_id = writer.team.id
    end
    
    def send_assigned_notification
      Slack.configure do |config|
        config.token = ENV['SLACK_TOKEN']
        raise 'Missing ENV[SLACK_TOKEN]!' unless config.token
      end
      
      client = Slack::Web::Client.new

      client.auth_test
      u = writer
      client.chat_postMessage(channel: u.slack_id, text: ':bell: A new task has been assigned to you and is due on *'+due_date_time.to_s + "* \n Task Link: <http://127.0.0.1:3000/admin/client_tasks/#{id}|#{task_title}> \n")
    end

  	def set_pending
  		self.status = 'Pending'
      self.client_payment_status  = "Due"
      self.writer_payment_status  = "Due"
      self.manager_payment_status  = "Due"
  	end

  	def upload_instructions_file
   		if instructions_file !=nil
   			session = GoogleDrive::Session.from_config("config.json")
   			file = session.upload_from_io(self.instructions_file.to_io, "Instructions-"+task_title, convert: true)
        baseFolder = session.collection_by_title("InkAIMS")
        teamfolder = baseFolder.subcollection_by_title("Team "+ writer.team.team_name)
        if teamfolder != nil
          folder = teamfolder.subcollection_by_title( writer.full_name)
          if folder != nil
            folder.add(file)
          else
            folder = teamfolder.create_subcollection(writer.full_name)
            folder.add(file)
          end
        else
          teamfolder = baseFolder.create_subcollection("Team "+ writer.team.team_name)
          folder = teamfolder.create_subcollection(writer.full_name)
          folder.add(file)
        end
        self.instructions = file.name
        self.instructions_file = nil
      end
   end

    def upload_submission_file
   		if submission_file !=nil
   			session = GoogleDrive::Session.from_config("config.json")
         baseFolder = session.subcollection_by_title("InkAIMS")
   			self.revision_number = self.revision_number + 1
   			file = session.upload_from_io(self.submission_file.to_io, task_title+"-v"+revision_number.to_s, convert: true)
        teamfolder = baseFolder.collection_by_title("Team "+ writer.team.team_name)
        if teamfolder != nil
          folder = teamfolder.subcollection_by_title(writer.full_name)
          if folder != nil
            folder.add(file)
          else
            folder = teamfolder.create_subcollection(writer.full_name)
            folder.add(file)
          end
        else
          teamfolder = baseFolder.create_subcollection("Team "+writer.team.team_name)
          folder = teamfolder.create_subcollection(writer.full_name)
          folder.add(file)
        end
        self.submission = file.name
        self.submission_file = nil
        self.set_submitted()
      end
   	end

   	def get_instructions
    	session = GoogleDrive::Session.from_config("config.json")
    	file = session.file_by_title(instructions)
    	file.human_url
  	end
  
    def get_submission
    	session = GoogleDrive::Session.from_config("config.json")
    	file = session.file_by_title(submission)
    	file.human_url
  	end

    def set_submitted
      self.status = 'Pending Manager Approval'
      if revision_due_date.nil?
        self.task_submitted_date_stamp = DateTime.now
      else
        self.revision_submission_date = DateTime.now
      end
      self.client_payment_due = submitted_word_count * pay_rate
      self.payment_type = "Submitted Word Count"
      self.writer_payment_due = required_word_count * 0.5
      self.manager_payment_due = (client_payment_due - writer_payment_due) * 0.5
    end

end