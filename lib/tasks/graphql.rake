require "graphql/rake_task"

# According to the graphql-ruby docs this should generate a schema dump
namespace :graphql do
  desc 'TODO'
  namespace :schema do
    task dump: :environment do
    GraphQL::RakeTask.new(schema_name: "content_management_schema")
    end
  end
end