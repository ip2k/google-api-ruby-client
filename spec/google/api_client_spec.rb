# Copyright 2010 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'spec_helper'

require 'faraday'
require 'signet/oauth_1/client'
require 'google/api_client'
require 'google/api_client/version'

shared_examples_for 'configurable user agent' do
  include ConnectionHelpers
  
  it 'should allow the user agent to be modified' do
    client.user_agent = 'Custom User Agent/1.2.3'
    expect(client.user_agent).to eq 'Custom User Agent/1.2.3'
  end

  it 'should allow the user agent to be set to nil' do
    client.user_agent = nil
    expect(client.user_agent).to be nil
  end

  it 'should not allow the user agent to be used with bogus values' do
    expect(lambda do
      client.user_agent = 42
      client.execute(:uri=>'https://www.google.com/')
    end).to raise_error(TypeError)
  end

  it 'should transmit a User-Agent header when sending requests' do
    client.user_agent = 'Custom User Agent/1.2.3'

    conn = stub_connection do |stub|
      stub.get('/') do |env|
        headers = env[:request_headers]
        expect(headers).to have_key('User-Agent')
        expect(headers['User-Agent']).to eq client.user_agent
        [200, {}, ['']]
      end
    end
    client.execute(:uri=>'https://www.google.com/', :connection => conn)
    conn.verify
  end
end

describe Google::APIClient do
  include ConnectionHelpers

  let(:client) { Google::APIClient.new(:application_name => 'API Client Tests') }

  it 'should make its version number available' do
    expect(Google::APIClient::VERSION::STRING).to be_instance_of(String)
  end

  it 'should default to OAuth 2' do
    expect(client.authorization).to be_instance_of(Signet::OAuth2::Client)
  end

  describe 'configure for no authentication' do
    before do
      client.authorization = nil
    end
    it_should_behave_like 'configurable user agent'
  end
    
  describe 'configured for OAuth 1' do
    before do
      client.authorization = :oauth_1
      client.authorization.token_credential_key = 'abc'
      client.authorization.token_credential_secret = '123'
    end

    it 'should use the default OAuth1 client configuration' do
      expect(client.authorization.temporary_credential_uri.to_s).to eq (
        'https://www.google.com/accounts/OAuthGetRequestToken')
      expect(client.authorization.authorization_uri.to_s).to include(
        'https://www.google.com/accounts/OAuthAuthorizeToken'
      )
      expect(client.authorization.token_credential_uri.to_s).to eq (
        'https://www.google.com/accounts/OAuthGetAccessToken')
      expect(client.authorization.client_credential_key).to eq 'anonymous'
      expect(client.authorization.client_credential_secret).to eq 'anonymous'
    end

    it_should_behave_like 'configurable user agent'
  end

  describe 'configured for OAuth 2' do
    before do
      client.authorization = :oauth_2
      client.authorization.access_token = '12345'
    end

    # TODO
    it_should_behave_like 'configurable user agent'
  end
  
  describe 'when executing requests' do
    before do
      @prediction = client.discovered_api('prediction', 'v1.2')
      client.authorization = :oauth_2
      @connection = stub_connection do |stub|
        stub.post('/prediction/v1.2/training?data=12345') do |env|
          expect(env[:request_headers]['Authorization']).to eq 'Bearer 12345'
        end
      end
    end

    after do
      @connection.verify
    end
    
    it 'should use default authorization' do
      client.authorization.access_token = "12345"
      client.execute(  
        :api_method => @prediction.training.insert,
        :parameters => {'data' => '12345'},
        :connection => @connection
      )
    end

    it 'should use request scoped authorization when provided' do
      client.authorization.access_token = "abcdef"
      new_auth = Signet::OAuth2::Client.new(:access_token => '12345')
      client.execute(  
        :api_method => @prediction.training.insert,
        :parameters => {'data' => '12345'},
        :authorization => new_auth,
        :connection => @connection
      )
    end
    
    it 'should accept options with batch/request style execute' do
      client.authorization.access_token = "abcdef"
      new_auth = Signet::OAuth2::Client.new(:access_token => '12345')
      request = client.generate_request(
        :api_method => @prediction.training.insert,
        :parameters => {'data' => '12345'}
      )
      client.execute(
        request,
        :authorization => new_auth,
        :connection => @connection
      )
    end
    
    
    it 'should accept options in array style execute' do
       client.authorization.access_token = "abcdef"
       new_auth = Signet::OAuth2::Client.new(:access_token => '12345')
       client.execute(  
         @prediction.training.insert, {'data' => '12345'}, '', {},
         { :authorization => new_auth, :connection => @connection }         
       )
     end
  end  
end
