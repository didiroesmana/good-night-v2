class FriendRecordsService
  DEFAULT_PAGE = 1
  DEFAULT_PER_PAGE = 10

  MAX_DATE_RANGE = 7.days

  attr_reader :user, :start_date, :end_date, :page, :per_page

  def initialize(user, start_date, end_date, page, per_page)
    @user = user
    @start_date = start_date
    @end_date = end_date
    @page = page || DEFAULT_PAGE
    @per_page = per_page || DEFAULT_PER_PAGE
  end

  def call!
    validate_params!
    build_query
  end

  def validate_params!
    raise ArgumentError, "Invalid user" if user.nil?
    raise ArgumentError, "Range should not be more than 7 days" if (end_date - start_date).days > MAX_DATE_RANGE
    raise ArgumentError, "Invalid date range" if start_date > end_date
    raise ArgumentError, "Invalid page number" if page < 1
    raise ArgumentError, "Invalid per page" if per_page < 1
  end

  def build_query
    query = DailySleepSummary.where(user: user.following).order(total_sleep_length_in_minutes: :desc)
    query = apply_date_filter(query)
    apply_pagination(query)
  end

  def apply_date_filter(query)
    query.where("date >= ? AND date <= ?", start_date, end_date)
  end

  def apply_pagination(query)
    query.page(page).per(per_page)
  end
end
