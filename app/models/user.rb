# encoding: utf-8
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, #:registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable, :lockable

  has_many :shares, dependent: :destroy

  def admin?      # User with id=1 is Admin. Temp solution.
    self.id == 1 ? true : false
  end

  def registered?
    self.confirmed_at
  end

  def upload_from_local_path(public: true)
    upload_path = APP_CONFIG[:local_upload_path]+"/#{self.id}"
    Dir.chdir(upload_path)
    count = 0
    Dir.foreach(upload_path) do |file|
      if File.ftype(file) == "file"
        begin
          share = Share.new
          share.file = File.open(file)
          share.user = self
          share.public = public
          share.created_at = File.mtime(file)
          share.save
          count += 1
        rescue => ex
          puts "#{ex.class}: #{ex.message}"
        else
          File.delete(file)
        end
      end
    end
    count
  end

end
