require 'active_support/concern'

module Authentication
  extend ActiveSupport::Concern
  
  included do
    before_save { email.downcase! }

    has_secure_password
    validates :password, length: { minimum: 8, allow_blank: false }
  end
end