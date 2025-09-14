Rails.application.routes.draw do
  # Health check endpoint for load balancers and uptime monitors
  get "up" => "rails/health#show", as: :rails_health_check

  # Sleep Tracker API Routes
  namespace :api do
    namespace :v1 do
      # User Following System
      # POST /api/v1/users/:user_id/follow - Follow a user
      # DELETE /api/v1/users/:user_id/unfollow - Unfollow a user
      resources :users, only: [] do
        member do
          post :follow
          delete :unfollow
        end
      end

      # Sleep Records System
      # POST /api/v1/sleep_records/clock_in - Clock in for sleep
      # POST /api/v1/sleep_records/clock_out - Clock out from sleep
      resources :sleep_records, only: [] do
        collection do
          post :clock_in
          post :clock_out
          get :friends_activity
        end
      end
    end
  end
end
