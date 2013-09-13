# == Schema Information
#
# Table name: dods
#
#  id          :integer          not null, primary key
#  visible     :boolean          default(TRUE)
#  title       :string(255)      not null
#  url         :string(255)      not null
#  startdate   :string(255)      default("unknown")
#  enddate     :string(255)      default("unknown")
#  provider    :string(255)      default(""), not null
#  providerurl :string(255)
#  proxy       :boolean          default(FALSE)
#  brief       :string(255)
#  descr       :text
#  fulltxt     :string(255)
#  illreq      :string(255)
#  fssub       :string(255)
#  other       :string(255)
#

require 'faker'

FactoryGirl.define do
  factory :dod do
    title    { Faker::Company.catch_phrase }
    url      { Faker::Internet.url         }
    provider { Faker::Company.name         }
    descr    { Faker::Company.bs           }
  end
end
