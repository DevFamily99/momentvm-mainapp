module Pages
  # Triggers the graphql schema subscription for page comments
  class TriggerPageCommentSubscription < Actor
    input :page_comment, allow_nil: false

    output :page_comment
    output :broadcast

    def call
      self.broadcast = ContentManagementSchema.subscriptions.trigger(:page_comments, { page_id: page_comment.page_id }, page_comment)
      self.page_comment = page_comment
    end
  end
end
