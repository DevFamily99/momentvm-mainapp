FactoryBot.define do
  factory :publishing_target do
    team { Team.first }
    name { 'Dev' }
    publishing_url { 'testurl.de' }
    default_library { 'library' }
  end
end
