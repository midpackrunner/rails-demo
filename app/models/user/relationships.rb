require 'active_support/concern'

module Relationships
  extend ActiveSupport::Concern
  
  included do
    has_many :relationships, foreign_key: "follower_id", dependent: :destroy
    has_many :reverse_relationships, foreign_key: "followed_id", class_name: 'Relationship', dependent: :destroy
    has_many :followed_users, through: :relationships, source: :followed
    has_many :followers, through: :reverse_relationships, source: :follower
  end
  
  def following?(user)
    relationships.find_by_followed_id(user.id)
  end
  
  def follow!(user)
    relationships.create!(followed_id: user.id)
  end
  
  def unfollow!(user)
    relationships.find_by_followed_id(user.id).destroy!
  end
  
end