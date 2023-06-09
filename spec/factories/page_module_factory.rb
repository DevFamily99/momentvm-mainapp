FactoryBot.define do
  factory :page_module do
    team { Team.first || create(:team) }
    body { '' }
    template
  end
end
