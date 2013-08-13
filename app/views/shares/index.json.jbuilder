json.array!(@shares) do |share|
  json.extract! share, :title
  json.url share_url(share, format: :json)
end
