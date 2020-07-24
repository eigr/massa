defmodule MongooseProxy do
end

defmodule MongooseProxy.CloudstateEntity do
  defstruct node: Node.self(),
            entity_type: "",
            service_name: "",
            persistence_id: "",
            proto: "",
            messages: [
              name: "",
              attributes: [
                name: "",
                number: 0,
                type: nil,
                options: [
                  type: nil
                ]
              ]
            ],
            services: [
              name: "",
              methods: [
                name: "",
                input_type: nil,
                output_type: nil,
                unary: true,
                stream_in: false,
                stream_out: false,
                streamed: false,
                options: [
                  type: nil
                ]
              ]
            ]
end
