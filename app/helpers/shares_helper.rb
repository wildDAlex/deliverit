module SharesHelper
  def download_share_link(share)
    "/download/#{share.file.to_s.split('/').last}"
  end
end
