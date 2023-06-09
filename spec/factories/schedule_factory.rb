FactoryBot.define do
  factory :schedule do
    page
    start_at { Time.current }
    end_at { Time.current + 7.days }
  end
end
