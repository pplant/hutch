module Hutch
  module MessageRegistration

    def register queue
      p "***A"
      Hutch.register_message(queue)
    end

  end
end
