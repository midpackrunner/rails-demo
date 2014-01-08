require 'active_support/concern'

module SessionManagement
  extend ActiveSupport::Concern

  included do
    before_create :create_remember_token
  end

  private
      def create_remember_token
        self.remember_token = self.class.encrypt(self.class.new_remember_token)
      end

  module ClassMethods
   def new_remember_token
      SecureRandom.urlsafe_base64
    end

    def encrypt(token)
      Digest::SHA1.hexdigest(token.to_s)
    end
  end
end