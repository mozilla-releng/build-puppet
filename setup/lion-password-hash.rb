require 'digest/sha2'

puts "enter password"
password = gets.chomp
seedint = rand(2**31 - 1)
seedstring = Array(seedint).pack("L")
saltedpass = Digest::SHA512.digest(seedstring + password)
puts (seedstring + saltedpass).unpack('H*')[0]
