require 'faker'

FactoryGirl.define do
  factory :rss_resource do
    module_title { Faker::Lorem.sentence }
  end
end