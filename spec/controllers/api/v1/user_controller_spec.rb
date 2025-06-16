require 'rails_helper'

RSpec.describe "Api::V1::UserController", type: :request do

  let(:valid_headers) { { 'CF-IPCountry' => 'US', 'CONTENT_TYPE' => 'application/json' } }
  let(:valid_params) do
    {
      idfa: 'test-idfa-123',
      rooted_device: false
    }
  end
  
  describe 'POST /api/v1/user/check_status' do

    let(:url) { '/api/v1/user/check_status' }

    context 'with valid parameters and headers' do
      it 'returns a successful response with ban_status' do
        post url, params: valid_params.to_json, headers: valid_headers

        expect(response).to have_http_status(200)
        json = JSON.parse(response.body)
        expect(json['ban_status']).to eq('not_banned')
      end
    end

    context 'missing required body parameters' do
      
      it 'returns unprocessable_entity with error message' do
        invalid_params = { rooted_device: false } # idfa missing

        post url, params: invalid_params.to_json, headers: valid_headers.merge('CONTENT_TYPE' => 'application/json')

        expect(response).to have_http_status(422)
        json = JSON.parse(response.body)
        expect(json['errors']).to include("Missing required body parameters: idfa")
      end
    end

    context 'missing required headers' do
      
      it 'returns unprocessable_entity with error message' do
        post url, params: valid_params.to_json, headers: { 'CONTENT_TYPE' => 'application/json' } # no CF-IPCountry

        expect(response).to have_http_status(422)
        json = JSON.parse(response.body)
        expect(json['errors']).to include('Missing required headers: CF-IPCountry')
      end
    end

    context 'when both body params and headers are missing' do
      
      it 'returns errors for both' do
        post url, params: {}.to_json, headers: { 'CONTENT_TYPE' => 'application/json' }

        expect(response).to have_http_status(422)
        json = JSON.parse(response.body)
        expect(json['errors']).to include('Missing required body parameters: idfa')
        expect(json['errors']).to include('Missing required body parameters: rooted_device')  
        expect(json['errors']).to include('Missing required headers: CF-IPCountry')
      end
    end

    context 'invalid rooted_device param (not boolean)' do
      
      it 'handles invalid param gracefully' do
        invalid_params = valid_params.merge(rooted_device: 'not_a_boolean')

        post url, params: invalid_params.to_json, headers: valid_headers.merge('CONTENT_TYPE' => 'application/json')
        expect(response).to have_http_status(200).or have_http_status(422)
      end
    end

    context 'empty JSON body' do
      it 'returns unprocessable_entity with error message' do
        post url, params: '{}', headers: valid_headers.merge('CONTENT_TYPE' => 'application/json')

        expect(response).to have_http_status(422)
        json = JSON.parse(response.body)
        expect(json['errors']).to include('Missing required body parameters: idfa')
        expect(json['errors']).to include('Missing required body parameters: rooted_device')
      end
    end
  end
end
