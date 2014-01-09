require 'spec_helper'

describe "<User pages>: " do
  subject { page }
  
  describe "Sign up page" do
    before { visit signup_path }
    
    let(:submit) { 'Create my account' }
    
    it { should have_content( 'Sign up' ) }
    it { should have_title( site_title( 'Sign Up' ) ) }
    
    describe "with empty form" do
      specify "submit should not create user" do
        expect{ click_button submit }.not_to change(User, :count)
      end
      
      describe "after submission" do
        before { click_button submit }
        
        specify "page should display errors" do
          expect(page).to have_content('error')
        end
      end
      
    end
    
    describe "with valid information" do
      let(:user) { FactoryGirl.build(:user) }
      before do
        fill_form({"Name" => user.name,
                   "Email" => (user.email + "x"), 
                   "Password" => user.password,
                   "Confirm Password" => user.password})
      end
      
      specify "submit should create user" do
        expect{click_button submit}.to change(User, :count).by(1)
      end
      
      describe "after submit" do
        before { click_button submit }
        
        specify "page should display welcome flash" do
          expect(page).to have_selector('div.alert.alert-success', text: 'Welcome')
        end
        
        specify "menu should include correct links" do
          expect(page).to have_link('Sign out', href: signout_path)
        end
      end
    end
  end
  
  describe "Profile page" do
    let (:user) { FactoryGirl.create(:user) }
    
    # generate 5 random posts
    let! (:posts) do 
      posts = []
      5.times do
        posts << FactoryGirl.create( :micropost,
                                     user: user,
                                     content: random_string( length: 8 ) )
      end
      posts
    end
    
    before { visit user_path(user) }
    
    it "should include the user's name in the title" do
      expect(page).to have_title(site_title(user.name, 'on'))
    end
    
    it "should include the user's name as a heading" do
      expect(page).to have_selector('h1', user.name)
    end
    
    describe "posts" do
      specify "should be displayed" do
        posts.each do |post|
          expect(page).to have_content(post.content)
        end
        expect(page).to have_content(user.microposts.count)
      end
    end
    
  end
  
  describe "Update profile page" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      start_session(user)
      visit edit_user_path(user)
    end
    
    it "should have the right title" do
      expect(page).to have_title(site_title("Profile Settings"))
    end
    
    it "should have the right heading" do
      expect(page).to have_selector('h2', text: 'Profile')
    end
    
    it "should link to Gravatar" do
      expect(page).to have_link('Change', href: 'http://gravatar.com/emails')
    end
    
    describe "submitted with invalid information" do
      before { click_button 'Save changes' }
      
      it 'should display an error' do
        expect(page).to have_selector('div.alert.alert-error')
      end
    end
    
    describe "with valid information" do
      let(:new_name) { 'New Name' }
      let(:new_email) { 'new@email.com' }
      before do
        fill_form({"Name" => new_name,
                   "Email" => new_email, 
                   "Password" => user.password,
                   "Confirm Password" => user.password})
        click_button "Save changes"
      end
      
      it "should redirect to the profile page" do
        expect(page).to have_title(site_title(new_name, 'on'))
        expect(page).to have_selector('div.alert.alert-success')
        expect(page).to have_link('Sign out', href: signout_path)
      end
      
      it "should make changes to the user's name and email" do
        user.reload
        expect(user.name).to eq new_name
        expect(user.email).to eq new_email
      end
      
    end
  end
  
  describe "User index page" do
    before do
      start_session FactoryGirl.create(:user)
      visit users_path
    end
    
    it "should have the right title and heading" do
      expect(page).to have_title(site_title('All Users', 'on'))
      expect(page).to have_selector('h2', text: 'All Users')
    end
    
    describe 'pagination' do
      before (:all) { 30.times { FactoryGirl.create(:user) } }
      after (:all) { User.delete_all }
      
      specify { expect(page).to have_selector('div.pagination') }
      
      it "should list the users" do
        User.paginate(page: 1).each do |user|
          expect(page).to have_selector('li', text: user.name)
        end
      end
    end

    describe 'user deletion' do
      specify{ expect(page).to_not have_link('delete') }
      
      describe 'as admin' do
        let (:admin) { FactoryGirl.create(:admin) }
        before do
          start_session admin
          visit users_path
        end
        
        it "should see delete links" do
          expect(page).to have_link("delete", href: user_path(User.first))
        end
        
        it "should be able to delete users" do
          expect do
            click_link 'delete', match: :first
          end.to change(User, :count).by(-1)
        end
        
        it "should not be able to delete self" do
          expect(page).to_not have_link('delete', href: user_path(admin))
        end
        
      end
    end
  end

  describe "following/followers" do
    let(:user) { FactoryGirl.create(:user) }
    let(:other_user) { FactoryGirl.create(:user) }
    before { user.follow!(other_user) }
    
    describe "followed users" do
      before do
       start_session user
       visit following_user_path(user) 
      end
      
      it "should land on the correct page" do
        expect(page).to have_title(site_title('Following'))
        expect(page).to have_selector('h3', text: 'Following')
      end
      
      it 'should contain links to users followed' do
        expect(page).to have_link(other_user.name, href: user_path(other_user))
      end
      
    end
    
    describe "followers" do
      before do
        start_session other_user
        visit followers_user_path(other_user)
      end
      
      it 'should land on the correct page' do
        expect(page).to have_title(site_title('Followers'))
        expect(page).to have_selector('h3', text: 'Followers')
      end
      
      it 'should contain links to users following' do
        expect(page).to have_link(user.name, href: user_path(user))
      end
      
    end
    
  end
  
end
