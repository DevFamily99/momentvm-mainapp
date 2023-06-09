FactoryBot.define do
  factory :role do
    name { 'Admin' }
    body { { can_create_pages: 'yes', can_edit_pages: 'yes' } }
    team { Team.first || create(:team) }
  end
end
