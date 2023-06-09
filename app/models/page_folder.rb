# frozen_string_literal: true

class PageFolder < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged
  belongs_to :page_folder, optional: true
  has_many :pages,  dependent: :destroy
  has_many :page_folders, dependent: :destroy
  belongs_to :team
  validates :name, presence: true
  validate :cant_belong_to_itself

  after_create :generate_path

  def cant_belong_to_itself
    # in case of creating the root folder for a team
    return if id.nil? && page_folder_id.nil?

    errors.add(:page_folder_id, 'cannot belong to itself') if id == page_folder_id
  end

  def soft_delete(value)
    self.is_deleted = value
    save
    page_folders.each do |p|
      p.soft_delete(value)
    end
  end

  def self.by_team(current_user)
    if PageFolder.where(team_id: current_user.team_id).empty?
      PageFolder.create(name: 'root', team_id: current_user.team_id, path: '/'+current_user.team.name+'/')
    end 
    return PageFolder.where(team_id: current_user.team_id)
  end

  def parent_folder
    page_folder
  end

  def root?
    return true if page_folder_id.nil?

    false
  end

  def generate_path
    self.path = Folders::GenerateFolderPath.call(folder: self).path
    self.save!
  end
end
