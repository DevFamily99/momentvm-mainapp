FactoryBot.define do
  factory :page_context do
    team { nil }
    name { 'page context' }
    context { 'global' } # rubocop:disable RSpec/MissingExampleGroupArgument, RSpec/EmptyExampleGroup

    slot { 'MyString' }
  end
end
