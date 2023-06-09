FactoryBot.define do
  factory :template_schema do
    body { { test: 'test' }.to_yaml }
    ui_schema { { test: 'test' }.to_yaml }
    team
    template
  end
end
