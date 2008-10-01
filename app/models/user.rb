require 'digest/sha1'

class User < ActiveRecord::Base
has_and_belongs_to_many :resources
has_and_belongs_to_many :pages, :include => 'page_resources', :order => 'position'
has_and_belongs_to_many :guides

  validates_presence_of  :name, :email, :password, :password_confirmation, :salt, :role                   
  validates_length_of :name, :within => 2..54
  validates_length_of :password, :within => 5..54
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => "Invalid email"  
  validates_uniqueness_of  :email
  
  attr_accessor :password_confirmation
  validates_confirmation_of :password
  
#protect these attributes so they can not be set with a POST request  
  attr_protected :id, :salt, :role 
  
#check that the password has been set 
  def validate
    errors.add_to_base("Missing password" ) if hashed_psswrd.blank?
  end
  
#return a user if they are hashed password matches the one stored for that user in the database  
  def self.authenticate(email, password)
    user = self.find_by_email(email)
    if user
      expected_password = encrypt(password, user.salt)
      if user.hashed_psswrd != expected_password
        user = nil
      end
    end
    user
  end

#create instance variable for password  
  def password
    @password
  end

#set the variable 'password' and store the encrypted version
  def password=(pwd)
    @password = pwd
    self.salt = User.random_string(10) if !self.salt?
    self.hashed_psswrd = User.encrypt(self.password, self.salt)
  end
 
#generate a new random password, change the users password to the new password, and email new password to the user
def set_new_password
    new_pass = User.random_string(10)
    self.password = self.password_confirmation = new_pass
    self.save    
    Notifications.deliver_forgot_password(self.email, self.password)
end 

#add a page to the HABTM relationship
def add_page(page)
   pages << page
end

def add_guide(guide)
   guides << guide
end


#add a resource to the HABTM relationship
def add_resource(resource)
    resources << resource
end

def add_profile(mid)
  self.rid = nil
  if mid
   self.update_attribute('rid', mid)\
 end
end

#get the users modules through resources
def modules(s = nil, reverse = nil)
    sortable = s || 'label'
    reverse = reverse || 'false'
    mods = resources.collect { |a| a.mod }
    unless mods.empty?
      mods = mods.sort! {|a,b|  a.send(sortable) <=> b.send(sortable)} 
      unless  reverse == 'true'
        mods = mods.reverse
      end
    end  
    return mods.uniq
end 


def find_resource(id, type)
   self.resources.find_by_mod_id_and_mod_type(id, type)
end

def contact_resources
  contacts =[]
  resources.each do |res|
    mod = res.mod
   if mod.content_type == "Librarian Profile" || mod.content_type == "Custom Content" || mod.content_type == "Course Widget" 
      contacts << res 
   end
 end
 return contacts
end

def is_admin
 return self.role == 'admin'
end


private
#create a unique salt value, combine it with the plaintext password into a single string, and
#then run an SHA1 digest on the result, returning a 40 character string of hex digits
  def self.encrypt(password, salt)
    string_to_hash = password + salt
    Digest::SHA1.hexdigest(string_to_hash)
  end
 
  
#generate a random password consisting of strings and digits, returning a newpassword of length equal
#to parameter len
  def self.random_string(len)
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    newpass = ""
    1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
    return newpass
  end
  
 
end
