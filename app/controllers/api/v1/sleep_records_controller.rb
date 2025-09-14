class Api::V1::SleepRecordsController < Api::V1::BaseController
  rescue_from SleepRecordErrors::Error, with: ->(e) { rescue_error(e, status: :unprocessable_content) }
  rescue_from ArgumentError, with: ->(e) { rescue_error(e, status: :bad_request) }

  # POST /api/v1/sleep_records/clock_in
  def clock_in
    service = SleepRecordsService.new(@current_user)
    sleep_records = service.clock_in!

    render_success(
      data: {
        message: "Successfully clocked in",
        sleep_records:  ActiveModel::Serializer::CollectionSerializer.new(
          sleep_records,
          serializer: V1::SleepRecordSerializer
        )
      },
      status: :created
    )
  end

  # POST /api/v1/sleep_records/clock_out
  def clock_out
    service = SleepRecordsService.new(@current_user)
    sleep_record = service.clock_out!

    render_success(
      data: {
        message: "Successfully clocked out",
        sleep_record: V1::SleepRecordSerializer.new(sleep_record)
      }
    )
  end

  def friends_activity
    start_date = Date.parse(params[:start_date]) rescue 1.week.ago.to_date
    end_date = Date.parse(params[:end_date]) rescue Date.current
    page = (params[:page] || 1).to_i
    per_page = (params[:per_page] || 10).to_i
    service = FriendRecordsService.new(@current_user, start_date, end_date, page, per_page)

    sleep_records = service.call!

    render_success(
      data: {
        sleep_records:  ActiveModel::Serializer::CollectionSerializer.new(
          sleep_records,
          serializer: V1::DailySleepSummarySerializer
        )
      },
      metadata: {
        current_page: sleep_records.current_page,
        per_page: sleep_records.limit_value,
        total_pages: sleep_records.total_pages,
        total_count: sleep_records.total_count,
      }
    )
  end
end