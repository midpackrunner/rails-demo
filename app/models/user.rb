require 'user/authentication'
require 'user/session_management'
require 'user/relationships'

class User < ActiveRecord::Base
  validates :name, presence: true, length: { maximum: 50 }
   VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
   validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }

  include Authentication
  include SessionManagement
  include Relationships

  has_many :microposts, dependent: :destroy

  def gravatar_url
    "https://secure.gravatar.com/avatar/#{gravatar_id}"
  end

  def feed
    Micropost.from_users_followed_by(self)
  end

private
    def gravatar_id
      Digest::MD5::hexdigest(self.email)
    end
end
