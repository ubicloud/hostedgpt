module User::Registerable
  extend ActiveSupport::Concern

  included do
    after_create :create_initial_assistants_etc
  end

  private

  def create_initial_assistants_etc
    puts "Creating initial assistants etc"
    ubicloud_api_service = api_services.create!(url: APIService::URL_SUFFIX_UBICLOUD, driver: :openai, name: "Ubicloud")
    puts "Created Ubicloud API service"
    [
      ["llama-3-2-3b-it", "Llama 3.2 3b", "https://1ecdjm6j96722k5v8jar2m60t3.b56xg.lb.", false, false, ubicloud_api_service, 5, 5],
    ].each do |api_name, name, url_prefix, supports_tools, supports_images, api_service, input_token_cost_per_million, output_token_cost_per_million|
      million = BigDecimal(1_000_000)
      input_token_cost_cents = input_token_cost_per_million/million
      output_token_cost_cents = output_token_cost_per_million/million

      language_models.create!(
        api_name: api_name,
        api_service: api_service,
        url_prefix: url_prefix,
        name: name,
        supports_tools: supports_tools,
        supports_images: supports_images,
        input_token_cost_cents: input_token_cost_cents,
        output_token_cost_cents: output_token_cost_cents,
      )
    end

    puts "Created initial language models"

    assistants.create! name: "Ubicloud Llama 3.2", language_model: language_models.find_by(api_name: "llama-3-2-3b-it")

    puts "Created initial assistants"
  end
end
