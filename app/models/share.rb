class Share < ActiveRecord::Base

  mount_uploader :file, FileUploader

  belongs_to :user

  validates :file, :original_filename, :presence => true

end
