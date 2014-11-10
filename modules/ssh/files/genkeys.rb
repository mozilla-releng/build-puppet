# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

require 'optparse'
require 'pathname'
require 'fileutils'

workdir = Pathname.new('.')
output = STDOUT

optparser = OptionParser.new do |o|
    o.on('-o', '--output FILE', "publickey_logon.ini file") do |f|
        output = File.new(f, File::CREAT|File::TRUNC|File::WRONLY)
    end
end

optparser.parse!

# KTS's publickey_logon.ini is, in essence, a map from (username, key) ->
# (username, password) where the usernames must match.  It is formatted as an
# ini file with a single section and keys named with integer suffixes from 0 to
# 1023.  See
# https://github.com/djmitche/kts/blob/master/session/KPublickeyLogon.hxx#L74
# for the code that reads this file.

output.write "[KPublickeyLogon]\n\n"
i = 0
workdir.children.select { |c| c.extname == '.pass' }.each do |c|
    username = "#{c.basename(c.extname)}"
    password = File.read(c).strip

    keyfile = Pathname.new("#{username}.keys")
    next unless keyfile.file?
    File.readlines(keyfile).each do |keyline|
        raise "too many keys (KTS has a hard limit of 1024)" if i > 1024
        key = keyline.split()[1]
        output.write "publickey#{i} = #{key}\nusername#{i} = #{username}\npassword#{i} = #{password}\n\n"
        i += 1
    end
end
