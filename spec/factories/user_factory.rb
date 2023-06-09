FactoryBot.define do
  factory :user do
    sequence(:email, 1000) { |n| "person#{n}@example.com" }
    password { '123456' }
    password_confirmation { '123456' }
    allowed_countries { %w[fr de].to_json }
    team { Team.first || create(:team) }
    

    trait :admin do
      after(:create) do |user|
        user.roles << create(:role)
      end
    end
  end
end
