require 'faker'

FactoryGirl.define do
  factory :miscellaneous_resource do |resource|
    module_title { Faker::Lorem.sentence }
  end
end
