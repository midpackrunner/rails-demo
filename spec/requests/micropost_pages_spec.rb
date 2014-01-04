require 'spec_helper'

describe "<MicropostPages> -" do
  let(:user) { FactoryGirl.create(:user) }
  before { start_session user }
  
  describe "micropost creation" do
    before { visit root_path }
    
    describe "with invalid content" do
      it "should not create a new post" do
        expect{ click_button "Post" }.to_not change(Micropost, :count)
      end
      
      describe "error messages" do
        before { click_button "Post" }
        
        it "should be displayed" do
          expect(page).to have_content("error")
        end
      end
    end

    describe "with valid content" do
      before { fill_in 'micropost_content', with: 'Lorem Ipsum' }
      
      it "should create a new post" do
        expect { click_button "Post" }.to change(Micropost, :count).by(1)
      end
    end # with valid content
    
  end # micropost creation
  
  describe "micropost destruction" do
    before { FactoryGirl.create(:micropost, user: user) }

    describe "as correct user" do
      before { visit root_path }

      it "should delete a micropost" do
        expect { click_link "delete" }.to change(Micropost, :count).by(-1)
      end
    end
  end
  
end # <MicropostPages>
