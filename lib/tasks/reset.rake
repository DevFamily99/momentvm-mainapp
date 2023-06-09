# Purge data from the database
namespace :reset do
  desc 'clean prod database'
  task page_thumbs: :environment do
    pages = Page.all.order(updated_at: :desc).last(20)
    pages.map(&:touch)
  end
end
