class User < ActiveRecord::Base
  before_create :create_remember_token
  before_save { email.downcase! }
  
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
  
  has_secure_password
  validates :password, length: { minimum: 8, allow_blank: false }
  
  has_many :microposts, dependent: :destroy
  
  def gravatar_url
    "https://secure.gravatar.com/avatar/#{gravatar_id}"
  end
  
  def feed
    Micropost.where('user_id=?', id)
  end
  
  def User.new_remember_token
    SecureRandom.urlsafe_base64
  end
  
  def User.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s)
  end
  
private
    def gravatar_id
      Digest::MD5::hexdigest(self.email)
    end
  
    def create_remember_token
      self.remember_token = User.encrypt(User.new_remember_token)
    end
end
