require "duckduckgo"

class Toolbox::WebSearch < Toolbox
  DuckDuckGo::RESOURCE_URL = "https://duckduckgo.com/html/?df=m&q=" # TODO: This is a hack to search for more recent results.

  describe :get_search_results, <<~S
    If a user asks a question that requires real time information, you may use this tool to search the web for the answer.
  S
  def get_search_results(search_query_s:)
    results = DuckDuckGo.search(:query => search_query_s)
    results = results.reject { _1.uri.include?("ad_domain") }.take(10).map { "#{_1.title}: #{_1.description}" }.join("\n\n").to_json
    Rails.logger.info "Toolbox::WebSearch: #{search_query_s} -> #{results}"
    results
  end
end
