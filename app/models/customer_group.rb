class CustomerGroup < ApplicationRecord
  has_and_belongs_to_many :schedules
  belongs_to :team
  validates :name, presence: true, uniqueness: { scope: :team }
end
