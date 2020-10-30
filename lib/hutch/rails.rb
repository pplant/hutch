module Hutch
  class Rails < ::Rails::Engine
    class Reloader
      def initialize(app = ::Rails.application)
        @app = app
      end

      def call
        @app.reloader.wrap do
          yield
        end
      end

      def inspect
        "#<Hutch::Rails::Reloader @app=#{@app.class.name}>"
      end
    end
  end
end