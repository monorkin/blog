# frozen_string_literal: true

class ApplicationService
  def self.call(*args, **kv_args)
    new(*args, **kv_args).call
  end
end
