class Api::V1::SleepRecordsController < Api::V1::BaseController
  rescue_from SleepRecordErrors::Error, with: ->(e) { rescue_error(e, status: :unprocessable_content) }

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
end