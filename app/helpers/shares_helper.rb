module SharesHelper
  def download_share_link(share)
    "/download/#{share.file.to_s.split('/').last}"
  end

  def download_share_absolute_link(share)
    port = request.port ? ":"+request.port.to_s : nil
    "http://#{request.host}#{port}/download/#{share.file.to_s.split('/').last}"
  end
end
