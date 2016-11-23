#!/usr/bin/env ruby

require 'open3'
require 'yaml'
require 'colorize'

$conf=YAML::load(File.read('config.yaml'))

def run_local_cmds(cmds)
  cmds.each do |step, commands|
    printf "RUNNING #{step}: ".green
    puts"#{commands}"
    puts
    commands.each do |cmd|
      line = '#'*4+'#'*cmd.length
      puts line
      puts '#'" #{cmd} "'#'
      puts line
      Open3.popen3(cmd) do |stdin, stdout, stderr, thread|
        pid = thread.pid
        puts
        puts stdout.read.chomp.yellow
        puts
      end
    end
  end
end

run = $conf['run_on_localhost']
run_local_cmds(run)

