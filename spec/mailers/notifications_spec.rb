require 'spec_helper'

describe Notifications do
  describe '#forgot_password' do
    before :each do
      @email = 'mike@nubgames.com'
    end
    it 'sets the recipient' do
      email = Notifications.forgot_password(@email, 'foo').deliver
      expect(email.to).to eq [@email]
    end

    it 'adds the password to the body' do
      email = Notifications.forgot_password(@email, 'foo').deliver
      expect(email.body.to_s).to include 'foo'
    end

    it 'sets the correct subject' do
      email = Notifications.forgot_password(@email, 'foo').deliver
      expect(email.subject).to eq 'Library a la Carte Message'
    end
  end
end