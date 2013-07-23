require 'faker'

FactoryGirl.define do
  factory :feed do
    label { Faker::Lorem.word }
    url 'http://foo.bar.com'
  end
end