# Purge data from the database
namespace :purge do
  desc 'clean prod database'
  task user_personal_data: :environment do
    users = User.all
    users.each do |user|
      user.password = ''
      user.salt = ''
      user.crypted_password = (0...50).map { ('a'..'z').to_a[rand(26)] }.join
      user.email = (0...50).map { ('a'..'z').to_a[rand(26)] }.join
      user.save
    end
    puts 'Done'
  end

  desc 'Removes the admin admin from the database'
  task team_personal_data: :environment do
    Team.all.each do |team|
      team.owner_firstname = (0...50).map { ('a'..'z').to_a[rand(26)] }.join
      team.owner_lastname = (0...50).map { ('a'..'z').to_a[rand(26)] }.join
      team.owner_email = (0...50).map { ('a'..'z').to_a[rand(26)] }.join
      team.save
    end
    puts 'Done'
  end

  desc 'Removes the admin admin from the database'
  task admin: :environment do
    admin = User.find_by(email: 'admin')
    if admin.nil?
      puts 'No user with email admin found'
      exit
    end
    puts 'Found an user with email admin'
    puts 'Deleted user:'
    admin.destroy
  end

  desc 'Remove users and create dummy ones'
  task users: :environment do
    puts '====== REMOVING ALL USERS ======'
    users = User.all
    users.destroy_all
    puts "====== ALL USERS REMOVED - total: #{users.count} users deleted ======"
    puts '====== CREATING DUMMY USERS ======'
    [
      { email: 'super@admin.com', password: 'password', password_confirmation: 'password', team_id: Team.first.id, app_admin: true },
      { email: 'user@admin.com', password: 'password', password_confirmation: 'password', team_id: Team.first.id }
    ].each do |user_params|
      puts "\t\tUSER CREATED WITH CREDENTIALS: #{user_params}" if User.create(user_params)
    end
    puts '====== DUMMY USERS CREATED ======'
  end

  desc 'Remove all teams but the MOMENTVM team'
  task teams: :environment do
    puts '====== REMOVING SENSITIVE DATA ======'
    teams = Team.all
    teams.each do |team|
      next if team.name == 'MOMENTVM'

      team.client_id = ''
      team.client_secret = ''
      team.save
    end
  end

  desc 'Delete old data'
  task remove_data: :environment do
    puts '====== REMOVING PAGES WHICH ARE OLDER THAN ONE MONTH ======'
    pages = Page.where('created_at < ?', 3.months.ago)
    pages.destroy_all
    puts "====== PAGES REMOVED - total: #{pages.count} pages deleted ======"

    puts '====== REMOVING 80% OF FIRST PAGE ACTIVITIES ======'
    activities = PageActivity.limit(PageActivity.all.count * 80 / 100)
    activities.destroy_all
    puts "====== PAGE ACTIVITIES REMOVED - total: #{activities.count} page activities deleted ======"

    puts '====== REMOVING 80% OF FIRST PAGE VIEWS ======'
    page_views = PageView.limit(PageView.all.count * 80 / 100)
    page_views.destroy_all
    puts "====== PAGE VIEWS REMOVED - total: #{page_views.count} page views deleted ======"

    puts '====== REMOVING 90% OF FIRST VERSIONS ======'
    versions = PaperTrail::Version.limit(PaperTrail::Version.all.count * 90 / 100)
    versions.destroy_all
    puts "====== VERSIONS REMOVED - total: #{versions.count} versions deleted ======"
  end

  task test: :environment do
    pages = Page.where('created_at < ?', 1.month.ago)
    pages.each do |page|
      page.page_modules.each(&:destroy)
      page.thumbnail&.destroy
      page.destroy
    end
    activities = PageActivity.where('created_at < ?', 1.month.ago)
    activities.each(&:destroy)
  end
end
