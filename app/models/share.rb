class Share < ActiveRecord::Base

  mount_uploader :file, FileUploader
  before_save :update_file_attributes
  before_save :set_automatic_tags

  IMAGE_VERSIONS = ['thumb', 'medium']
  IMAGE_VERSIONS_TO_BE_COUNT = ['medium'] # except full version that count by default

  belongs_to :user
  has_many :taggings
  has_many :tags, through: :taggings

  validates :file, :original_filename, presence: true
  validates :user, presence: true

  scope :images, -> { where("content_type LIKE '%image%' and content_type NOT LIKE '%tiff%'") }
  scope :tagged_with, ->(name, user) { Tag.owned_by(user).find_by_name!(name).shares }
  scope :owned_by, ->(user) { where(user_id: user.id) }

  # Deletes file with share
  before_destroy do
    remove_file!
  end

  #scope :images, where("content_type LIKE 'image%'")

  # Using in specs only
  def filename
    self.file.to_s.split('/').last
  end

  # Restrict filename to 50 symbols
  def short_original_filename(size=50)
    self.original_filename.length > size ? self.original_filename[0...size] + '...' : self.original_filename
  end

  def image?
    #MIME::Types.type_for(self.file.url).first.content_type.start_with? 'image'
    self.content_type.start_with? 'image' and not self.content_type.end_with? 'tiff'   #Tiff files are not processible
  end

  def turn_publicity
    self.public ? false : true
  end

  def self.tag_counts
    Tag.select("tags.*, count(taggings.tag_id) as count").
        joins(:taggings).group("taggings.tag_id")
  end

  def tag_list
    tags.map(&:name).join(", ")
  end

  def tag_list=(names)
    if names.empty?
      self.tags.clear
      return
    end

    tags = names.split(",").uniq.map do |n|
      Tag.where(name: n.strip, user: self.user).first_or_create! unless n.strip.empty?
    end
    self.tags = tags.compact.uniq

  end

  def file_icon_class
    self.content_type.gsub('.','_').split('/').last
  end

  private

  def update_file_attributes
    if file.present? && file_changed?
      self.content_type = file.file.content_type
      self.file_size = file.file.size
    end
  end

  def set_automatic_tags
    if self.image? and not self.tags.include?(Tag.where(name: "images", user: self.user).first_or_create!)
      self.tags << Tag.where(name: "images", user: self.user).first
    end
    if self.original_filename.downcase.include?("screenshot_") and not self.tags.include?(Tag.where(name: "screenshot", user: self.user).first_or_create!)
      self.tags << Tag.where(name: "screenshot", user: self.user).first
    end
  end

end
