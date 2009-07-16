#!/usr/bin/env ruby

good = 0
bad = 0
for cnt in 1..200
  if `bin/primes 2000 -H localhost,localhost` =~ /303\sprimes\sfound/
    good += 1
    putc '.'
  else
    bad += 1
    putc 'x'
  end
  puts " #{cnt}" if (cnt % 50) == 0
  STDOUT.flush
end
puts
puts "good: #{good}"
puts "bad:  #{bad}"
