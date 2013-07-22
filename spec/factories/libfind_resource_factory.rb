require 'faker'

FactoryGirl.define do
  factory :libfind_resource do
    module_title { Faker::Lorem.sentence }
  end
end