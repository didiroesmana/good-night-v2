describe Api::V1::SleepRecordsController, type: :controller do
  let(:current_user) { create(:user, name: "Sleep User") }

  before do
    request.headers['X-User-ID'] = current_user.id
  end

  describe "POST #clock_in" do
    context "when user has no active sleep record" do
      it "creates a new sleep record" do
        expect {
          post :clock_in
        }.to change(SleepRecord, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(response_body['data']['message']).to eq("Successfully clocked in")
      end

      it "sets sleep_time to current time" do
        freeze_time = Time.current

        post :clock_in

        sleep_record = SleepRecord.last
        expect(sleep_record.sleep_time).to be_within(1.second).of(freeze_time)
        expect(sleep_record.wake_time).to be_nil
        expect(sleep_record.sleep_length_in_minutes).to be_nil
      end
    end

    context "when user has an completed sleep record" do 
      before do
        create_list(:sleep_record, 11, :completed, user: current_user)
      end

      it "creates a new sleep record and return 10 records" do
        freeze_time = Time.current

        expect {
          post :clock_in
        }.to change(SleepRecord, :count).by(1)

        last_sleep = SleepRecord.last
        expect(last_sleep.sleep_time).to be_within(1.second).of(freeze_time)

        expect(response).to have_http_status(:created)
        expect(response_body['data']['message']).to eq("Successfully clocked in")
        expect(response_body['data']['sleep_records'].size).to eq(10)
        expect(response_body['data']['sleep_records'].first['id']).to eq(last_sleep.id)
      end
    end
  end

  describe "POST #clock_out" do
    context "when user has an active sleep record" do
      let!(:active_sleep) do
        create(:sleep_record, user: current_user, sleep_time: 8.hours.ago, wake_time: nil)
      end

      it "updates the active sleep record with wake_time and sleep_length" do
        freeze_time = Time.current

        post :clock_out

        active_sleep.reload
        expect(active_sleep.wake_time).to be_within(1.second).of(freeze_time)
        expect(active_sleep.sleep_length_in_minutes).to be >= 480
      end

      it "returns success with the record" do
        post :clock_out

        expect(response).to have_http_status(:ok)
        expect(response_body['data']['message']).to eq("Successfully clocked out")

        sleep_record = response_body['data']['sleep_record']
        expect(sleep_record['wake_time']).to be_present
        expect(sleep_record['sleep_length_in_minutes']).to be >= 480
      end
    end

    context "when user has no active sleep record" do
      it "returns an error" do
        post :clock_out

        expect(response).to have_http_status(:unprocessable_content)
        expect(response_body['error']['code']).to eq('SleepRecordErrors::CannotClockOutWithoutActiveRecord')
        expect(response_body['error']['message']).to include("Cannot clock out without an active sleep record")
      end
    end

    context "when user has only completed sleep records" do
      before do
        create(:sleep_record, user: current_user, sleep_time: 1.day.ago, wake_time: 16.hours.ago,sleep_length_in_minutes: 480)
      end

      it "returns an error" do
        post :clock_out

        expect(response).to have_http_status(:unprocessable_content)
        expect(response_body['error']['code']).to eq('SleepRecordErrors::CannotClockOutWithoutActiveRecord')
      end
    end
  end

  describe "GET #friends_activity" do
    let(:friend1) { create(:user) }
    let(:friend2) { create(:user) }
    let(:non_friend) { create(:user) }

    before do
      # Set up following relationships
      create(:user_following, follower: current_user, followed: friend1)
      create(:user_following, follower: current_user, followed: friend2)

      # Create daily sleep summaries for friends within the last week
      create(:daily_sleep_summary,
        user: friend1,
        date: 2.days.ago.to_date,
        total_sleep_length_in_minutes: 480
      )
      create(:daily_sleep_summary,
        user: friend2,
        date: 3.days.ago.to_date,
        total_sleep_length_in_minutes: 420
      )
      create(:daily_sleep_summary,
        user: friend1,
        date: 1.day.ago.to_date,
        total_sleep_length_in_minutes: 510
      )

      # Create summary for non-friend (should not appear)
      create(:daily_sleep_summary,
        user: non_friend,
        date: 2.days.ago.to_date,
        total_sleep_length_in_minutes: 600
      )
    end

    context "when user has friends with sleep records" do
      it "returns friends' sleep records ordered by duration" do
        get :friends_activity

        expect(response).to have_http_status(:ok)

        sleep_records = response_body['data']['sleep_records']
        expect(sleep_records.size).to eq(3)

        # Should be ordered by total_sleep_length_in_minutes desc
        expect(sleep_records.first['total_sleep_length_in_minutes']).to eq(510)
        expect(sleep_records.second['total_sleep_length_in_minutes']).to eq(480)
        expect(sleep_records.third['total_sleep_length_in_minutes']).to eq(420)
      end

      it "only includes records from followed friends" do
        get :friends_activity, params: { page: 1, per_page: 100 }

        sleep_records = response_body['data']['sleep_records']
        user_ids = sleep_records.map { |r| r['user_id'] }

        expect(user_ids).to contain_exactly(friend1.id, friend1.id, friend2.id)
        expect(user_ids).not_to include(non_friend.id)
        expect(user_ids).not_to include(current_user.id)
      end

      it "includes pagination metadata" do
        get :friends_activity

        metadata = response_body['metadata']
        expect(metadata['current_page']).to eq(1)
        expect(metadata['per_page']).to eq(10)
        expect(metadata['total_pages']).to eq(1)
        expect(metadata['total_count']).to eq(3)
      end

      it "respects pagination parameters" do
        get :friends_activity, params: { page: 1, per_page: 2 }

        sleep_records = response_body['data']['sleep_records']
        metadata = response_body['metadata']

        expect(sleep_records.size).to eq(2)
        expect(metadata['current_page']).to eq(1)
        expect(metadata['per_page']).to eq(2)
        expect(metadata['total_pages']).to eq(2)
      end

      context "with pagination parameters" do
        before do
          DailySleepSummary.destroy_all
          UserFollowing.destroy_all
          create_list(:user_following, 30, follower: current_user)

          current_user.following.each do |friend|
            create(:daily_sleep_summary, date: rand(1...6).days.ago, user: friend, total_sleep_length_in_minutes: rand(480..510))
          end
        end

        it "should return correct pagination metadata" do
          get :friends_activity, params: { page: 2, per_page: 10 }

          metadata = response_body['metadata']
          expect(metadata['current_page']).to eq(2)
          expect(metadata['per_page']).to eq(10)
          expect(metadata['total_pages']).to eq(3)
          expect(metadata['total_count']).to eq(30)
        end
      end
    end

    context "when user has no friends" do
      before do
        UserFollowing.destroy_all
      end

      it "returns empty array" do
        get :friends_activity

        expect(response).to have_http_status(:ok)
        sleep_records = response_body['data']['sleep_records']
        expect(sleep_records).to be_empty
      end

      it "returns correct pagination metadata for empty results" do
        get :friends_activity

        metadata = response_body['metadata']
        expect(metadata['total_count']).to eq(0)
        expect(metadata['total_pages']).to eq(0)
      end
    end

    context "when friends have no sleep records in the past week" do
      before do
        DailySleepSummary.destroy_all
        # Create old records outside the week range
        create(:daily_sleep_summary,
          user: friend1,
          date: 10.days.ago.to_date,
          total_sleep_length_in_minutes: 480
        )
      end

      it "returns empty array" do
        get :friends_activity

        expect(response).to have_http_status(:ok)
        sleep_records = response_body['data']['sleep_records']
        expect(sleep_records).to be_empty
      end
    end
  end
end