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
end