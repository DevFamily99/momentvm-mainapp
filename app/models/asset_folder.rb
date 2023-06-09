# A folder which can contain assets
class AssetFolder < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged
  belongs_to :asset_folder, optional: true
  has_many :assets, dependent: :destroy
  has_many :asset_folders, dependent: :destroy
  validates :name, presence: true
  belongs_to :team

  def self.by_team(current_user)
    AssetFolder.where(team_id: current_user.team_id)
  end

  def parent_folder
    asset_folder
  end

  def root?
    return true if asset_folder_id.nil?

    false
  end

  def generate_path
    self.path = Folders::GenerateFolderPath.call(folder: self).path
  end
end
