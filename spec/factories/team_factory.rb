FactoryBot.define do
  factory :team do
    name { 'testPage' }
    owner_firstname { 'firstName' }
    owner_lastname { 'lastName' }
    owner_email { 'test@email.com' }
    client_secret { 'testSecret' }
    client_id { 'testID' }
    plan
  end
end
