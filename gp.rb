#!/usr/bin/env ruby

require 'pg'
require 'yaml'

$conf=YAML::load(File.read('config.yaml'))

con = PG.connect(host: $conf['db_host'], dbname: $conf['db_name'], user: $conf['db_user'], password: $conf['db_pass'])
res = con.exec('select * from build_versions order by build_version desc limit 10')

fields = res.fields

fields.each do |f|
  printf "%-20s %s\n", "#{f}","#{res.field_values(f).to_s}"
end

con.close if con
