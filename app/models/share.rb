class Share < ActiveRecord::Base

  mount_uploader :attachment, AttachmentUploader

end
