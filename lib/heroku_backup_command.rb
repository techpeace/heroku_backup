=begin
  Copyright (c) 2010 Matt Buck.

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
    def app_option
      '--app ' + @app
    end

    def latest_bundle_name
      %x{ heroku bundles #{app_option}| cut -f 1 -d ' ' }.chomp
    end

    # Capture a new bundle and back it up to S3.
    def index
      require 'erb'

      # Warn that we're about to blow out the latest bundle.
      print 'WARNING: This will destroy the most recent bundle.  Do you wish to proceed? (y/n) '
      answer = STDIN.gets.chomp
      exit unless answer == 'y'

      display "===== Deleting most recent bundle from Heroku..."

      %x{ heroku bundles:destroy #{latest_bundle_name} #{app_option} }

      display "===== Capturing a new bundle..."

      %x{ heroku bundles:capture #{app_option} }

      while %x{ heroku bundles #{app_option} | grep complete }.empty?
        sleep 10
      end

      display "===== Downloading new bundle..."

      %x{ heroku bundles:download #{app_option} }

      display "===== Pushing the bundle up to S3..."

      # Establish a connection to S3.
      aws_creds =  YAML::load(ERB.new(File.read(File.join(Dir.getwd, 'config', 'amazon_s3.yml'))).result)["default"]

      AWS::S3::Base.establish_connection!(
        :access_key_id     => aws_creds["access_key_id"],
        :secret_access_key => aws_creds["secret_access_key"]
      )

      bundle_file_name = @app + '.tar.gz'

      AWS::S3::S3Object.store(latest_bundle_name + '.tar.gz', open(bundle_file_name), s3_bucket)

      puts "===== Deleting the temporary bundle file..."

      FileUtils.rm(bundle_file_name)
    end
      
    private
    
      def s3_bucket
        retries = 1
        begin
          return @app + '-backups' if AWS::S3::Bucket.find(@app + '-backups')
        rescue AWS::S3::NoSuchBucket
          AWS::S3::Bucket.create(@app + '-backups')
          retry if retries > 0 && (retries -= 1)
        end
      end
      
  end
end
