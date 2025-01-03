class Settings::ApplicationController < ApplicationController
  before_action :set_settings_menu

  layout "settings"

  private

  def set_settings_menu
    # controller_name => array of items
    @settings_menu = if Feature.ubicloud_mode?
      {
        people: {
          "Your Account": edit_settings_person_path,
        },
      }
    else
      {
        people: {
          "Your Account": edit_settings_person_path,
        },

        memories: {
          "Assistant Memories": settings_memories_path,
        },

        assistants: Current.user.assistants.ordered.map {
          |assistant| [ assistant, edit_settings_assistant_path(assistant) ]
        }.to_h.merge({
          "New Assistant": new_settings_assistant_path
        }),

        language_models: {
          "Language Models": settings_language_models_path,
        },

        api_services: {
          "API Services": settings_api_services_path,
        },
      }
    end
  end
end
