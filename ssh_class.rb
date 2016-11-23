#!/usr/bin/env ruby

require 'rubygems'
require 'net/ssh'
require 'yaml'
require 'colorize'

$conf=YAML::load(File.read('config.yaml'))

class Run_via_ssh
  attr_reader :hostname, :username
  @@count_hosts_run = 0
  @@hosts = Array.new 
  def initialize(hostname, username=$conf['ssh_user_def'], password=$conf['ssh_pass_def'])
    @hostname, @username, @password = hostname, username, password
  end
 
  
  def run_cmd(cmds)
    @cmds = cmds
    begin
      ssh = Net::SSH.start(@hostname, @username, :password => @password) 
      @cmds.each do |step, commands|
        printf "#{step}: ".green
        puts "#{commands}"
        commands.each do |cmd|
          line = '#'*4+'#'*cmd.length
          puts line
          puts '#'" #{cmd} "'#'
          puts line
          puts
          res = ssh.exec!(cmd)
          puts "#{res}".yellow
        end
      end
    ssh.close
    @@count_hosts_run += 1
    @@hosts << @hostname
    rescue
      pass_hidden = '*'*@password.length
      puts "Unable to connect to #{@hostname} using #{@username}/#{pass_hidden}"
    end
  end

  def self.each_node_run(nodes, cmds)
    @nodes = nodes
    @nodes.each do |node|
      puts "NODE: #{node}".green
      Run_via_ssh.new(node).run_cmd(cmds)
      puts
    end
  end

  def self.gen_names(subdomains)
    pref='fedbst.'
    suff='.mydom.org'
    subdomains.map{|elem| pref + elem.to_s + suff }
  end

  def self.print_report
    puts "REPORT".blue
    puts "*We have created #{@@count_hosts_run} object(s).".green 
    puts "*We have run commands on the following hosts:".green
    @@hosts.uniq!
    @@hosts.each {|host| puts " ""#{host}" } 
  end

end

nodes = Run_via_ssh.gen_names(['ab', 'ta'])

puts "Running using each_node_run".blue
Run_via_ssh.each_node_run(nodes, $conf['run_via_ssh1'])
Run_via_ssh.each_node_run(nodes, $conf['run_via_ssh2'])

puts "Running using Run_via_ssh instance".blue
n = Run_via_ssh.new('be1.mydom', 'yaatest', 'yaatestpass')
n.run_cmd({ "RUNNING ON #{n.hostname} for user #{n.username}":  ['echo $HOME']})

puts "First way to get @hostname and @username vars".blue
hostname='be1.mydom'
username='yaatest'
password='yaatestpass'
Run_via_ssh.new(hostname, username, password).run_cmd({ "RUNNING ON #{hostname} for user #{username}":  ['echo $HOME']})

puts "Second way to get @hostname and @username vars".blue
( n = Run_via_ssh.new('be2.mydom')).run_cmd({ "RUNNING ON #{n.hostname} for user #{n.username}":  ['echo $HOME']})

#load 'include'

Run_via_ssh.print_report
