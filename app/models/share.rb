class Share < ActiveRecord::Base

  mount_uploader :file, FileUploader

end
