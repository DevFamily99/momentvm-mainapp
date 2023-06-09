FactoryBot.define do
  factory :publishing_manifest do
    page
    publishing_target
    user
    schedule { nil }
  end
end
