require 'faker'

FactoryGirl.define do
  factory :student do
    firstname { Faker::Lorem.word }
    lastname {Faker::Lorem.word }
    email 'foo@bar.com'
    onid {Faker::Lorem.word }
    sect_num {Faker::Lorem.word }
    tutorial_id 1
  end
end