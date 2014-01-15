require 'spec_helper'

describe RelationshipsController do
  let(:user) { FactoryGirl.create(:user) }
  let(:other) { FactoryGirl.create(:user) }
  
  before { start_session user, no_capybara: true }
  
  describe 'Ajax requests' do
    describe 'creating relationships' do
      it 'should add a new relationship' do
        expect do
          xhr :post, :create, relationship: { followed_id: other.id }
        end.to change(Relationship, :count).by(1)
      end
      
      it 'should respond with 200' do
        xhr :post, :create, relationship: { followed_id: other.id }
        expect(response).to be_success
      end
    end
    
    describe 'destroying relationships' do
      before { user.follow!(other) }
      let(:relationship) { user.relationships.find_by(followed_id: other) }
      
      it 'should remove an existing relationship' do
        expect do
          xhr :delete, :destroy, id: relationship.id
        end.to change(Relationship, :count).by(-1)
      end
      
      it 'should respond with 200' do
        xhr :delete, :destroy, id: relationship.id
        expect(response).to be_success
      end
    end
  end
end