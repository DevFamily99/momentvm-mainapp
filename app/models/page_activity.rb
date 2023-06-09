class PageActivity < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :page

  after_create :clean_up

  # Dont allow more than  page activities to be stored
  def clean_up
    while self.page.page_activities.count > 10
      self.page.page_activities.last.destroy
    end

  end

  def self.by_team(current_user)
    return PageActivity.where(team_id: current_user.team_id)
  end 

  
end
