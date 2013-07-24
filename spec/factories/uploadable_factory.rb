require 'faker'

FactoryGirl.define do
  factory :uploadable do
    upload_file_name { Faker::Lorem.word }
  end
end