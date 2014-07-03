require 'faye/websocket'
require 'json'
require 'erb'

module ChatDemo
  class ChatBackend
    KEEPALIVE_TIME = 15 # in seconds

    def initialize(app)
      @app     = app
      @group   = {}
    end

    def call(env)
      if Faye::WebSocket.websocket?(env)
        ws = Faye::WebSocket.new(env, nil, {ping: KEEPALIVE_TIME })
        path = env["ORIGINAL_FULLPATH"]

        if @group.has_key?(path)
          group_number = @group[path].length+1
          @group[path].store(ws,group_number)
        else
          @group[path]={ws => 1}
        end

        @group.each do |path, ws|
          p path
        end

        ws.on :open do |event|

          p [:open, ws.object_id]

          @group[path].each { |student,group_position|
            @group[path].each_value{ |pos|
              note = "student #{pos} join the room "
              text = {:text => note}
              student.send(text.to_json)
            }

            note = "you joined as student #{group_position}"
            student.send({:text => note}.to_json)
          }
        end

        ws.on :message do |event|

          sender = event.current_target
          sender_pos = @group[path][sender]
          received = JSON.parse(event.data)

          data = received["text"]
          @group[path].each {|client, pos| 
            note = "student #{sender_pos} : #{data}"
            text = {:text => note} 
            client.send(text.to_json)
          }

        end

        ws.on :close do |event|
          sender_pos = @group[path][ws]
          note = "student #{sender_pos} quit the chat"
          @group[path].delete(ws)
          ws = nil
        end

        # Return async Rack response
        ws.rack_response
      else
        @app.call(env)
      end
    end
  end
end
      
