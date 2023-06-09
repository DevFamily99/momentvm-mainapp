# frozen_string_literal: true

class AddScheduleIdToPublishingManifest < ActiveRecord::Migration[5.2]
  def change
    add_reference :publishing_manifests, :schedule, index: true
  end
end
