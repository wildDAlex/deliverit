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
        'HTTP_USER_TOKEN' => @user.authentication_token
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
      let(:file) {
        Rack::Test::UploadedFile.new(Rails.root.join('public','test_image.jpg'), 'image/jpeg')
      }
      xit 'creates share with correct attributes' do
        include Rack::Test::Methods
        #file = ActionDispatch::Http::UploadedFile.new(Rails.root.join('public','test_image.jpg'))
        #file = Rack::Test::UploadedFile.new(Rails.root.join('public','test_image.jpg'))
        #require 'base64'
        #file =  File.open(Rails.root.join('public','test_image.jpg'))
        #file = Base64.encode64(file.read)


        #file = ActionDispatch::Http::UploadedFile.new({
        #                                                    :filename => 'test_image.jpg',
        #                                                    :content_type => 'image/jpeg',
        #                                                    :tempfile => File.new(Rails.root.join('public','test_image.jpg'))
        #                                                })



        share_params = { 'share' => { 'public' => true, file: {
            :content_type => file.content_type,
            :filename => file.original_filename,
            :file_data => Base64.encode64(file.read)
        } } }.to_json
        #share_params = share_params << {'file' => file}
        #share_params = { 'share[file]' => file.to_s }.to_json
        puts "======"
        #share_params[:file].each do |key,var| puts key end
        #puts share_params['share']['file']
        post "/api/v1/shares/", share_params, VALID_REQUEST_HEADERS

        expect(response.status).to eq 201

        expect(Share.last.public).to be_false
      end
    end

  end

  context 'non-matching requests' do

    describe 'GET /api/v1/shares' do
      it 'with invalid credentials returns error' do
        get '/api/v1/shares/', {}, INVALID_REQUEST_HEADERS

        expect(response.status).to eq 401

        body = JSON.parse(response.body)
        expect(body['error']).to eq('You need to sign in or sign up before continuing.')
      end
    end

    describe 'GET /api/v1/shares/:share' do
      it 'with invalid credentials returns error' do
        get "/api/v1/shares/#{@share1.id}", {}, INVALID_REQUEST_HEADERS

        expect(response.status).to eq 401

        body = JSON.parse(response.body)
        expect(body['error']).to eq('You need to sign in or sign up before continuing.')
      end

      it 'private share not viewable by another user' do
        private_share = FactoryGirl.create(:share, user: @user, public: false)
        get "/api/v1/shares/#{private_share.id}", {}, VALID_REQUEST_HEADERS_FOR_ANOTHER_USER

        expect(response.status).to eq 403

        body = JSON.parse(response.body)
        expect(body['error']).to eq('You are not authorized to access this page.')
      end

      it 'returns 404 if share non-exist' do
        share = FactoryGirl.create(:share, user: @user)
        share.destroy!
        get "/api/v1/shares/#{share.id}", {}, VALID_REQUEST_HEADERS

        expect(response.status).to eq 404

        body = JSON.parse(response.body)
        expect(body['error']).to eq('404: Not found.')
      end
    end

    describe 'PUT /api/v1/shares/:share' do
      it 'with invalid credentials returns error' do
        public_share = FactoryGirl.create(:share, user: @user, public: true)
        share_params = { 'share' => { 'public' => false } }.to_json
        put "/api/v1/shares/#{public_share.id}", share_params, INVALID_REQUEST_HEADERS

        expect(response.status).to eq 401

        body = JSON.parse(response.body)
        expect(body['error']).to eq('You need to sign in or sign up before continuing.')
      end

      it 'private share not updatable by another user' do
        private_share = FactoryGirl.create(:share, user: @user, public: false)
        share_params = { 'share' => { 'public' => true } }.to_json
        put "/api/v1/shares/#{private_share.id}", share_params, VALID_REQUEST_HEADERS_FOR_ANOTHER_USER

        expect(response.status).to eq 403

        body = JSON.parse(response.body)
        expect(body['error']).to eq('You are not authorized to access this page.')
      end

      it 'returns 404 if share non-exist' do
        share = FactoryGirl.create(:share, user: @user)
        share.destroy!
        share_params = { 'share' => { 'public' => false } }.to_json

        put "/api/v1/shares/#{share.id}", share_params, VALID_REQUEST_HEADERS

        expect(response.status).to eq 404

        body = JSON.parse(response.body)
        expect(body['error']).to eq('404: Not found.')
      end

    end

  end
end