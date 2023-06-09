# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pages::TriggerPageCommentSubscription, type: :actor do
  let!(:page_comment) { create(:page_comment) }

  it 'returns page comment' do
    result = described_class.call(page_comment: page_comment)
    expect(result.page_comment).to be_instance_of(PageComment)
  end
end
