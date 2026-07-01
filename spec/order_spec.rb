require_relative "../lib/order"

# Exemplos do comportamento esperado. Estão `pending` para o esqueleto rodar verde de
# início — conforme implementar, remova os `pending`, ajuste à sua API e adicione os seus
# (caminho feliz, criação inválida, transição inválida, retry até failed, estado final).
RSpec.describe Order do
  let(:order) { described_class.new(domain: "loja.exemplo.com.br", provider: "lets_encrypt") }

  it "começa em pending com 0 tentativas" do
    pending("implemente o initialize")
    expect(order.status).to eq("pending")
    expect(order.validation_attempts).to eq(0)
  end

  it "segue o caminho feliz até installed" do
    pending("implemente o apply")
    order.apply(:start_validation)
    order.apply(:validate_ok)
    order.apply(:install)
    expect(order.status).to eq("installed")
  end

  it "recusa transição inválida sem mudar o estado" do
    pending("implemente o tratamento de transição inválida")
    expect { order.apply(:install) }.to raise_error(Order::InvalidTransition)
    expect(order.status).to eq("pending")
  end

  it "vai para failed ao atingir MAX_VALIDATION_ATTEMPTS" do
    pending("implemente o retry da validação")
    order.apply(:start_validation)
    order.apply(:validate_fail)
    order.apply(:validate_fail)
    order.apply(:validate_fail)
    expect(order.status).to eq("failed")
  end
end
