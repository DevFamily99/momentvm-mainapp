FactoryBot.define do
  factory :page do
    name { 'testPage' }
    team { Team.first || create(:team) }
  end
end
