
gen-stubs:
	grpc_tools_ruby_protoc -I proto --ruby_out=lib --grpc_out=lib proto/helloworld.proto

run-client:
	bundle exec ruby grpc_client.rb
