class Blueprint < ApplicationRecord
    has_many :blueprint_page_modules
    has_many :page_modules, through: :blueprint_page_modules
end
  