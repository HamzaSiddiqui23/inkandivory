class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

    before_save :upload_resume
    before_validation :set_status
    belongs_to :team, optional: true
    has_many :client_tasks
    has_many :client_invoices
    has_many :internal_invoices

    
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :slack, presence: true
  
    scope :active, lambda { where(status: 'Active') }

    def is_manager?
      role == "Management"
    end

    def is_admin?
      role == "Admin"
    end

    def is_writer?
      role == "Individual Contributor"
    end

   def full_name
   		f_name = first_name + ' ' + last_name
    	f_name.titleize
   end

   def set_status
    self.status = "Active"
   end

   def upload_resume
   		if resume_file !=nil
   			session = GoogleDrive::Session.from_config("config.json")
   			file = session.upload_from_io(self.resume_file.to_io, full_name+"-resume", convert: true)
         baseFolder = session.collection_by_title("InkAIMS")
        if(is_admin?)
          adminFolder = baseFolder.subcollection_by_title("Admin")
          if adminFolder != nil
            afolder = adminFolder.subcollection_by_title(full_name)
            if afolder != nil
              afolder.add(file)
            else
              afolder = adminFolder.create_subcollection(full_name)
              folder.add(file)
            end
          else
            adminFolder = baseFolder.create_subcollection("Admin")
            afolder = adminFolder.create_subcollection(full_name)
            afolder.add(file)
          end
        else
          teamfolder = baseFolder.subcollection_by_title("Team "+team.team_name)
          if teamfolder != nil
            folder = teamfolder.subcollection_by_title(full_name)
            if folder != nil
              folder.add(file)
            else
              folder = teamfolder.create_subcollection(full_name)
              folder.add(file)
            end
          else
            teamfolder = session.baseFolder.create_subcollection("Team "+team.team_name)
            folder = teamfolder.create_subcollection(full_name)
            folder.add(file)
          end
        end
        self.resume = file.name
        self.resume_file = nil
      end
   end

  def get_resume
    session = GoogleDrive::Session.from_config("config.json")
    file = session.file_by_title(resume)
    file.human_url
    #send_file file, :disposition => 'attachment'
  end
end