# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Role, type: :model do
  let(:role) { create(:role) }

  it { should have_and_belong_to_many(:users) }
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name).scoped_to(:team_id) }

  it 'All skills helper function' do
    skills = Role.all_skills
    expect(skills.length).to equal(14)
    skills.each do |skill_obj|
      expect(skill_obj.first[1]).to equal(false)
    end
  end

  describe 'has_skill?' do
    it 'returns true if user is admin' do
      expect(role.has_skill?('can_do_anything')).to equal(true)
    end
    it 'returns true if user has skill' do
      role.update(name: 'notAdmin')
      expect(role.has_skill?('can_create_pages')).to equal(true)
    end
    it 'returns false if user does not have skill' do
      role.update(name: 'notAdmin')
      expect(role.has_skill?('can_nothing')).to equal(false)
    end
  end

  # it 'By team helper function' do
  #   current_user = User.find_by(email: 'testuser@example.com')
  #   user_team_id = current_user.team_id

  #   roles_by_team = Role.by_team(current_user)
  #   expect(roles_by_team.length).to equal(2)

  #   roles_by_team.each do |single_role|
  #     expect(single_role.team_id).to equal(user_team_id)
  #   end
  # end
end
