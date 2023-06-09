# An asset like an image
class BlueprintPageModule < ApplicationRecord
    belongs_to :blueprint
    belongs_to :page_module
end
  