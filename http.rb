#!/usr/bin/env ruby

require 'socket' # Provides TCPServer and TCPSocket classes
require 'open3'
require 'yaml'
require 'colorize'

$conf=YAML::load(File.read('config.yaml'))
# Initialize a TCPServer object that will listen
# on localhost:2345 for incoming connections.
server = TCPServer.new('localhost', 9876)

def run_cmd(cmd)
  Open3.popen3(cmd) do |stdin, stdout, stderr, thread|
    pid = thread.pid
    puts
    out = stdout.read.chomp
    puts out
    return "#{out}\n"
  end
end

# loop infinitely, processing one incoming
# connection at a time.
loop do

  # Wait until a client connects, then return a TCPSocket
  # that can be used in a similar fashion to other Ruby
  # I/O objects. (In fact, TCPSocket is a subclass of IO.)
  socket = server.accept

  # Read the first line of the request (the Request-Line)
  request = socket.gets

  # Log the request to the console for debugging
  STDERR.puts request
  
  response = run_cmd($conf['http_cmd']) 

  # We need to include the Content-Type and Content-Length headers
  # to let the client know the size and type of data
  # contained in the response. Note that HTTP is whitespace
  # sensitive, and expects each header line to end with CRLF (i.e. "\r\n")
  
  socket.print "HTTP/1.1 200 OK\r\n" +
               "Content-Type: text/plain\r\n" +
               "Content-Length: #{response.bytesize}\r\n" +
               "Connection: close\r\n"

  # Print a blank line to separate the header from the response body,
  # as required by the protocol.
  socket.print "\r\n"

  # Print the actual response body, which is just "Hello World!\n"
  socket.print response

  # Close the socket, terminating the connection
  socket.close
end


