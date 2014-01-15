require 'spec_helper'

describe "<AuthenticationPages>: " do
  subject { page }
  
  describe "Sign in page" do
    before { visit signin_path }
    
    it "should have the correct title" do
      expect(page).to have_title(site_title('Sign In'))
    end
    
    it "should have the appropriate heading" do
      expect(page).to have_selector('h1', 'Sign In')
    end
    
    describe "while authenticating" do
      let (:user) { FactoryGirl.create(:user) }
      let (:submit) { 'Sign in' }
      
      before { fill_in "Email", with: user.email }
      
      describe "before signing in" do
        it "should show the correct links in the menu" do
          expect(page).to have_link("Sign in", href: signin_path)
          expect(page).to_not have_link("Sign out", href: signout_path)
          expect(page).to_not have_link('Profile', href: user_path(user))
          expect(page).to_not have_link('Settings', href: edit_user_path(user))
          expect(page).to_not have_link('Users', href: users_path)
        end
      end
      
      describe "with valid login" do
        before do
          fill_in "Password", with: user.password
          click_button submit
        end
        
        it "should redirect to the user page" do
          expect(page).to have_title(site_title(user.name, 'on'))
        end
        
        it "should show the correct links in the menu" do
          expect(page).to have_link("Users", href: users_path)
          expect(page).to have_link("Profile", href: user_path(user))
          expect(page).to have_link("Settings", href: edit_user_path(user))
          expect(page).to have_link("Sign out", href: signout_path)
          expect(page).to_not have_link("Sign in", href: signin_path)
        end
        
        describe "followed by sign out" do
          before { click_link "Sign out" }
          
          it "should not have a current user" do
            expect(current_user).to be_nil
          end
          
          it "should display the sign in link" do
            expect(page).to have_link("Sign in", href: signin_path)
          end
        end
        
      end
      
      describe "with invalid login on submit" do
        before do
          fill_in "Password", with: "OMGWTFBBQ"
          click_button submit
        end
          
        it "should not create a new session" do
          expect(current_user).to be_nil
        end
      
        it "should show error message" do
          expect(page).to have_selector('div.alert.alert-error', 'Invalid')
        end
        
        describe "after visiting another page" do
          before { click_link "Home" }
          specify "the error should be cleared" do
            expect(page).to_not have_selector('div.alert.alert-error')
          end
        end
      end
      
    end # "while authenticating"
    
  end # "Sign in page"
  
  describe "authorization" do
    let(:user) { FactoryGirl.create :user }
    
    describe "for non signed-in users" do
      
      describe "when attempting to visit a protected page" do
        before do
          visit edit_user_path(user)
          start_session user
        end
        
        describe "after signing in" do
          it "should return the user to the protected page" do
            expect(page).to have_title(site_title('Profile Settings'))
          end
        end
      end
      
      describe "visiting the edit page" do
        before { get edit_user_path(user) }
        specify { expect(response).to redirect_to(signin_path) }
      end
      
      describe "updating user settings" do
        before { patch user_path(user) }
        specify { expect(response).to redirect_to(signin_path) }
      end
      
      describe "viewing the user index" do
        before { get users_path }
        specify { expect(response).to redirect_to(signin_path)}
      end
      
      describe "in the Microposts controller" do
        describe "submitting a POST request to Micropost#create action" do
          before { post microposts_path }
          specify { expect(response).to redirect_to(signin_path) }
        end
        
        describe "submitting a DELETE request to Micropost#destroy action" do
          before { delete micropost_path( FactoryGirl.create(:micropost) ) }
          specify { expect(response).to redirect_to(signin_path) }
        end
        
        describe "attempting to destroy another user's post" do
          let(:other_user) { FactoryGirl.create(:user) }
          let!(:others_post) { FactoryGirl.create(:micropost, user: other_user) }
          
          before do
            start_session user
            delete micropost_path(others_post)
          end
          
          it "should redirect to the home page" do
            expect(response).to redirect_to(root_url)
          end
        end
      end
      
      describe 'in the Relationships controller' do
        describe 'submitting to the create action' do
          before { post relationships_path }
          specify { expect(response).to redirect_to(signin_path) }
        end
        
        describe 'submitting to the destroy action' do
          before { delete relationship_path(1) }
          specify { expect(response).to redirect_to(signin_path) }
        end
      end
      
    end
    
    describe "deleting users" do
      let(:user) { FactoryGirl.create(:user) }
      
      describe "as non-admin user" do
        let(:non_admin) { FactoryGirl.create(:user) }
      
        before { start_session non_admin, no_capybara: true }
      
        describe 'submitting a DELETE request to User#destroy action' do
          before { delete user_path(user) }
          specify { expect(response).to redirect_to(root_url) }
        end
      end
      
      describe "as admin user" do
        let(:admin) { FactoryGirl.create(:admin) }
        
        before { start_session admin, no_capybara: true }
        
        describe 'submitting a DELETE request to User#destroy action' do
          before { delete user_path(admin) }
          specify { expect(response).to redirect_to(root_url) }
        end
      end    
    end
    
    describe "as the wrong user" do
      let(:other_user) { FactoryGirl.create(:user, email: 'other@example.com') }
      before { start_session user,{ no_capybara: true } }
      
      describe "submitting a GET request to edit action" do
        before { get edit_user_path(other_user) }
        specify { expect(response).to_not redirect_to(edit_user_path(other_user)) }
        specify { expect(response).to redirect_to(edit_user_path(user)) }
      end
      
      describe "submitting a PATCH request to update action" do
        before { patch user_path(other_user) }
        specify { expect(response).to redirect_to(root_url) }
      end
    end
  end

end
