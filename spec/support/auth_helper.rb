# frozen_string_literal: true

RSpec.shared_context 'Auth Helper' do
  let(:username) { 'admin_user' }
  let(:password) { 'super_safe_password' }

  before { get root_path, headers: { 'Authorization' => basic_auth(username, password) } }

  def basic_auth(username, password)
    ActionController::HttpAuthentication::Basic.encode_credentials(username, password)
  end
end

RSpec.shared_examples 'unauthorized' do
  let(:username) { 'wrong' }
  it 'redirects' do
    subject
    expect(response).to redirect_to(root_path)
  end
end
