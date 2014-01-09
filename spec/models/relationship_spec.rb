require 'spec_helper'

describe Relationship do
  let(:follower) { FactoryGirl.create(:user) }
  let(:followed) { FactoryGirl.create(:user) }
  let(:relationship) { follower.relationships.build(followed_id: followed.id) }
  
  it "should be valid" do
    expect(relationship).to be_valid
  end
  
  it "should have to right properties" do
    expect(relationship).to respond_to(:follower)
    expect(relationship).to respond_to(:followed)
  end
  
  it "should properly assign follower and followed" do
    expect(relationship.follower).to eq follower
    expect(relationship.followed).to eq followed
  end
  
  describe "when follower is not present" do
    before { relationship.follower_id = nil }
    specify "relationship should be invalid" do
      expect(relationship).to be_invalid
    end
  end
  
  describe "when followed is not present" do
    before { relationship.followed_id = nil }
    specify "relationship should be invalid" do
      expect(relationship).to be_invalid
    end
  end
  
end
