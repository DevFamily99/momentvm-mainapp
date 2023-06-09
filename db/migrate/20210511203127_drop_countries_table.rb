class DropCountriesTable < ActiveRecord::Migration[6.0] #:nodoc:
  def change
    drop_table :countries_country_groups do |t|
      t.bigint 'country_id'
      t.bigint 'country_group_id'
      t.datetime 'created_at', null: false
      t.datetime 'updated_at', null: false
      t.index ['country_group_id'], name: 'index_countries_country_groups_on_country_group_id'
      t.index ['country_id'], name: 'index_countries_country_groups_on_country_id'
    end

    drop_table :countries_languages do |t|
      t.bigint 'country_id'
      t.bigint 'language_id'
      t.datetime 'created_at', null: false
      t.datetime 'updated_at', null: false
      t.index ['country_id'], name: 'index_countries_languages_on_country_id'
      t.index ['language_id'], name: 'index_countries_languages_on_language_id'
    end

    drop_table :countries_publishing_manifests do |t|
      t.bigint 'country_id'
      t.bigint 'publishing_manifest_id'
      t.datetime 'created_at', null: false
      t.datetime 'updated_at', null: false
      t.index ['country_id'], name: 'index_countries_publishing_manifests_on_country_id'
      t.index ['publishing_manifest_id'], name: 'index_countries_publishing_manifests_on_publishing_manifest_id'
    end

    drop_table :countries do |t|
      t.string 'name'
      t.string 'code'
      t.datetime 'created_at', null: false
      t.datetime 'updated_at', null: false
      t.integer 'team_id'
    end
  end
end
