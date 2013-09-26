def login(user)
  visit root_path
  fill_in "user[email]", :with => user.email
  fill_in "user[password]", :with => user.password
  click_button "Sign in"
end

def within_row(text, &block)
  within :xpath, "//table//tr[contains(.,\"#{text}\")]" do
    yield
  end
end