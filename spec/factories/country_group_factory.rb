FactoryBot.define do
  factory :country_group do
    team
    name { 'CountryGroup' }
    description { 'a test country group' }
    after(:create) do |country_group|
      country_group.sites << create(:site, team: country_group.team)
    end
  end
end
