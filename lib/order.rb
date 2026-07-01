class Order
  PROVIDERS = %w[lets_encrypt globalsign].freeze
  MAX_VALIDATION_ATTEMPTS = 3

  TRANSITIONS = {
    "pending"    => { start_validation: "validating" },
    "validating" => { validate_ok: "issued", validate_fail: "validating" },
    "issued"     => { install: "installed" },
  }.freeze

  class InvalidTransition < StandardError; end

  attr_reader :domain, :provider, :status, :validation_attempts

  def initialize(domain:, provider:)
    raise ArgumentError, "domain inválido: #{domain.inspect}"     unless valid_domain?(domain)
    raise ArgumentError, "provider inválido: #{provider.inspect}" unless PROVIDERS.include?(provider)

    @domain              = domain
    @provider            = provider
    @status              = "pending"
    @validation_attempts = 0
  end

  def apply(event)
    raise InvalidTransition, "estado final: #{status}" if final?

    if event == :cancel
      @status = "failed"
      return @status
    end

    next_state = TRANSITIONS.dig(status, event)
    raise InvalidTransition, "#{event} não permitido em #{status}" if next_state.nil?

    if event == :validate_fail
      @validation_attempts += 1
      next_state = "failed" if @validation_attempts >= MAX_VALIDATION_ATTEMPTS
    end

    @status = next_state
  end

  def final?
    status == "installed" || status == "failed"
  end

  private

  # peguei do https://regexr.com/3au3g
  DOMAIN_REGEX = '(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z0-9][a-z0-9-]{0,61}[a-z0-9]'

  def valid_domain?(domain)
    domain.is_a?(String) && domain.match?(DOMAIN_REGEX)
  end
end
