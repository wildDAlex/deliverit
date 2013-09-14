json.array!(@shares) do |share|
  json.extract! share, :original_filename
  json.url share_url(share, format: :json)
end
