defmodule MassaProxy.CloudstateEntity do
  @moduledoc false
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
                label: nil,
                entity_id: nil,
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
                  option: [
                    type: nil,
                    data: nil
                  ]
                ]
              ]
            ]
end
