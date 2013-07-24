require 'faker'

FactoryGirl.define do
  factory :url_resource do
    module_title { Faker::Lorem.sentence }
  end
end