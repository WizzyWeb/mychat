require 'rails_helper'

RSpec.describe 'Platform Users API', type: :request do
  let!(:user) { create(:user, email: 'dev+testing@chatmy.ae', custom_attributes: { test: 'test' }) }

  describe 'GET /platform/api/v1/users/{user_id}' do
    context 'when it is an unauthenticated platform app' do
      it 'returns unauthorized' do
        get "/platform/api/v1/users/#{user.id}"
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when it is an invalid platform app token' do
      it 'returns unauthorized' do
        get "/platform/api/v1/users/#{user.id}", headers: { api_access_token: 'invalid' }, as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when it is an authenticated platform app' do
      let(:platform_app) { create(:platform_app) }

      it 'returns unauthorized when its not a permissible object' do
        get "/platform/api/v1/users/#{user.id}", headers: { api_access_token: platform_app.access_token.token }, as: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it 'shows a user when its permissible object' do
        create(:platform_app_permissible, platform_app: platform_app, permissible: user)

        get "/platform/api/v1/users/#{user.id}",
            headers: { api_access_token: platform_app.access_token.token }, as: :json

        expect(response).to have_http_status(:success)
        data = response.parsed_body
        expect(data['email']).to eq(user.email)
        expect(data['custom_attributes']['test']).to eq('test')
      end
    end
  end

  describe 'GET /platform/api/v1/users/{user_id}/login' do
    context 'when it is an unauthenticated platform app' do
      it 'returns unauthorized' do
        get "/platform/api/v1/users/#{user.id}/login"
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when it is an invalid platform app token' do
      it 'returns unauthorized' do
        get "/platform/api/v1/users/#{user.id}/login", headers: { api_access_token: 'invalid' }, as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when it is an authenticated platform app' do
      let(:platform_app) { create(:platform_app) }

      it 'returns unauthorized when its not a permissible object' do
        get "/platform/api/v1/users/#{user.id}/login", headers: { api_access_token: platform_app.access_token.token }, as: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it 'return login link for user' do
        create(:platform_app_permissible, platform_app: platform_app, permissible: user)

        get "/platform/api/v1/users/#{user.id}/login",
            headers: { api_access_token: platform_app.access_token.token }, as: :json

        expect(response).to have_http_status(:success)
        data = response.parsed_body
        expect(data['url']).to include('email=dev%2Btesting%40chatmy.ae&sso_auth_token=')
      end
    end
  end

  describe 'POST /platform/api/v1/users/{user_id}/token' do
    context 'when it is an unauthenticated platform app' do
      it 'returns unauthorized' do
        post "/platform/api/v1/users/#{user.id}/token"
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when it is an invalid platform app token' do
      it 'returns unauthorized' do
        post "/platform/api/v1/users/#{user.id}/token", headers: { api_access_token: 'invalid' }, as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when it is an authenticated platform app' do
      let(:platform_app) { create(:platform_app) }

      it 'returns unauthorized when its not a permissible object' do
        post "/platform/api/v1/users/#{user.id}/token", headers: { api_access_token: platform_app.access_token.token }, as: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns access token for the user with expiry and user info' do
        create(:platform_app_permissible, platform_app: platform_app, permissible: user)

        post "/platform/api/v1/users/#{user.id}/token",
             headers: { api_access_token: platform_app.access_token.token }, as: :json

        expect(response).to have_http_status(:success)
        data = response.parsed_body

        # Check access token and expiry
        expect(data['access_token']).to eq(user.access_token.token)
        expect(data['expiry']).to be_nil

        # Check user info
        expect(data['user']).to include(
          'id' => user.id,
          'name' => user.name,
          'display_name' => user.display_name,
          'email' => user.email,
          'pubsub_token' => user.pubsub_token
        )
      end
    end
  end

  describe 'POST /platform/api/v1/users/' do
    context 'when it is an unauthenticated platform app' do
      it 'returns unauthorized' do
        post '/platform/api/v1/users'
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when it is an invalid platform app token' do
      it 'returns unauthorized' do
        post '/platform/api/v1/users/', headers: { api_access_token: 'invalid' }, as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when it is an authenticated platform app' do
      let(:platform_app) { create(:platform_app) }

      it 'creates a new user and permissible for the user without sending an email' do
        # TODO: enqueued mail check failes because of  : https://github.com/rspec/rspec-rails/pull/2793
        # revert to this block when the issue is fixed

        # expect do
        #   post '/platform/api/v1/users/', params: { name: 'test', display_name: 'displaytest',
        #                                             email: 'test@test.com', password: 'Password1!',
        #                                             custom_attributes: { test: 'test_create' } },
        #                                   headers: { api_access_token: platform_app.access_token.token }, as: :json
        #   byebug
        # end.not_to have_enqueued_mail

        ##------ revert this block when the issue is fixed
        post '/platform/api/v1/users/', params: { name: 'test', display_name: 'displaytest',
                                                  email: 'test@test.com', password: 'Password1!',
                                                  custom_attributes: { test: 'test_create' } },
                                        headers: { api_access_token: platform_app.access_token.token }, as: :json
        mail_jobs = ActiveJob::Base.queue_adapter.enqueued_jobs.select do |job|
          job[:job] == 'ActionMailer::MailDeliveryJob'
        end
        expect(mail_jobs.count).to eq(0)
        ##------ revert this block when the issue is fixed

        expect(response).to have_http_status(:success)
        data = response.parsed_body
        expect(data).to match(
          hash_including(
            'name' => 'test',
            'display_name' => 'displaytest',
            'email' => 'test@test.com',
            'custom_attributes' => {
              'test' => 'test_create'
            }
          )
        )
        expect(platform_app.platform_app_permissibles.first.permissible_id).to eq data['id']
      end

      it 'fetch existing user and creates permissible for the user' do
        create(:user, name: 'old test', email: 'test@test.com')
        post '/platform/api/v1/users/', params: { name: 'test', email: 'test@test.com', password: 'Password1!' },
                                        headers: { api_access_token: platform_app.access_token.token }, as: :json

        expect(response).to have_http_status(:success)
        data = response.parsed_body
        expect(data['name']).to eq('old test')
        expect(platform_app.platform_app_permissibles.first.permissible_id).to eq data['id']
      end
    end
  end

  describe 'PATCH /platform/api/v1/users/{user_id}' do
    context 'when it is an unauthenticated platform app' do
      it 'returns unauthorized' do
        patch "/platform/api/v1/users/#{user.id}"
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when it is an invalid platform app token' do
      it 'returns unauthorized' do
        patch "/platform/api/v1/users/#{user.id}", headers: { api_access_token: 'invalid' }, as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when it is an authenticated platform app' do
      let(:platform_app) { create(:platform_app) }

      it 'returns unauthorized when its not a permissible object' do
        patch "/platform/api/v1/users/#{user.id}", params: { name: 'test' },
                                                   headers: { api_access_token: platform_app.access_token.token }, as: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it 'updates the user attributes' do
        create(:platform_app_permissible, platform_app: platform_app, permissible: user)
        patch "/platform/api/v1/users/#{user.id}", params: {
                                                     name: 'test123', email: 'newtestemail@test.com', custom_attributes: { test: 'test_update' }
                                                   },
                                                   headers: { api_access_token: platform_app.access_token.token }, as: :json

        expect(response).to have_http_status(:success)
        data = response.parsed_body
        expect(data['name']).to eq('test123')
        expect(data['email']).to eq('newtestemail@test.com')
        expect(data['custom_attributes']['test']).to eq('test_update')
      end
    end
  end

  describe 'DELETE /platform/api/v1/users/{user_id}' do
    context 'when it is an unauthenticated platform app' do
      it 'returns unauthorized' do
        delete "/platform/api/v1/users/#{user.id}"
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when it is an invalid platform app token' do
      it 'returns unauthorized' do
        delete "/platform/api/v1/users/#{user.id}", headers: { api_access_token: 'invalid' }, as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when it is an authenticated platform app' do
      let(:platform_app) { create(:platform_app) }

      it 'returns unauthorized when its not a permissible object' do
        delete "/platform/api/v1/users/#{user.id}", headers: { api_access_token: platform_app.access_token.token }, as: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it 'deletes the user' do
        create(:platform_app_permissible, platform_app: platform_app, permissible: user)
        expect(DeleteObjectJob).to receive(:perform_later).with(user).once
        delete "/platform/api/v1/users/#{user.id}",
               headers: { api_access_token: platform_app.access_token.token }, as: :json
        expect(response).to have_http_status(:success)
      end
    end
  end
end
