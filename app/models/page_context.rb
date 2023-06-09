# frozen_string_literal: true

# Page context provides config info for publishing content slots
class PageContext < ApplicationRecord
  CONTEXTS = %w[global category folder].freeze

  belongs_to :team
  has_many :pages, dependent: :nullify
  validates :context, presence: true, inclusion: { in: PageContext::CONTEXTS }

  def context_type
    context
  end

  def category?
    context == 'category'
  end

  def global?
    context == 'global'
  end

  def folder?
    context == 'folder'
  end
end
