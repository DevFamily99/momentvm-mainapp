# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pages::SavePageComment, type: :actor do
  let(:user) { create(:user) }
  let(:page) { create(:page, team: user.team) }

  it 'saves a new page comment' do
    page_comment = described_class.call(page_id: page.id, user_id: user.id, body: 'hello').page_comment
    expect(page_comment).to be_instance_of(PageComment)
  end

  it 'fails if validation fails' do
    expect do
      described_class.call(page_id: page.id, user_id: user.id, body: '')
    end
      .to raise_error(ActiveRecord::RecordInvalid)
  end
end
