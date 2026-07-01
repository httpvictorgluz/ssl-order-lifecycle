# Esqueleto — Pedido de Certificado SSL

Ponto de partida opcional para a **Parte 1** (lógica em Ruby + RSpec). Sinta-se livre para
reorganizar — só explique no seu README final. A **Parte 2** (cenário & tecnologias) você
responde no README; uma POC é opcional.

## Estrutura

```
lib/
  order.rb        # a lógica do pedido (esqueleto — você implementa)
spec/
  order_spec.rb   # exemplos do comportamento esperado (alguns marcados pending)
Gemfile           # apenas rspec
```

## Como rodar

```bash
bundle install
bundle exec rspec
```

Ao iniciar, parte dos testes está `pending`. Conforme implementar, remova os `pending`,
ajuste à sua API e acrescente os seus próprios testes.

Consulte o `enunciado.pdf` para as regras completas e as perguntas da Parte 2.
