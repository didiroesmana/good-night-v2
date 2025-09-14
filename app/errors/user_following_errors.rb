module UserFollowingErrors
  class Error < StandardError; end
  class CannotFollowYourself < Error; end
  class AlreadyFollowing < Error; end
  class FollowFailed < Error; end
  class CannotUnfollowYourself < Error; end
  class UnfollowFailed < Error; end
end