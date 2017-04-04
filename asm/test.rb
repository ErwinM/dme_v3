


out = File.open("tessie.bin", "w+")

ar =[0xaabb, 0xccdd, 0xeeff, 0xbabe, 0xcafe]

ar.each do |a|
  a=[a]
  out.write(a.pack("n"))
end
out.close


