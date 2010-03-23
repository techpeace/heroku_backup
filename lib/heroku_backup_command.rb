=begin
  Copyright (c) 2009 Matthew Buck.

  This file is part of Heroku Backup Command.

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
=end

module Heroku::Command
  class Backup < BaseWithApp
    def latest_bundle_name(app)
      %x{ heroku bundles #{app_option(app)}| cut -f 1 -d ' ' }.chomp
    end

    def app_option(app)
      '--app ' + app if app
    end

    def app_name(app)
      return app if app

      %x{heroku info}.split("\n")[0].split(' ')[1]
    end

    #desc "Capture a new bundle and back it up to S3."
    #task :backup, :app do |t, args|
    def index
      display(selected_application)
    end
  end
end
