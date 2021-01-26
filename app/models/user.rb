class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

    before_validation :upload_resume, :set_status
    belongs_to :team

    
  validates :first_name, presence: true
  validates :last_name, presence: true
  
    scope :active, lambda { where(status: 'Active') }

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
        teamfolder = session.collection_by_title("Team "+team.team_name)
        if teamfolder != nil
          folder = teamfolder.subcollection_by_title(full_name)
          if folder != nil
            folder.add(file)
          else
            folder = teamfolder.create_subcollection(full_name)
            folder.add(file)
          end
        else
          teamfolder = session.root_collection.create_subcollection("Team "+team.team_name)
          folder = teamfolder.create_subcollection(full_name)
          folder.add(file)
        end
        self.resume = file.name
        self.resume_file = nil
      end
   end

  def get_resume
    session = GoogleDrive::Session.from_config("config.json")
    file = session.file_by_title(resume)
    file.human_url
  end
end