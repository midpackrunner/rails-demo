include ApplicationHelper
include SessionsHelper

def start_session(user, options={})
  if options[:no_capybara]
    remember_token = User.new_remember_token
    cookies[:remember_token] = remember_token
    user.update_attribute(:remember_token, User.encrypt(remember_token))
  else
    visit signin_path
    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    click_button "Sign in"
  end
end

def fill_form(options={})
  if options[:no_capybara].nil?
    options.each do |key, value|
      fill_in key, with: value
    end
  end
end

def random_string(options={})
  args = { length: 8 }.merge(options)
  length = (args[:length] % 26)
  
  ('a'..'z').to_a.shuffle[0, length].join 
end