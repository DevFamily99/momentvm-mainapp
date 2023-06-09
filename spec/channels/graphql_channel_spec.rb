require 'spec_helper'

RSpec.describe GraphqlChannel, type: :channel do
  let(:page) { create(:page) }

  it 'successfully subscribes' do
    subscribe room_id: 42
    expect(subscription).to be_confirmed
  end

  it 'transmits successfully' do
    subscribe room_id: 42
    query = 'subscription { pageComments(pageId: $pageId) { id } }'
    variables = { "pageId": page.id }
    perform :execute, query: query, variables: variables
    expect(transmissions.last).not_to be_empty
  end

  it 'throws parse error if variables are not formated as json' do
    subscribe room_id: 42
    query = 'subscription { pageComments(pageId: $pageId) { id } }'
    variables = 'nil'
    expect do
      perform :execute, query: query, variables: variables
    end.to raise_error(JSON::ParserError)
  end

  it 'throws error if variables are of an unsuported data type' do
    subscribe room_id: 42
    query = 'subscription { pageComments(pageId: $pageId) { id } }'
    variables = 1
    expect do
      perform :execute, query: query, variables: variables
    end.to raise_error(ArgumentError)
  end
end
