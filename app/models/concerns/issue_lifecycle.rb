module IssueLifecycle
  extend ActiveSupport::Concern

  DRAFT_STATES = %w[
    ingested
    research_ready
    draft_ready
    verification_ready
    approved
    scheduled
  ].freeze

  SENT_STATES = %w[sent failed].freeze

  TERMINAL_STATES = %w[sent failed].freeze

  ALL_STATES = (DRAFT_STATES + SENT_STATES).freeze

  ALLOWED_TRANSITIONS = {
    "ingested" => %w[research_ready failed],
    "research_ready" => %w[draft_ready failed],
    "draft_ready" => %w[verification_ready failed],
    "verification_ready" => %w[approved draft_ready failed],
    "approved" => %w[scheduled draft_ready],
    "scheduled" => %w[sent failed],
    "sent" => [],
    "failed" => []
  }.freeze

  class_methods do
    def lifecycle_state?(state)
      ALL_STATES.include?(state.to_s)
    end

    def transition_allowed?(from:, to:)
      ALLOWED_TRANSITIONS.fetch(from.to_s, []).include?(to.to_s)
    end

    def terminal_lifecycle_state?(state)
      TERMINAL_STATES.include?(state.to_s)
    end
  end
end
