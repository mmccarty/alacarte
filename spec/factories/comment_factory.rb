require 'faker'

FactoryGirl.define do
  factory :comment do
    body "Hi, I'm a comment!"
    author_email { Faker::Internet.email }
  end
end
