describe PopulateDailySleepSummaryJob, type: :job do
  let(:user) { create(:user) }

  describe '#perform' do
    context "when user has completed sleep records for the date" do
      let!(:sleep_record) { create(:sleep_record, :completed, user: user) }

      it "creates or updates the daily sleep summary" do
        expect {
          described_class.perform_now(user.id, sleep_record.id)
        }.to change { DailySleepSummary.count }.by(1)

        summary = DailySleepSummary.find_by(user: user, date: sleep_record.sleep_time.to_date)
        expect(summary.total_sleep_length_in_minutes).to eq(sleep_record.sleep_length_in_minutes)
      end
    end

    context "when user has completed sleep records for several times" do
      before  do
        3.times do | i |
          create(:sleep_record, :completed, sleep_time: i.minutes.ago, user: user)
        end
      end

      it "updates the daily sleep summary with the total sleep length" do
        expect {
          described_class.perform_now(user.id, user.sleep_records.last.id)
        }.to change { DailySleepSummary.count }.by(1)

        summary = DailySleepSummary.find_by(user: user, date: user.sleep_records.last.sleep_time.to_date)
        expect(summary.total_sleep_length_in_minutes).to eq(user.sleep_records.sum(:sleep_length_in_minutes))
      end
    end
  end
end