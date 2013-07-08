require 'faker'

FactoryGirl.define do
  factory :guide do
    guide_name { Faker::Lorem.sentence }

    factory :published_guide do
      published true
    end
  end
end
