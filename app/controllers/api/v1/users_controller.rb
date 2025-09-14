class Api::V1::UsersController < Api::V1::BaseController
  rescue_from UserFollowingErrors::Error, with: ->(e) { rescue_error(e, status: :unprocessable_content) }
  rescue_from UserErrors::Error, with: ->(e) { rescue_error(e, status: :not_found) }

  # POST /api/v1/users/:id/follow
  def follow
    @current_user.follow!(target_user(params[:id]))

    render_success(
      data: {
        message: "Successfully followed user",
      },
      status: :created
    )
  end

  # DELETE /api/v1/users/:id/unfollow
  def unfollow
    @current_user.unfollow!(target_user(params[:id]))

    render_success(
      data: {
        message: "Successfully unfollowed user",
      },
      status: :ok
    )
  end


  private def target_user(user_id)
    @target_user ||= User.find(user_id)
  rescue ActiveRecord::RecordNotFound
    raise UserErrors::UserNotFound, "target user not found"
  end
end