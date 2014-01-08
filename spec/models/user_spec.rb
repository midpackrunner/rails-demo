require 'spec_helper'

describe User do
  before do
    @user = User.new(name: 'Jon Doe', 
                     email: 'jdoe@example.com',
                     password: 'foobarbaz',
                     password_confirmation: 'foobarbaz')
  end
  
  subject { @user }
  it { should be_valid }
  it { should_not be_admin }
  
  describe "validates :name -" do
    it { should respond_to(:name) }
    
    describe 'when :name is not present' do
      before { @user.name = ' ' }
      it "user should be invalid" do
        expect(@user).to_not be_valid
      end
    end
  
    describe 'when :name is too long' do
      before { @user.name = 'a' * 51 }
      it "user should be invalid" do
        expect(@user).to_not be_valid
      end
    end
  end
  
  describe "validates :email -" do
    it { should respond_to(:email) }
      
    describe 'when :email is not present' do
      before { @user.email = ' ' }
    
      it "user should be invalid" do
        expect(@user).to_not be_valid
      end
    end
  
    describe "when email format is invalid" do
      it "user should be invalid" do
        addresses = %w[user@foo,com user_at_foo.org example.user@foo.
                       foo@bar_baz.com foo@bar+baz.com foo@bar..com]
        addresses.each do |invalid_address|
          @user.email = invalid_address
          expect(@user).not_to be_valid
        end
      end
    end

    describe "when email format is valid" do
      it "user should be valid" do
        addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
        addresses.each do |valid_address|
          @user.email = valid_address
          expect(@user).to be_valid
        end
      end
    end
    
    describe "when email address is already in use" do
      before do
        duplicate_user = @user.dup
        duplicate_user.email.upcase! # test also for case insensitivity
        duplicate_user.save
      end
      
      it "user should be invalid" do
        expect(@user).to_not be_valid
      end
    end
    
    describe "when email address is mixed case" do
      let(:mixed_case_email) { "MixedCAse@Email.com" }
      before do
        @user.email = mixed_case_email
        @user.save
      end
      
      specify "address should be downcased before saving" do
        expect(@user.reload.email).to eq mixed_case_email.downcase
      end
    end
  end
  
  describe "session persistance" do
    before { @user.save }
    
    it { should respond_to(:remember_token)}
    it "should have a remember token" do
      expect(@user.remember_token).to_not be_blank
    end
  end
  
  describe "administrative priviledges" do
    before do
       @user.save
       @user.toggle! :admin
    end
    
    it { should respond_to(:admin) }
    it { should be_admin }
    
  end
  
  ##
  # NB:
  # The following tests feel like testing the validity of the rails core 'has_secure_password' machinery.
  # They are included for completeness, but should be strongly considered for removal.
  ##
  describe "validates password -" do
    it { should respond_to(:password_digest) }
    it { should respond_to(:password) }
    it { should respond_to(:password_confirmation) }
    
    describe "when password is too short" do
      before { @user.password = @user.password_confirmation = 'short' }
      it "user should not be valid" do
        expect(@user).to_not be_valid
      end
    end
    
    describe "when password is not present" do
      before do
        @user.password = @user.password_confirmation = ' '
      end
      
      it "user should not be valid" do
        expect(@user).to_not be_valid
      end
    end
    
    describe "when password and confirmation don't match" do
      before do
        @user.password_confirmation = 'someotherpassword'
      end
      
      it "user should not be valid" do
        expect(@user).to_not be_valid
      end
    end
  end
  
  describe "authenticates -" do
    it { should respond_to(:authenticate) }
    
    describe "return value of authenticate method" do
      before { @user.save }
      let(:found_user) { User.find_by_email(@user.email) }
      
      it ", when given the correct password, should be our current user" do
        expect(@user).to eq found_user.authenticate(@user.password)
      end
      
      describe ", when given the incorrect password, " do
        let(:invalid_user) { found_user.authenticate('bunkpassword') }
        it "should be false" do
          expect(invalid_user).to be_false
        end
        
        it "should not be our current user" do
          expect(@user).to_not eq invalid_user
        end
      end
      
    end
  end

  describe "microposts -" do
    it "should be associated with microposts" do
      expect(@user).to respond_to(:microposts)
    end
    
    it "should have a feed of microposts" do
      expect(@user).to respond_to(:feed)
    end
    
    describe "associations" do
      before { @user.save }
      let!(:older_post) { FactoryGirl.create(:micropost, user: @user, created_at: 1.day.ago) }
      let!(:newer_post) { FactoryGirl.create(:micropost, user: @user, created_at: 1.hour.ago) }
      
      it "should be ordered by ascending recency" do
        expect(@user.microposts.to_a).to eq [newer_post, older_post]
      end
      
      it "should destroy user posts when user is destroyed" do
        posts = @user.microposts.to_a
        @user.destroy
        expect(posts).to_not be_empty
        posts.each do |post|
          expect do
            Micropost.find(post)
          end.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
      
      describe "status" do
        let(:unfollowed_post) do 
          FactoryGirl.create(:micropost, 
                             user: FactoryGirl.create(:user),
                             content: 'noseeum')
        end
        
        specify 'feed should only include posts from current/followed users' do
          expect(@user.feed).to include(older_post)
          expect(@user.feed).to include(newer_post)
          expect(@user.feed).to_not include(unfollowed_post)
        end
        
      end
      
    end
  end

  describe "relationships -" do
    it "should have the appropriate attributes and methods" do
      expect(@user).to respond_to(:relationships)
      expect(@user).to respond_to(:followed_users)
      expect(@user).to respond_to(:following?)
      expect(@user).to respond_to(:follow!)
      expect(@user).to respond_to(:unfollow!)
      expect(@user).to respond_to(:reverse_relationships)
      expect(@user).to respond_to(:followers)
    end
    
    describe "following" do
      let(:other_user) { FactoryGirl.create(:user) }
      before do
        @user.save
        @user.follow!(other_user)
      end
      
      it "should include followed user in current user's group of followed users" do
        expect(@user).to be_following(other_user)
        expect(@user.followed_users).to include(other_user)
        expect(other_user.followers).to include(@user)
      end
      
      describe "and unfollowing" do
        before { @user.unfollow!(other_user) }
        
        it "should remove other user from the current user's followed list" do
          expect(@user).to_not be_following(other_user)
          expect(@user.followed_users).to_not include(other_user)
          expect(other_user.followers).to_not include(@user)
        end
      end
      
    end
    
    describe "associations" do
      before do
        @follower = FactoryGirl.create(:user)
        @followed = FactoryGirl.create(:user)
        @follower.relationships.create(followed_id: @followed.id)
      end
      
      it "should destroy relationships when following users are destroyed" do
        relationships = @follower.relationships.to_a
        @follower.destroy
        expect(relationships).to_not be_empty
        relationships.each do |r|
          expect do
            Relationship.find(r)
          end.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      it "should destroy relationships when followed users are destroyed" do
        relationships = @follower.relationships.to_a
        @followed.destroy
        expect(relationships).to_not be_empty
        relationships.each do |r|
          expect do
            Relationship.find(r)
          end.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
      
    end
  end
  
end
