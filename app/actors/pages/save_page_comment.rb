module Pages
  # Saves the page comment to the db
  class SavePageComment < Actor
    input :page_id, allow_nil: false
    input :user_id, allow_nil: false
    input :body, allow_nil: false

    output :page_comment

    def call
      self.page_comment = PageComment.create!(page_id: page_id, user_id: user_id, body: body)
    end
  end
end
