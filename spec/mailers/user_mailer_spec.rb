require 'spec_helper'

describe UserMailer do
  describe '#forgot_password' do
    before :each do
      @email = 'mike@nubgames.com'
    end
    it 'sets the recipient' do
      email = UserMailer.forgot_password(@email, 'foo').deliver
      expect(email.to).to eq [@email]
    end

    it 'adds the password to the body' do
      email = UserMailer.forgot_password(@email, 'foo').deliver
      expect(email.body.to_s).to include 'foo'
    end

    it 'sets the correct subject' do
      email = UserMailer.forgot_password(@email, 'foo').deliver
      expect(email.subject).to eq 'Library a la Carte Password'
    end
  end
end
