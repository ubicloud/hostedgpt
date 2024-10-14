require "duckduckgo"

class Toolbox::WebSearch < Toolbox
  describe :get_search_results, <<~S
    Perform a web search to get real-time information on anything.
    Call this if AND ONLY IF you cannot find any information on a topic in your memory or if answering a question requires real-time information.
  S

  def get_search_results(search_query_s:)
    results = DuckDuckGo.search(:query => search_query_s)
    Rails.logger.info "Tookbox::WebSearch: #{search_query_s}"
    results.take(3).map { _1.description }.join("\n\n").to_json
  end
end
