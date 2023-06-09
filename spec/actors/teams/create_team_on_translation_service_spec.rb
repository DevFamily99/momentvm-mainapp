# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Teams::CreateTeamOnTranslationService, type: :actor do
  let!(:team) { create(:team) }

  context 'when team does not exist' do
    it 'creates a new team on the translation service' do
      expect do
        stub_request(:post,
                     'http://localhost:6789/api/create_team')
          .to_return(status: 200)
        described_class.call(team: team)
      end.not_to raise_error
    end
  end
  context 'when team already exists' do
    it 'creates a new team on the translation service' do
      expect do
        stub_request(:post,
                     'http://localhost:6789/api/create_team')
          .to_return(status: 422)
        described_class.call(team: team)
      end.to raise_error(ServiceActor::Failure)
    end
  end
end
