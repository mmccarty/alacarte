# == Schema Information
#
# Table name: users
#
#  id            :integer          not null, primary key
#  name          :string(255)      default(""), not null
#  hashed_psswrd :string(255)      default(""), not null
#  email         :string(255)      default(""), not null
#  salt          :string(255)      default(""), not null
#  role          :string(255)      default("author"), not null
#  node_id       :integer
#

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
