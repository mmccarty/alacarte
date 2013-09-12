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

class Dod < ActiveRecord::Base
  validates :title,
    :presence => { :message => _('may not be blank!') },
    :uniqueness => {  :message => _('{{value}} is already being used!') }

  validates :url, :presence => { :message => _('may not be blank!') }
  validates :provider, :presence => { :message => _('may not be blank!') }
  validates :descr, :presence => { :message => _('may not be blank!') }

  def self.sort(sort=nil)
    unless sort==nil
      where("title LIKE ?", "#{sort}")
    else
      order("title")
    end
  end

  def coverage_label
    return startdate + ' - ' + enddate
  end
end
