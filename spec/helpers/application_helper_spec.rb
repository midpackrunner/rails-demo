require 'spec_helper'

describe ApplicationHelper do
  
  describe 'site_title' do
    it 'should include the page title' do
      expect( site_title('foo') ).to match(/foo/)
    end
    
    it 'should always include the base title' do
      expect( site_title('foo') ).to match(/Rails Demo$/)
    end
    
    it 'should not include the separator in unnamed pages' do
      expect( site_title('') ).not_to match(/\|/)
    end
    
    describe 'with a custom separator' do
      let(:separator) { '@@' }
      let(:new_title) { site_title('foo', separator) }
      
      it 'should include the new separator' do
        expect(new_title).to match(/\@\@/)
      end
      
      it 'should not include the pipe separator' do
        expect(new_title).not_to match(/\|/)
      end
    end
  end
  
end