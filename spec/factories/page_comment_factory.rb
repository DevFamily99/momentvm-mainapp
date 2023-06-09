FactoryBot.define do
  factory :page_comment do
    body { 'test comment' }
    user
    page
  end
end
