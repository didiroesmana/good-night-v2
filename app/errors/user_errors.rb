module UserErrors
  class Error < StandardError; end
  class UserNotFound < Error; end
end