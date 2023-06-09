require 'rails_helper'

RSpec.describe ApplicationCable::Connection, type: :channel do
  let(:user) { create(:user) }

  it 'successfully connects' do
    connect "/cable?token=#{user.generate_api_token}"
    expect(connection.current_user).to eq user
  end

  it 'rejects connection when no authorization' do
    expect { connect '/cable' }.to have_rejected_connection
  end

  it 'rejects connection when bad token' do
    expect { connect '/cable', headers: { 'Authorization': user.generate_api_token + 'p' } }.to have_rejected_connection
  end
end
