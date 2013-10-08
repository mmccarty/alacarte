[![Build Status](https://travis-ci.org/terrellt/alacarte.png?branch=3.x-bugfix)](https://travis-ci.org/terrellt/alacarte)

A Brief History
---------------

History is important to give credit where it is due, and also because
the licensing is a bit convoluted.

The Interactive Course Assignment Pages (ICAP) project was started
in 2007 at the Oregon State University Libraries and Press by
Kimberly Griggs. In 2008, ICAP was rebranded to Library a la Carte.
Early versions were released under the GPL and are available from
RubyForge and the rubyforge branch of our git repository. See:

- https://rubyforge.org/projects/alacarte/
- https://github.com/nubgames/alacarte/tree/rubyforge

Version 1.5 was released under the GNU Affero Public License. That
release is available both from the original developer's GitHub page
and the griggsk branch of our source tree. See:

- https://github.com/griggsk/Library-a-la-Carte
- https://github.com/nubgames/alacarte/tree/griggsk

In December 2012, OSU released version 1.6 and declared a la Carte
abandonware. With the 1.6 release, the license reverted to GPL3. See:

- http://alacarte.library.oregonstate.edu/node/25416

The 1.6 release is available both at RubyForge and the v1.6 tag on
GitHub.  See:

- https://github.com/griggsk/Library-a-la-Carte
- https://github.com/nubgames/alacarte/releases/tag/v1.6

Nub Games, Inc. adopted the project in 2013.  We have restored the
AGPL for our contributions, as is allowed under the terms of the
GPL.  (You must make the source available for any improvements you
might make).

Versions
--------

We have changed the version scheme to loosely follow Rails.  Version
2 is the last version we will release for the Rails 2.x series.  It
differs from version 1.6 only in being made current with Rails 2.3.x
and is end-of-life.

Most of our work so far has been focused on bringing version 3
up-to-date with the Rails 3.x series.  We have also completely
revamped the UI, using Bootstrap to provide a more modern look-and-feel,
both for patrons and librarians.  Importantly, however, version 3
has no schema changes relative to versions 1.6 and 2.0, so users
of earlier versions can upgrade with a drop-in replacement.

We plan continue to maintain version 3 for a few years, but new
development efforts will focus on version 4 using Rails 4.

| Alacarte | Rails  | Ruby  | License |
| -------- | ------ | ----- | ------- |
| 1.5      | 2.3.5  | 1.8.7 | AGPL    |
| 1.6      | 2.3.5  | 1.8.7 | GPL3    |
| 2.0      | 2.3.18 | 1.8.7 | AGPL    |
| 3.0      | 3.2.14 | 1.9.3 | AGPL    |
| 4.0      | 4.0    | 2.0   | AGPL    |

Status
------

Version 2 is available and ready for use:

- https://github.com/nubgames/alacarte/releases/tag/v2.0

Version 3 is coming along, but is not yet feature-complete.  Most
notably, tutorials are not available in the current development
snapshot.  Everything else is in good shape, and we expect to restore
tutorials soon.

You can see a demo of the current development version running on
our main documentation site:

- http://docs.nubgames.com/

Bugs
----

Please submit bugs to our GitHub issue tracker:

- https://github.com/nubgames/alacarte/issues

Contributing
------------

We're always happy to accept contributions.  Send us a pull request.

Hosting
-------

We can provide hosting services, if for any reason it is not practical
for you to run Alacarte locally.  Contact us at support@nubgames.com
and we will set things up for you.

We'll also work with you to migrate your data from any previous
content management system you may be using.

Install
-------

Step 0. Install rails and dependencies.

  0.1 Install ruby 1.9.3 or later.  (We recommend using rbenv.)
  0.2 gem install bundler
  0.3 bundle install

Step 1. Create the Databases.

	1.1 Create the following databases in MySQL:

	    alacarte_development
	    alacarte_test
	    alacarte_production

	    (Be sure to use those names -or whichever names you choose in database.yml)

	1.2 Edit the file config/database.yml.example

	Copy config/database.yml.example to config/database.yml and edit to reflect your mysql databases and database settings.
	 Verify that the names for database in database.yml match the databases you created in step 1.1

	1.3 In the root directory of your application, run the following command:

	    rake db:schema:load
	    This will run the initial migration to populate alacarte_development.
	    Unless Library a la Carte is run in production mode the application uses the development database.

	    OPTIONAL
	    rake db:schema:load RAILS_ENV=production
	    This will run the initial migration to populate alacarte_production

	    rake db:schema:load RAILS_ENV=test
	    This will run the initial migration to populate alacarte_test

	You *should* see messages scrolling by indicating tables have been created.
    If you have any errors in your DB, you will see them now.

Step 2. Configure Environments Variables

	Open the configuration folder: config/

	2.1 Add Action Mailer variables

	 edit config/initializers/smtp_settings.rb

	 You will need to specify some additional configuration to tell ActionMailer which server will handle your outgoing e-mail.

	2.2 Add error notification settings

	  edit config/initializers/error_notification.rb

	  Add email address where you want error notifications sent to.  Add the email address in between the parentheses %w()
	  ExceptionNotification::Notifier.exception_recipients = %w(user@email.edu).
	  All 500 errors that occur in Library a la Carte will be logged and emailed to this address.
	  Note: You may see errors, due to robots crawling protected pages.

Step 3.OPTIONAL: Edit and Batch load course subjects, research departments, and database subscription:

   Use this method to batch load data at install. Optionally, enter data by using Library a la Carte admin tools.
   See this documentation on entering data in the tool. http://alacarte.library.oregonstate.edu/support.

    OPTION 1: Edit and add data

    edit: lib/subjects.txt

	Edit the course subject codes to reflect the codes specific to your institution.
	The codes in subjects.txt by default are specific to Oregon State University
	courses.  The file format is subject code then tab then subject name, one per line; use subjects.txt as an example.

	edit: lib/masters.txt

	Edit the master subjects to reflect the general subjects for your institution.
	The values in masters.txt by default are specific to Oregon State University
	departments.  The file format is one subject value per line; use masters.txt as an example.

	edit: lib/dods.txt

	Edit the database of database (dod) file to add your own database subscriptions.
	The values in dods.txt are open access databases selected by OSU librarians.
	The file format is one database per line with comma seperated values.
	See this documentation http://alacarte.library.oregonstate.edu/support and use dods.txt as an example.

    OPTION 2: Batch Load data

	 run: script/batchload_data
	 or
	 ruby script/batchload_data

	 This will populate the subjects and masters table with the values found in lib/subjects.txt and lib/masters.txt respectively.

     OPTION 3: batch load database subscription data
     Required for database module: Either run this script and/or enter information through the admin tool.

     run: script/batchload_dods
     or
     ruby script/batchload_dods

Step 4. OPTIONAL: Module Configuration

    Create attachment folders and enable read/write access privileges for attachment folders: public/uploads, public/photos
    Required if you plan on enabling the attachment module or the image manager to allow users to upload documents and images.

    Unix Command:
	   mkdir /path/to/public/uploads
	   mkdir /path/to/public/photos

       chmod -R g+w /path/to/public/uploads
       chmod -R g+w /path/to/public/photos

Step 6. Run the install script.

	In the root directory of the application, type:

	    script/install_admin
	    or
		ruby script/install_admin
	This will  create the default admin user:

	    login: admin@your-domain.com
	    password: adm!n

Step 7. Test Library ala Carte Tool

	At this time the ala Carte tool should be installed.
	Navigate to the root of where you installed the code:  http://yourdomain.com/

    Login with the default admin account created above.
	Once logged in, change the password and email address, by clicking "My Account"

	An admin should use the admin tools to further customize the application. Please see this documentation for more info:
	Admin FAQ: http://alacarte.library.oregonstate.edu/support/admin_faq
	Customize Content Types: http://alacarte.library.oregonstate.edu/support/content_types
	Configure Module Types: http://alacarte.library.oregonstate.edu/support/enable_mods
	Customize Template: http://alacarte.library.oregonstate.edu/support/tut_template_customization
	Customization Map: http://alacarte.library.oregonstate.edu/support/tut_map_customization
	Customize Search: http://alacarte.library.oregonstate.edu/support/search_customization
	Manage Database Tables: http://alacarte.library.oregonstate.edu/support/config_db

Step 8. OPTIONAL: Move to production and deploy

8.1 If you have not already populated the production database:

	rake db:schema:load RAILS_ENV=production

	Optionally, you can dump the development database into the production database or
	edit database.yml and point the production environment variable to a populated database

8.2 If you populated a new production database in step 8.1:

	Repeat steps 3 and 5 to populate the production database.

8.3 Run in Production Mode

	Option 1: Set the Environment in Your .bash_login File on the Server
	The best way is to set the actual RAILS_ENV environment variable. Rails work best with the bash shell.

	 ~/.bashrc export RAILS_ENV="production"

	Option 2: Set the Environment in Your Web Server Config File
	If you can’t set the Rails environment variable in your shell, you must look for another way to do it.
	The next best place is in your web server configuration.

	Option 3: Edit environment.rb
	The final way to set the environment for a shared host is to uncomment the following line at the top of environment.rb:

	RAILS_ENV = 'production'

8.4 Deploy to production server

	OPTION 1: Mongrel

	Mongrel
	http://mongrel.rubyforge.org/

	Apache2, Mongrel Cluster on Fedora
	http://nlakkakula.wordpress.com/2007/07/19/setting-up-rails-production-server-using-apache2-mongrel-cluster-on-fedora-core-5/

	Mongrel and Apache
	http://tonyrose023.blogspot.com/2007/01/multiple-rails-apps-with-mongrel.html
	http://blog.codahale.com/2006/06/19/time-for-a-grown-up-server-rails-mongrel-apache-capistrano-and-you/

	Mongrel and Nginx
	http://itsignals.cascadia.com.au/?p=16
	http://www.slideshare.net/addame/montreal-on-rails-5-rails-deployment-193082

	OPTION 2: Passenger

	Apache and Passenger on Fedora
	http://fedoraphprails.blogspot.com/2009/08/how-to-use-apache-server-for-ruby-on.html

	Apache and Passenger
	http://www.modrails.com/documentation/Users%20guide%20Apache.html

	Nginx and Passenger
	http://www.modrails.com/documentation/Users%20guide%20Nginx.html

	Passenger Tips
	http://www.rubyinside.com/28_mod_rails_and_passenger_resources-899.html

	OPTION 3: Windows

	Rails on Windows
	http://hotgazpacho.org/2009/02/rails-230-iis7-fastcgi-rails-on-windows-ftw/
	http://mvolo.com/blogs/serverside/archive/2007/02/18/10-steps-to-get-Ruby-on-Rails-running-on-Windows-with-IIS-FastCGI.aspx
	http://ruslany.net/2008/08/ruby-on-rails-in-iis-70-with-url-rewriter/

Troubleshooting
---------------

Look at the Web Server Error Logs

	One of the best places to start troubleshooting are the web server’s error logs, especially when you are initially debugging your configuration.

	/log/development.log or /log/production.log

	Rails can’t start writing to .log files until it has launched, so Rails logging can’t help you if your initial setup has critical problems.
	File permission problems and other errors will show up in the web server’s access_log and may give you clues about what is going wrong.

Do Files Have the Correct Permissions?

	Here are a few important files and the permissions they must have:
	• The log directory and files must be writable by the user running the FastCGI or Mongrel process.
	• The public directory must be writable by the user running the FastCGI or Mongrel process if you are using page caching. Rails will run if the public directory is not writable but will not use caching.
	• dispatch.fcgi must be executable, but not writable by others.
	• index must be writable by the application
	• public/photo and public/photos and uploads must be RW (if using)

Are Current Versions of Necessary Files and Requirements Present?

	Is database.yml present and correct
	Are all the gems installed and the correct version

Has the Database Been Migrated to the Correct Version for Your
Application?

   Check that you have run the migration or initialized the database for the correct environment.  If you are running in production mode
   add RAILS_ENV="production" to rail's commands.

Is the server started?

   You must start and stop the web server to make changes to the application. If using Phusion, run touch/tmp/restart.txt.
