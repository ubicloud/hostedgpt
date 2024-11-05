module HasConversationStarter
  extend ActiveSupport::Concern

  private

  def set_conversation_starters
    conversation_starters = [
      ["Suggest a healthy meal plan", "for a week for someone with a busy schedule"],
      ["What are the top startup conferences", "to attend in Europe"],
      ["Compose a short biography of Matz", "focusing on his philosophy behind creating Ruby"],
      ["Help me pick", "a business outfit that will look good on camera"],
      ["Create a personal webpage for me", "after asking me three questions"],
      ["Recommend activities", "for a team-building day with remote employees"],
      ["Write a SQL query", "that adds a \"status\" column to an \"orders\" table"],
      ["Explain the significance of quantum computing", "in addressing complex problems"],
      ["Create a weekly newsletter template", "for a long-running project"],
      ["Recommend traditional Bavarian dishes", "and where to find them in Munich"],
      ["Craft a clever invitation", "for an engineering book club"],
      ["Write a survival guide", "for making it through a day with no coffee"],
      ["Help me plan", "a roadtrip from Amsterdam to Paris"]
    ]

    @conversation_starters = conversation_starters.shuffle[0..3]
  end
end
