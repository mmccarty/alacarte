require 'faker'

FactoryGirl.define do
  factory :uploader_resource do
    module_title { Faker::Lorem.sentence }
  end
end