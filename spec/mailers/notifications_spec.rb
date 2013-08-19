require 'spec_helper'

describe Notifications do
  describe '#forgot_password' do
    before :each do
      @email = 'test@nubgames.com'
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

  describe '#forgot' do
    before :each do
      @email = 'test@nubgames.com'
    end
    it 'sets the recipient' do
      email = Notifications.forgot(@email, '1', '2', 'foo.com').deliver
      expect(email.to).to eq [@email]
    end

    it 'adds the url to the body' do
      email = Notifications.forgot(@email, '1', '2', 'foo.com').deliver
      expect(email.body.to_s).to include 'foo.com'
    end

    it 'sets the correct subject' do
      email = Notifications.forgot(@email, '1', '2', 'foo.com').deliver
      expect(email.subject).to eq 'Library Tutorial Message'
    end
  end

  describe '#share_module' do
    before :each do
      @email = 'test@nubgames.com'
    end
    it 'sets the recipient' do
      email = Notifications.share_module(@email, 'me@nubgames.com', 'mymod', 'Me').deliver
      expect(email.to).to eq [@email]
    end

    it 'sets the from' do
      email = Notifications.share_module(@email, 'me@nubgames.com', 'mymod', 'Me').deliver
      expect(email.from).to eq ['me@nubgames.com']
    end

    it 'adds the name to the body' do
      email = Notifications.share_module(@email, 'me@nubgames.com', 'mymod', 'Me').deliver
      expect(email.body.to_s).to include 'Me'
    end

    it 'sets the correct subject' do
      email = Notifications.share_module(@email, 'me@nubgames.com', 'mymod', 'Me').deliver
      expect(email.subject).to eq 'Shared Library a la Carte Module'
    end
  end

  describe '#send_message' do
    before :each do
      @email = 'test@nubgames.com'
    end
    it 'sets the recipient' do
      email = Notifications.send_message(@email, 'me@nubgames.com', 'message body', 'subject').deliver
      expect(email.to).to eq [@email]
    end

    it 'sets the from' do
      email = Notifications.send_message(@email, 'me@nubgames.com', 'message body', 'subject').deliver
      expect(email.from).to eq ['me@nubgames.com']
    end

    it 'adds the name to the body' do
      email = Notifications.send_message(@email, 'me@nubgames.com', 'message body', 'subject').deliver
      expect(email.body.to_s).to include 'message body'
    end

    it 'sets the correct subject' do
      email = Notifications.send_message(@email, 'me@nubgames.com', 'message body', 'subject').deliver
      expect(email.subject).to eq 'subject'
    end
  end

  describe '#add_user' do
    before :each do
      @email = 'test@nubgames.com'
    end
    it 'sets the recipient' do
      email = Notifications.add_user(@email, 'me@nubgames.com', 'pass', 'foo.com').deliver
      expect(email.to).to eq [@email]
    end

    it 'sets the from' do
      email = Notifications.add_user(@email, 'me@nubgames.com', 'pass', 'foo.com').deliver
      expect(email.from).to eq ['me@nubgames.com']
    end

    it 'adds the password to the body' do
      email = Notifications.add_user(@email, 'me@nubgames.com', 'pass', 'foo.com').deliver
      expect(email.body.to_s).to include 'pass'
    end

    it 'sets the correct subject' do
      email = Notifications.add_user(@email, 'me@nubgames.com', 'pass', 'foo.com').deliver
      expect(email.subject).to eq 'Library a la Carte Message'
    end
  end

  describe '#accept_nonsso_pending_user' do
    before :each do
      @email = 'test@nubgames.com'
    end
    it 'sets the recipient' do
      email = Notifications.accept_nonsso_pending_user(@email, 'me@nubgames.com', 'pass', 'foo.com').deliver
      expect(email.to).to eq [@email]
    end

    it 'sets the from' do
      email = Notifications.accept_nonsso_pending_user(@email, 'me@nubgames.com', 'pass', 'foo.com').deliver
      expect(email.from).to eq ['me@nubgames.com']
    end

    it 'adds the password to the body' do
      email = Notifications.accept_nonsso_pending_user(@email, 'me@nubgames.com', 'pass', 'foo.com').deliver
      expect(email.body.to_s).to include 'pass'
    end

    it 'sets the correct subject' do
      email = Notifications.accept_nonsso_pending_user(@email, 'me@nubgames.com', 'pass', 'foo.com').deliver
      expect(email.subject).to eq 'Your Library ala Carte Account has been approved'
    end
  end

  describe '#notify_admin_about_pending_user' do
    before :each do
      @email = 'test@nubgames.com'
    end
    it 'sets the recipient' do
      email = Notifications.notify_admin_about_pending_user(@email, 'me@nubgames.com', 'foo.com').deliver
      expect(email.to).to eq [@email]
    end

    it 'sets the from' do
      email = Notifications.notify_admin_about_pending_user(@email, 'me@nubgames.com', 'foo.com').deliver
      expect(email.from).to eq ['me@nubgames.com']
    end

    it 'adds the url to the body' do
      email = Notifications.notify_admin_about_pending_user(@email, 'me@nubgames.com', 'foo.com').deliver
      expect(email.body.to_s).to include 'foo.com'
    end

    it 'sets the correct subject' do
      email = Notifications.notify_admin_about_pending_user(@email, 'me@nubgames.com', 'foo.com').deliver
      expect(email.subject).to eq 'Library ala Carte Message - Pending User Notification'
    end
  end
end