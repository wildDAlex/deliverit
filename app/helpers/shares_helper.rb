module SharesHelper
  def download_share_link(share, version = nil)
    "/download/#{version}#{"/" if !version.nil?}#{share.file.to_s.split('/').last}"
  end

  def download_share_absolute_link(share, version = nil)
    port = request.port ? ":"+request.port.to_s : nil
    "http://#{request.host}#{port}/download/#{version}#{"/" if !version.nil?}#{share.file.to_s.split('/').last}"
  end

  def image_in_img_tag(share)
    "[IMG]#{download_share_absolute_link(share)}[/IMG]"
  end

  def preview_with_link(share)
    "[URL=#{download_share_absolute_link(share)}][IMG]#{download_share_absolute_link(share, :medium)}[/IMG][/URL]"
  end

  def html_inline_link(share)
    "<a target='_blank' href=#{share_url(share)}><img src=#{download_share_absolute_link(share)} border='0'></a>"
  end

  def html_inline_with_full_link(share)
    "<a href='#{download_share_absolute_link(share)}' target='_blank'><img src='#{download_share_absolute_link(share, :medium)}' border='0'></a>"
  end
end
