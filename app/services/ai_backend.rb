class AIBackend
  include Utilities, Tools

  attr :client

  def initialize(user, assistant, conversation = nil, message = nil, rag_context = nil)
    @user = user
    @assistant = assistant
    @conversation = conversation
    @message = message # required for streaming responses
    @rag_context = rag_context
    @client_config = {}
    @response_handler = nil
  end

  def get_oneoff_message(instructions, messages, params = {})
    set_client_config(
      instructions:,
      messages: preceding_messages(messages),
      params:,
    )
    response = @client.send(client_method_name, ** @client_config)

    response.dig("content", 0, "text") ||
      response.dig("choices", 0, "message", "content")
  end

  def get_oneoff_message_for_recent_conversation(instructions, params = {})
    set_client_config(
      instructions:,
      messages: preceding_conversation_messages.last(3),
      params:,
    )
    response = @client.send(client_method_name, ** @client_config)

    response.dig("content", 0, "text") ||
      response.dig("choices", 0, "message", "content")
  end

  def stream_next_conversation_message(&chunk_handler)
    @stream_response_text = ""
    @stream_response_tool_calls = []
    @response_handler = block_given? ? stream_handler(&chunk_handler) : nil

    preceding_messages = preceding_conversation_messages

    if @rag_context.present?
      last_message = preceding_messages.last
      last_message[:content] = last_message[:content] + "\n\nFor additional context, below are the results of a related web search. Don't mention this in your answer and use these web search results at your own discretion:\n\n" + @rag_context
      Rails.logger.info "last_message_rag: #{last_message[:content]}"
    end

    set_client_config(
      instructions: full_instructions,
      messages: preceding_messages,
      streaming: true,
    )

    begin
      response = @client.send(client_method_name, ** @client_config)
    rescue ::Faraday::UnauthorizedError => e
      raise configuration_error
    end

    if @stream_response_tool_calls.present?
      return format_parallel_tool_calls(@stream_response_tool_calls)
    elsif @stream_response_text.blank?
      raise ::Faraday::ParsingError
    end
  end

  private

  def client_method_name
    raise NotImplementedError
  end

  def configuration_error
    raise NotImplementedError
  end

  def set_client_config(config)
    if config[:streaming] && @response_handler.nil?
      raise "You configured streaming: true but did not define @response_handler"
    end
  end

  def get_response
    raise NotImplementedError
  end

  def stream_response
    raise NotImplementedError
  end

  def preceding_messages(messages = [])
    messages.map.with_index do |msg, i|
      role = (i % 2).zero? ? "user" : "assistant"

      {
        role:,
        content: msg
      }
    end
  end

  def preceding_conversation_messages
    raise NotImplementedError
  end

  def full_instructions
    s = @assistant.instructions.to_s

    if @assistant.api_service.name == "Ubicloud" && s.empty?
      if @assistant.language_model.supports_tools? && Toolbox.tools.count > 0
        s = "You are a helpful assistant with tool calling capabilities. Only reply with a tool call if you cannot directly answer a question and if the function exists in the library provided by the user. In any other case, just reply directly in natural language. When you receive a tool call response, use the output to format an answer to the original user question."
      else
        s = "You are a helpful assistant."
      end
    end

    if @user.memories.present?
      s += "\n\nNote these additional items that you've been told and remembered:\n\n"
      s += @user.memories.pluck(:detail).join("\n")
    end


    s += "\n\nFor the user, the current time is #{DateTime.current.strftime("%-l:%M%P")}; the current date is #{DateTime.current.strftime("%A, %B %-d, %Y")}"
    s.strip
  end
end
