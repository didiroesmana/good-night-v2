class Api::V1::BaseController < ApplicationController
  before_action :set_current_user

  protected def set_current_user
    current_user_id = request.headers['X-User-ID']

    if current_user_id.blank?
      render_error(
        code: "MISSING_USER_ID",
        message: "X-User-ID header is required",
        status: :bad_request
      )
      return
    end

    @current_user = User.find(current_user_id)
  rescue ActiveRecord::RecordNotFound
    render_error(
      code: "INVALID_USER_ID",
      message: "Invalid user ID provided in X-User-ID header",
      status: :unauthorized
    )
  end

  # Standardized success response format
  protected def render_success(data: {}, status: :ok)
    render json: {
      data: data,
    }, status: status
  end

  # Standardized error response format
  protected def render_error(code:, message:, details: {}, status: :bad_request)
    render json: {
      error: {
        code: code,
        message: message,
        details: details,
      }
    }, status: status
  end

  protected def rescue_error(exception, status: :unprocessable_content)
    render_error(
      code: exception.class.name,
      message: exception.message,
      status: status,
    )
  end
end