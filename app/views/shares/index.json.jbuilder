json.array!(@shares) do |share|
  json.extract! share, :description
  json.url share_url(share, format: :json)
end
