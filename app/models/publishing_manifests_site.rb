# frozen_string_literal: true

# Pivot table for assigning sites to the publishing manifest
class PublishingManifestsSite < ApplicationRecord
  belongs_to :publishing_manifest
  belongs_to :site
end
