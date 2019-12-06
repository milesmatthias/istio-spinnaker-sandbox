#!/usr/bin/env ruby

this_dir = File.expand_path(File.dirname(__FILE__))
lib_dir = File.join(this_dir, 'lib')

p "lib_dir = #{lib_dir}"

$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

require 'grpc'
require 'multi_json'
require 'helloworld_services_pb'

include Simple

def get_sample_messages
  (1..5).map do |i|
    Simple::SimpleMessage.new({
      name: "msg #{i}",
      id: "#{i}",
      payload: "foo"
    })
  end
end

def main
  stub = Simple::Demo::Stub.new('localhost:8980', :this_channel_is_insecure)

  msgs = get_sample_messages
  p "Sending #{msgs.count} messages:"
  msgs.each do |msg|
    p "msg id: #{msg.id}, name: #{msg.name}, payload: #{msg.payload}"
  end
  stub.send_messages(msgs.each) { |r| p "received #{r.inspect}" }
end

main
