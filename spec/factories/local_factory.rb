# == Schema Information
#
# Table name: locals
#
#  id               :integer          not null, primary key
#  banner_url       :string(255)
#  logo_url         :string(255)
#  styles           :string(255)
#  lib_name         :string(255)
#  lib_url          :string(255)
#  univ_name        :string(255)
#  univ_url         :string(255)
#  footer           :text
#  image_map        :text
#  ica_page_title   :string(255)      default("Get Help with a Class")
#  guide_page_title :string(255)      default("Get Help with a Subject")
#  logo_width       :integer
#  logo_height      :integer
#  proxy            :string(255)
#  admin_email_to   :string(255)
#  admin_email_from :string(255)
#  left_box         :text
#  js_link          :string(255)
#  meta             :text
#  tracking         :text
#  guide_box        :text
#  right_box        :text
#

require 'faker'

FactoryGirl.define do
  factory :local do
    banner_url 'http://foo.bar.com'
  end
end
