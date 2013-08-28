require 'faker'

FactoryGirl.define do
  factory :user do
    pass = Faker::Lorem.characters 14

    name  { Faker::Internet.user_name }
    email { Faker::Internet.email }

    salt { Faker::Lorem.characters 4 }
    password pass
    password_confirmation pass

    factory :author

    factory :admin do
      role 'admin'
    end
  end
end