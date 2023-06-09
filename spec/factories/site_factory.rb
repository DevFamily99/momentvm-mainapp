FactoryBot.define do
  factory :site do
    team
    name { 'Germany' }
    salesforce_id { 'DE' }
  end
end
