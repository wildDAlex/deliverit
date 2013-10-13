def login(user)
  visit root_path
  fill_in "user[email]", :with => user.email
  fill_in "user[password]", :with => user.password
  click_button "Sign in"
end

def signing_out
  visit root_path
  click_on "Sign out"
end

def within_row(text, &block)
  within :xpath, "//table//tr[contains(.,\"#{text}\")]" do
    yield
  end
end

def download_share_link(share, version = nil)
  "/download/#{version}#{"/" if !version.nil?}#{share.file.to_s.split('/').last}"
end