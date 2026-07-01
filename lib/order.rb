# Pedido de certificado SSL (Ruby puro). Implemente a lógica do enunciado.
# Pode reorganizar à vontade (ex.: separar a máquina de estados em outra classe) —
# só explique no README.
#
# Estados: pending, validating, issued, installed (final), failed (final)
# Eventos: start_validation, validate_ok, validate_fail, install, cancel
class Order
  PROVIDERS = %w[lets_encrypt globalsign].freeze
  MAX_VALIDATION_ATTEMPTS = 3

  # Levante isto numa transição não permitida (sugestão de nome).
  class InvalidTransition < StandardError; end

  attr_reader :domain, :provider
  attr_accessor :status, :validation_attempts

  # domain: string (formato de domínio válido); provider: um de PROVIDERS.
  # Deve recusar criação com dados inválidos.
  def initialize(domain:, provider:)
    # TODO
    raise NotImplementedError
  end

  # Aplica um evento de transição (ver enunciado) e retorna o novo estado.
  def apply(event)
    # TODO
    raise NotImplementedError
  end

  # true se o pedido está em um estado final (installed ou failed).
  def final?
    # TODO
    raise NotImplementedError
  end
end
