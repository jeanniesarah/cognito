# frozen_string_literal: true


module Cognito
  class Client
    include HTTParty,
            Responder

    # Default URI, can be override with Client#base_uri
    base_uri 'https://sandbox.cognitohq.com'

    HEADERS = {
      'Accept' => 'application/vnd.api+json',
      'Content-Type' => 'application/vnd.api+json'
    }.freeze

    def initialize(api_key:)
      basic_auth(api_key)
    end

    def base_uri=(uri)
      self.class.base_uri(uri)
    end

    def create_profile!
      response_from(post('/profiles', profile_params.to_json))
    end

    def search!(profile_id, phone_number)
      payload = search_params(profile_id, phone_number).to_json
      response_from(post('/identity_searches', payload))
    end

    def search_status!(search_job_id)
      response_from(get("/identity_searches/jobs/#{search_job_id}"))
    end

    def basic_auth(api_key)
      self.class.basic_auth(api_key, '')
    end

    protected

    def get(path)
      self.class.get(path, headers: HEADERS)
    end

    def post(path, payload)
      self.class.post(path, headers: HEADERS, body: payload)
    end

    private

    def profile_params
      {
        data: {
          type: PROFILE
        }
      }
    end

    # rubocop:disable Metrics/MethodLength
    def search_params(profile_id, phone_number)
      {
        data: {
          type: IDENTITY_SEARCH,
          attributes: {
            phone: {
              number: phone_number
            }
          },
          relationships: {
            profile: {
              data: {
                type: PROFILE,
                id:   profile_id
              }
            }
          }
        }
      }
    end
  end
end
