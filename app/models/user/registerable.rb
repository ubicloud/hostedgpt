module User::Registerable
  extend ActiveSupport::Concern

  included do
    after_create :create_initial_assistants_etc
  end

  private

  def create_initial_assistants_etc
    if Feature.ubicloud_mode?
      create_initial_assistants_etc_ubicloud
      return
    end


    open_ai_api_service = api_services.create!(url: APIService::URL_OPEN_AI, driver: :openai, name: "OpenAI")
    anthropic_api_service = api_services.create!(url: APIService::URL_ANTHROPIC, driver: :anthropic, name: "Anthropic")
    groq_api_service = api_services.create!(url: APIService::URL_GROQ, driver: :openai, name: "Groq")

    LanguageModel.import_from_file(users: [self])

    assistants.create! name: "GPT-4o", language_model: language_models.best_for_api_service(open_ai_api_service).first
    assistants.create! name: "Claude 3.5 Sonnet", language_model: language_models.best_for_api_service(anthropic_api_service).first
    assistants.create! name: "Meta Llama", language_model: language_models.best_for_api_service(groq_api_service).first
  end

  def create_initial_assistants_etc_ubicloud
    ubicloud_api_service = api_services.create!(url: APIService::URL_UBICLOUD, driver: :openai, name: "Ubicloud")
    [
      ["llama", "Llama", false, true, false, true, ubicloud_api_service, 5, 5],
    ].each do |api_name, name, supports_tools, supports_system_message, supports_images, best, api_service, input_token_cost_per_million, output_token_cost_per_million|
      million = BigDecimal(1_000_000)
      input_token_cost_cents = input_token_cost_per_million/million
      output_token_cost_cents = output_token_cost_per_million/million

      language_models.create!(
        api_name:,
        api_service:,
        name:,
        supports_tools:,
        supports_system_message:,
        supports_images:,
        best:,
        input_token_cost_cents:,
        output_token_cost_cents:,
      )
    end

    assistants.create! name: "Ubicloud Llama", description: "Ubicloud Llama 3.1 405B", language_model: language_models.find_by(api_name: "llama")
  end
end
