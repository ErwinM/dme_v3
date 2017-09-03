# peasant mult algorithm

a = 0x800
b = 0x1e

if a > b then
  x = b
  y = a
else
  x = a
  y = b
end

result = 0

puts "#{x} - #{y} (#{x%2}) -> #{result}\n"

while (x > 1) do
  unless (x % 2) == 0 then result += y end
  x = x / 2
  y = y * 2
  #unless (x % 2) == 0 then result += y end
  puts "#{x} - #{y} (#{x%2}) -> #{result}\n"
end
unless (x % 2) == 0 then result += y end

puts result.to_s(16)