class Share < ActiveRecord::Base

  mount_uploader :file, FileUploader

  belongs_to :user

  validates :file, :original_filename, presence: true
  validates :user, presence: true

  def filename
    self.file.to_s.split('/').last
  end

end
