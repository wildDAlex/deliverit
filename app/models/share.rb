class Share < ActiveRecord::Base

  mount_uploader :file, FileUploader

  belongs_to :user

  validates :file, :original_filename, presence: true
  validates :user, presence: true

  def filename
    self.file.to_s.split('/').last
  end

  # Restrict filename to 50 symbols
  def short_original_filename
    self.original_filename.length > 50 ? self.original_filename[0...50] + '...' : self.original_filename
  end

end
