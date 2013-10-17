class Share < ActiveRecord::Base

  mount_uploader :file, FileUploader
  before_save :update_file_attributes

  IMAGE_VERSIONS = ['thumb', 'medium']

  belongs_to :user

  validates :file, :original_filename, presence: true
  validates :user, presence: true

  #scope :images, where("content_type LIKE 'image%'")

  def filename
    self.file.to_s.split('/').last
  end

  # Restrict filename to 50 symbols
  def short_original_filename
    self.original_filename.length > 50 ? self.original_filename[0...50] + '...' : self.original_filename
  end

  def image?
    #MIME::Types.type_for(self.file.url).first.content_type.start_with? 'image'
    self.content_type.start_with? 'image'
  end

  def turn_publicity
    self.public ? false : true
  end

  # Filter by content type
  def self.type(shares, type)
    shares.where("content_type LIKE ?", "%#{type}%")
  end

  private

  def update_file_attributes
    if file.present? && file_changed?
      self.content_type = file.file.content_type
      self.file_size = file.file.size
    end
  end

end
