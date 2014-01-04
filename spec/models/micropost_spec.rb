require 'spec_helper'

describe Micropost do
  let(:user) { FactoryGirl.create(:user) }
  
  before do
    @micropost = user.microposts.build(content: "Lorem Ipsum")
  end
  
  it "should have the expected attributes" do
    expect(@micropost).to respond_to(:content)
    expect(@micropost).to respond_to(:user_id)
    expect(@micropost).to respond_to(:user)
    expect(@micropost.user).to eq user
  end
  
  specify "current micropost should be valid" do
    expect(@micropost).to be_valid
  end
  
  ###
  # basic validations
  describe "when :user_id is not present" do
    before { @micropost.user_id = nil }
    
    it "should be invalid" do
      expect(@micropost).to be_invalid
    end
  end
  
  describe "when :content is empty" do
    before { @micropost.content = "  " }
    
    it "should be invalid" do
      expect(@micropost).to be_invalid
    end
  end
  
  describe "when microposts are too long" do
    before { @micropost.content = 'a'*141 }
    it "should be invalid" do
      expect(@micropost).to be_invalid
    end
  end
  # / basic validations
  ###
  
end
