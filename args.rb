#!/usr/bin/env ruby

def some_method(a, b, *p, g)
  puts a="#{a}"
  puts b="#{b}"
  puts p="#{p}"
  puts g="#{g}"
end

some_method(25,35,45,'qwe',55)
