# t.string "code"
# t.string "display_name"
# t.string "display_country"
# t.string "display_language"
# t.boolean "default"
# t.bigint "site_id"
# t.datetime "created_at", null: false
# t.datetime "updated_at", null: false

class Locale < ApplicationRecord
    belongs_to :site
end