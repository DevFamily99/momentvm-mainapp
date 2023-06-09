# frozen_string_literal: true

class PageModuleRoleWhitelist < ApplicationRecord
  belongs_to :role
  belongs_to :page_module
  belongs_to :user
end
