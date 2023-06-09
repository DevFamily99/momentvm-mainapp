class PageComment < ApplicationRecord
  belongs_to :user
  belongs_to :page

  validates_presence_of :body
  after_create :trigger_comment_posted_event

  private

  def trigger_comment_posted_event
    puts "created new comment for page: #{self.page.id}"
    ContentManagementSchema.subscriptions.trigger("page_comments", {}, { comment: self })
  end
end
