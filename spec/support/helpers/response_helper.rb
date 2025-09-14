module ResponseHelpers
  def reload_response_body
    @_response_body = nil
  end

  def response_body
    @_response_body ||= begin
      JSON.parse(response.body)
    rescue StandardError
      {}
    end
  end
end
