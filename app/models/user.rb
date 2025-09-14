class User < ApplicationRecord
  # Following relationships
  has_many :following_relationships, class_name: 'UserFollowing', foreign_key: 'follower_id', dependent: :destroy
  has_many :follower_relationships, class_name: 'UserFollowing', foreign_key: 'followed_id', dependent: :destroy
  has_many :following, through: :following_relationships, source: :followed
  has_many :followers, through: :follower_relationships, source: :follower

  # Sleep records relationship
  has_many :sleep_records, dependent: :destroy

  # Validations
  validates :name, presence: true, length: { maximum: 100 }

  # Following/Unfollowing business logic
  def follow!(user)
    raise UserFollowingErrors::CannotFollowYourself, "Cannot follow yourself" if self.id == user.id

    raise UserFollowingErrors::AlreadyFollowing, "Already following this user" if following?(user)

    following_relationships.create!(followed_id: user.id)
  rescue ActiveRecord::RecordInvalid => e
    raise UserFollowingErrors::FollowFailed, "Failed to follow user: #{e.message}"
  end

  def unfollow!(user)
    raise UserFollowingErrors::CannotUnfollowYourself, "Cannot unfollow yourself" if self.id == user.id

    following_relationships.find_by(followed_id: user.id)&.destroy!
  rescue ActiveRecord::RecordInvalid => e
    raise UserFollowingErrors::UnfollowFailed, "Failed to unfollow user: #{e.message}"
  end

  def following?(user)
    following_relationships.exists?(followed_id: user.id)
  end
end
