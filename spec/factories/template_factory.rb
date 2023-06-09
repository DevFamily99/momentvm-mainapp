FactoryBot.define do
  factory :template do
    name { 'testTemplate' }
    body { 'body' }
    team { Team.first }

    trait :with_schema do
      after(:create) do |template|
        create(:template_schema, template: template, team: template.team)
      end
    end
  end
end
