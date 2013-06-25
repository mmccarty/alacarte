require 'faker'

FactoryGirl.define do
  factory :user do |user|
    user.name  { Faker::Name.name      }
    user.email { Faker::Internet.email }

    user.salt 'salt'
    user.password 'password'
    user.password_confirmation 'password'
  end

  factory :admin, :class => :user do |user|
    user.name  { Faker::Name.name      }
    user.email { Faker::Internet.email }

    user.salt 'salt'
    user.password 'password'
    user.password_confirmation 'password'

    user.role 'admin'
  end
end
