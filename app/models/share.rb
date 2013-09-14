class Share < ActiveRecord::Base

  mount_uploader :file, FileUploader

  belongs_to :user

end
