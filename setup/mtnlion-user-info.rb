# Get the password information for an existing user.  After updating a password
# with 'passwd', run this as:
#   ruby mtnlion-user-info.rb <username>
require 'facter/util/plist'

user = ARGV[0]

puts "username : #{user}"
users_plist = Plist::parse_xml(`plutil -convert xml1 -o /dev/stdout /var/db/dslocal/nodes/Default/users/#{user}.plist`)
password_hash_plist = users_plist['ShadowHashData'][0].string
IO.popen('plutil -convert xml1 -o - -', mode='r+') do |io|
  io.write password_hash_plist
  io.close_write
  @converted_plist = io.read
end


converted_hash_plist = Plist::parse_xml(@converted_plist)
password_stuff = converted_hash_plist['SALTED-SHA512-PBKDF2']
puts "iterations : #{password_stuff['iterations']}"
puts "salt : #{password_stuff['salt'].string.unpack("H*")[0]}"
puts "password : #{password_stuff['entropy'].string.unpack("H*")[0]}"
