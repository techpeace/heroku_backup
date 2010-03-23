=begin
  Copyright (c) 2009, 2010 Matt Buck.

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

Heroku::Command::Help.group('Backup Command') do |group|
  group.command('backup', 'deletes the current bundle, captures a new one, and uploads it to S3')
end
