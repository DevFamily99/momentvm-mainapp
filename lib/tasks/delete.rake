namespace :delete do
  desc "TODO"
  task stuff: :environment do
    sql = "drop table publishing_manifests cascade"
    ActiveRecord::Base.connection.execute(sql)

    sql = "delete from schema_migrations  where version in ('20190510172325')"
    ActiveRecord::Base.connection.execute(sql)
  end

  task publishing_events_countries: :environment do
    sql = "alter table \"publishing_events\" drop column \"countries\""
    ActiveRecord::Base.connection.execute(sql)
  end

  task type_on_publishing_event: :environment do
    sql = "alter table \"publishing_events\" rename column \"type\" to \"category\""
    ActiveRecord::Base.connection.execute(sql)
  end

  task page_module_page_id: :environment do 
    sql = "alter table \"page_modules\" drop column \"page_id\""
    ActiveRecord::Base.connection.execute(sql)
  end




end
