module Pages
  #  Saves a new page comment to the db and triggers the subscription
  class NewPageComment < Actor
    play SavePageComment, TriggerPageCommentSubscription
  end
end
