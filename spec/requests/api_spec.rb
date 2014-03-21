# encoding: utf-8
require 'spec_helper'
require 'requests_helper'
#require "selenium-webdriver"

describe Api do

  before :all do
    @user = FactoryGirl.create(:valid_user)
    @another_user = FactoryGirl.create(:valid_user)
    VALID_REQUEST_HEADERS = {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json',
        'HTTP_USER_EMAIL' => @user.email,
        'HTTP_USER_TOKEN' => @user.authentication_token,
    }
    VALID_REQUEST_HEADERS_FOR_ANOTHER_USER = {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json',
        'HTTP_USER_EMAIL' => @another_user.email,
        'HTTP_USER_TOKEN' => @another_user.authentication_token
    }
    INVALID_REQUEST_HEADERS = {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json',
        'HTTP_USER_EMAIL' => @user.email,
        'HTTP_USER_TOKEN' => 'wrongtoken'
    }
    @share1 = FactoryGirl.create(:share, user: @user)
    @share2 = FactoryGirl.create(:not_image_share, user: @user)
  end

  context 'matching requests' do

    describe 'GET /api/v1/shares' do
      it 'returns all shares' do

        get '/api/v1/shares/', {}, VALID_REQUEST_HEADERS

        expect(response.status).to eq 200

        body = JSON.parse(response.body)
        filenames = body.map { |s| s['original_filename'] }
        expect(filenames).to match_array %w(test_image.jpg test_file.txt)
      end
    end

    describe 'GET /api/v1/shares/:share' do
      it 'return correct share' do
        get "/api/v1/shares/#{@share1.id}", {}, VALID_REQUEST_HEADERS

        expect(response.status).to eq 200

        body = JSON.parse(response.body)
        expect(body['original_filename']).to eq 'test_image.jpg'
      end
    end

    describe 'PUT /api/v1/shares/:share' do
      it 'updates share' do
        public_share = FactoryGirl.create(:share, user: @user, public: true)
        share_params = { 'share' => { 'public' => false } }.to_json

        put "/api/v1/shares/#{public_share.id}", share_params, VALID_REQUEST_HEADERS

        expect(response.status).to eq 204

        expect(Share.last.public).to be_false
      end
    end

    describe 'POST /api/v1/shares/' do
      it 'creates share with correct attributes' do
        file = Rack::Test::UploadedFile.new(Rails.root.join('public','file_via_post.jpg'), 'image/jpeg')
        share_params = { share: { public: true, file: file } }
        post "/api/v1/shares/", share_params, VALID_REQUEST_HEADERS

        expect(response.status).to eq 201

        expect(Share.last.public).to be_true
        expect(Share.last.original_filename).to eq 'file_via_post.jpg'
      end
    end

    describe 'DELETE /api/v1/shares/:share' do
      it 'deletes share' do
        share = FactoryGirl.create(:share, user: @user)
        delete "/api/v1/shares/#{share.id}", {}, VALID_REQUEST_HEADERS

        expect(response.status).to eq 204

        expect { Share.find(share.id) }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

  context 'non-matching requests' do

    shared_examples_for "not signed" do
      it "if invalid credentials" do
        request_with_invalid_credentials
        expect(response.status).to eq 401

        body = JSON.parse(response.body)
        expect(body['error']).to eq('You need to sign in or sign up before continuing.')
      end
    end

    shared_examples_for "not authorized" do
      it "when requested by another user" do
        request_by_another_user
        expect(response.status).to eq 403

        body = JSON.parse(response.body)
        expect(body['error']).to eq('You are not authorized to access this page.')
      end
    end

    shared_examples_for "non-exist" do
      it "when share not found" do
        request_to_non_exist_share
        expect(response.status).to eq 404

        body = JSON.parse(response.body)
        expect(body['error']).to eq('404: Not found.')
      end
    end

    describe 'GET /api/v1/shares' do
      let(:request_with_invalid_credentials) { get '/api/v1/shares/', {}, INVALID_REQUEST_HEADERS }
      it_should_behave_like "not signed"
    end

    describe 'GET /api/v1/shares/:share' do
      let(:request_with_invalid_credentials) { get "/api/v1/shares/#{@share1.id}", {}, INVALID_REQUEST_HEADERS }
      it_should_behave_like "not signed"

      let(:request_by_another_user) {
        private_share = FactoryGirl.create(:share, user: @user, public: false)
        get "/api/v1/shares/#{private_share.id}", {}, VALID_REQUEST_HEADERS_FOR_ANOTHER_USER
      }
      it_should_behave_like "not authorized"

      let(:request_to_non_exist_share) {
        share = FactoryGirl.create(:share, user: @user)
        share.destroy!
        get "/api/v1/shares/#{share.id}", {}, VALID_REQUEST_HEADERS
      }
      it_should_behave_like "non-exist"

    end

    describe 'PUT /api/v1/shares/:share' do
      let(:request_with_invalid_credentials) {
        public_share = FactoryGirl.create(:share, user: @user, public: true)
        share_params = { 'share' => { 'public' => false } }.to_json
        put "/api/v1/shares/#{public_share.id}", share_params, INVALID_REQUEST_HEADERS
      }
      it_should_behave_like "not signed"

      let(:request_by_another_user) {
        private_share = FactoryGirl.create(:share, user: @user, public: false)
        share_params = { 'share' => { 'public' => true } }.to_json
        put "/api/v1/shares/#{private_share.id}", share_params, VALID_REQUEST_HEADERS_FOR_ANOTHER_USER
      }
      it_should_behave_like "not authorized"

      let(:request_to_non_exist_share) {
        share = FactoryGirl.create(:share, user: @user)
        share.destroy!
        share_params = { 'share' => { 'public' => false } }.to_json
        put "/api/v1/shares/#{share.id}", share_params, VALID_REQUEST_HEADERS
      }
      it_should_behave_like "non-exist"

    end

    describe 'POST /api/v1/shares/' do
      let(:request_with_invalid_credentials) {
        file = Rack::Test::UploadedFile.new(Rails.root.join('public','file_via_post.jpg'), 'image/jpeg')
        share_params = { share: { public: true, file: file } }
        post "/api/v1/shares/", share_params, INVALID_REQUEST_HEADERS
      }
      it_should_behave_like "not signed"

      it 'filters unpermitted parameters' do
        file = Rack::Test::UploadedFile.new(Rails.root.join('public','file_via_post.jpg'), 'image/jpeg')
        share_params = { share: { public: true, file: file, user_id: @another_user.id } }
        post "/api/v1/shares/", share_params, VALID_REQUEST_HEADERS

        expect(response.status).to eq 201

        expect(Share.last.user).to eq @user
      end
    end

    describe 'DELETE /api/v1/shares/:share' do
      let(:request_with_invalid_credentials) {
        share = FactoryGirl.create(:share, user: @user)
        delete "/api/v1/shares/#{share.id}", {}, INVALID_REQUEST_HEADERS
      }
      it_should_behave_like "not signed"

      let(:request_to_non_exist_share) {
        share = FactoryGirl.create(:share, user: @user)
        share.destroy!
        delete "/api/v1/shares/#{share.id}", {}, VALID_REQUEST_HEADERS
      }
      it_should_behave_like "non-exist"

      let(:request_by_another_user) {
        private_share = FactoryGirl.create(:share, user: @user, public: false)
        delete "/api/v1/shares/#{private_share.id}", {}, VALID_REQUEST_HEADERS_FOR_ANOTHER_USER
      }
      it_should_behave_like "not authorized"
    end
  end
end