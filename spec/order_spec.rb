require_relative "../lib/order"

RSpec.describe Order do
  let(:order) { described_class.new(domain: "victorgluz.com", provider: "lets_encrypt") }

  describe "#initialize" do
    it "começa em pending com 0 tentativas" do
      expect(order.status).to eq("pending")
      expect(order.validation_attempts).to eq(0)
    end

    it "aceitar todos os provedores válidos" do
      Order::PROVIDERS.each do |provider|
        expect { described_class.new(domain: "pay.victorgluz.com", provider: provider) }.not_to raise_error
      end
    end

    it "recusar domínio inválido" do
      expect { described_class.new(domain: "victorgluz", provider: "lets_encrypt") }
        .to raise_error(ArgumentError, /domain inválido/)
    end

    it "recusar domínio não preenchido" do
      expect { described_class.new(domain: "", provider: "lets_encrypt") }
        .to raise_error(ArgumentError, /domain inválido/)
    end

    it "recusar provedor inválido" do
      expect { described_class.new(domain: "victorgluz.com", provider: "cloudflare") }
        .to raise_error(ArgumentError, /provider inválido/)
    end
  end

  describe "#apply" do
    context "caminho feliz" do
      it "segue de pending para validating para issued para installed" do
        order.apply(:start_validation)
        expect(order.status).to eq("validating")

        order.apply(:validate_ok)
        expect(order.status).to eq("issued")

        order.apply(:install)
        expect(order.status).to eq("installed")
      end
    end

    context "transições inválidas" do
      it "recusar evento não permitido no estado atual" do
        expect { order.apply(:install) }.to raise_error(Order::InvalidTransition)
      end

      it "não alterar o estado ao recusar" do
        expect { order.apply(:install) }.to raise_error(Order::InvalidTransition)
        expect(order.status).to eq("pending")
      end

      it "recusar evento desconhecido" do
        expect { order.apply(:voar) }.to raise_error(Order::InvalidTransition)
      end
    end

    context "tentativas de validação" do
      before { order.apply(:start_validation) }

      it "mantém validating e incrementa tentativas antes do limite" do
        order.apply(:validate_fail)
        expect(order.status).to eq("validating")
        expect(order.validation_attempts).to eq(1)

        order.apply(:validate_fail)
        expect(order.status).to eq("validating")
        expect(order.validation_attempts).to eq(2)
      end

      it "Deve ficar como failed ao atingir MAX_VALIDATION_ATTEMPTS" do
        Order::MAX_VALIDATION_ATTEMPTS.times { order.apply(:validate_fail) }
        expect(order.status).to eq("failed")
        expect(order.validation_attempts).to eq(Order::MAX_VALIDATION_ATTEMPTS)
      end

      it "certificado emitido com sucesso mesmo após falhas anteriores" do
        order.apply(:validate_fail)
        order.apply(:validate_fail)
        order.apply(:validate_ok)
        expect(order.status).to eq("issued")
      end
    end

    context "cancel" do
      it "cancela a partir de pending" do
        order.apply(:cancel)
        expect(order.status).to eq("failed")
      end

      it "cancela a partir de validating" do
        order.apply(:start_validation)
        order.apply(:cancel)
        expect(order.status).to eq("failed")
      end

      it "cancela a partir de issued" do
        order.apply(:start_validation)
        order.apply(:validate_ok)
        order.apply(:cancel)
        expect(order.status).to eq("failed")
      end
    end

    context "estados finais" do
      it "não aceita eventos após installed" do
        order.apply(:start_validation)
        order.apply(:validate_ok)
        order.apply(:install)
        expect { order.apply(:cancel) }.to raise_error(Order::InvalidTransition)
      end

      it "não aceita eventos após failed" do
        order.apply(:cancel)
        expect { order.apply(:start_validation) }.to raise_error(Order::InvalidTransition)
      end
    end
  end

  describe "#final?" do
    it "retorna false em estados intermediários" do
      expect(order.final?).to be false
      order.apply(:start_validation)
      expect(order.final?).to be false
      order.apply(:validate_ok)
      expect(order.final?).to be false
    end

    it "retorna true em installed" do
      order.apply(:start_validation)
      order.apply(:validate_ok)
      order.apply(:install)
      expect(order.final?).to be true
    end

    it "retorna true em failed" do
      order.apply(:cancel)
      expect(order.final?).to be true
    end
  end
end
