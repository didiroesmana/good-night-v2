describe Api::V1::UsersController, type: :controller do
  let(:current_user) { create(:user, name: "Current User") }
  let(:target_user) { create(:user, name: "Target User") }

  before do
    request.headers['X-User-ID'] = current_user.id
  end

  describe "POST #follow" do
    context "when X-User-ID header is missing" do
      before do
        request.headers['X-User-ID'] = nil
      end

      it "returns authentication error" do
        post :follow, params: { id: target_user.id }

        expect(response).to have_http_status(:bad_request)
        expect(response_body['error']['code']).to eq('MISSING_USER_ID')
      end
    end

    context "when X-User-ID header is invalid" do
      before do
        request.headers['X-User-ID'] = '999999'
      end

      it "returns authentication error" do
        post :follow, params: { id: target_user.id }

        expect(response).to have_http_status(:unauthorized)
        expect(response_body['error']['code']).to eq('INVALID_USER_ID')
      end
    end

    context "when following a valid user" do
      it "successfully follows the user" do
        post :follow, params: { id: target_user.id }

        expect(response).to have_http_status(:created)
        expect(response_body['data']['message']).to eq("Successfully followed user")
        expect(current_user.following?(target_user)).to be true
      end

      it "returns user information in response" do
        post :follow, params: { id: target_user.id }

        expect(response_body['data']).to include(
          'message' => 'Successfully followed user'
        )
      end
    end

    context "when trying to follow yourself" do
      it "returns an error" do
        post :follow, params: { id: current_user.id }

        expect(response).to have_http_status(:unprocessable_content)
        expect(response_body['error']['code']).to eq('UserFollowingErrors::CannotFollowYourself')
        expect(response_body['error']['message']).to include("Cannot follow yourself")
      end
    end

    context "when already following the user" do
      before do
        current_user.follow!(target_user)
      end

      it "returns an error" do
        expect {
          post :follow, params: { id: target_user.id }
        }.not_to change(UserFollowing, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(response_body['error']['code']).to eq('UserFollowingErrors::AlreadyFollowing')
      end
    end

    context "when target user doesn't exist" do
      it "returns user not found error" do
        post :follow, params: { id: 999999 }

        expect(response).to have_http_status(:not_found)
        expect(response_body['error']['code']).to eq('UserErrors::UserNotFound')
      end
    end
  end

  describe "DELETE #unfollow" do
    context "when unfollowing a followed user" do
      before do
        current_user.follow!(target_user)
      end

      it "successfully unfollows the user" do
        delete :unfollow, params: { id: target_user.id }

        expect(response).to have_http_status(:ok)
        expect(current_user.following?(target_user)).to be false
      end

      it "returns success message" do
        delete :unfollow, params: { id: target_user.id }

        expect(response_body['data']['message']).to eq('Successfully unfollowed user')
      end
    end

    context "when trying to unfollow yourself" do
      it "returns an error" do
        delete :unfollow, params: { id: current_user.id }

        expect(response).to have_http_status(:unprocessable_content)
        expect(response_body['error']['code']).to eq('UserFollowingErrors::CannotUnfollowYourself')
      end
    end

    context "when not following the user" do
      it "handles gracefully without error" do
        delete :unfollow, params: { id: target_user.id }

        expect(response).to have_http_status(:ok)
        expect(response_body['data']['message']).to eq('Successfully unfollowed user')
      end
    end

    context "when target user doesn't exist" do
      it "returns user not found error" do
        delete :unfollow, params: { id: 999999 }

        expect(response).to have_http_status(:not_found)
        expect(response_body['error']['code']).to eq('UserErrors::UserNotFound')
      end
    end
  end
end