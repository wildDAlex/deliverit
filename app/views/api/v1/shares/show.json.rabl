object @share
attributes :id, :created_at, :updated_at, :original_filename, :public, :file_size, :content_type, :download_count, :tag_list
child :file => :file do
  attributes :url
  node(:url) { |share| download_share_absolute_link(share) }

  child :thumb => :thumb do
    node(:url) { |share| download_share_absolute_link(share, :thumb) }
  end

  child :medium => :medium do
    node(:url) { |share| download_share_absolute_link(share, :medium) }
  end
end