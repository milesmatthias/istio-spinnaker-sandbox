# Generated by the protocol buffer compiler.  DO NOT EDIT!
# Source: helloworld.proto for package 'simple'
# Original file comments:
#
# # Copyright 2019 Google LLC. This software is provided as-is, without warranty or representation for any use or purpose.
# # Your use of it is subject to your agreement with Google.
# # Licensed under the Apache License, Version 2.0 (the "License");
# # you may not use this file except in compliance with the License.
# # You may obtain a copy of the License at
# #
# #    http://www.apache.org/licenses/LICENSE-2.0
# #
# # This code is a prototype and not engineered for production use.
# # Error handling is incomplete or inappropriate for usage beyond
# # a development sample.
#

require 'grpc'
require 'helloworld_pb'

module Simple
  module Demo
    # The greeting service definition.
    class Service

      include GRPC::GenericService

      self.marshal_class_method = :encode
      self.unmarshal_class_method = :decode
      self.service_name = 'simple.Demo'

      # Sends a greeting
      rpc :SendMessages, stream(SimpleMessage), stream(SimpleAck)
    end

    Stub = Service.rpc_stub_class
  end
end