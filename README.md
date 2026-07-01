# Pedido de Certificado SSL

## Como rodar os testes
```
bundle install
bundle exec rspec --format documentation  # saída detalhada
```

## Decisões de design

A lógica fica em lib/order.rb

Todo o fluxo gira em torno da tabela (TRANSITIONS) que mapeia estado e evento para o próximo estado

Validação acontece no initialize. Domínio e provider inválidos são negados com ArgumentError descritivo antes do objeto ser criado

status e validation_attempts são attr_reader. Só #apply muda o estado, o resto apenas lê

## Parte 2 (API REST em Rails)

A classe Order continuaria em app/models/order.rb sem alteração <br>
O model do ActiveRecord persiste os atributos mas delega toda a lógica de transição para a classe <br>

Para criar um pedido: <br>
POST /orders com domain e provider no body <br>
Retorna 201 em sucesso, 422 se os dados forem inválidos <br>

Para consultar: <br>
GET /orders/:id <br>
retorna o estado atual e os dados do pedido <br>
<br>
GET /orders lista todos os pedidos, com paginação<br>
<br>
Para mudar de estado: <br>
POST /orders/:id/transitions <br>
body: { event: "start_validation" } <br>
Retorna 200 com o pedido atualizado, 422 se o evento não for permitido no estado atual, 409 se o pedido já estiver em estado final.

### Front-end em Vue / React

Criaria três componentes: OrderList para listar pedidos com o status visível, OrderCard para exibir os detalhes de um pedido e os botões de ação, e um composable useOrder que encapsula as chamadas à API e o estado reativo. Os componentes consomem o composable e não falam com a API diretamente. <br>

Os botões em OrderCard são derivados do estado atual "Iniciar validação" só aparece em pending, "Instalar" só em issued. <br>
Não escondo botões com CSS. Se o estado não permite a ação, o botão não existe na página.

### Confiabilidade

Chamar o provedor dentro do ciclo request/response trava o processo e estoura timeouts. O fluxo correto seria assíncrono: 
o POST /transitions com start_validation move o pedido para validating e joga para a fila do sidekiq, retornando 200. De forma async, o job chama o provedor e ao terminar dispara validate_ok ou validate_fail no pedido.

O front exibe validating e atualiza quando o estado mudar, via polling simples ou ActionCable se quiser evitar requisições desnecessárias.

```
class ValidateOrderJob < ApplicationJob
  queue_as :default

  def perform(order_id)
    order = Order.find(order_id)
    result = SslProviderClient.new(order.provider).validate(order.domain)
    order.apply(result.success? ? :validate_ok : :validate_fail)
    order.save!
  rescue Order::InvalidTransition
    # pedido cancelado enquanto o job rodava
  end
end
```

## O que faria com mais tempo

Associar pedidos a um cliente com autenticação JWT e autorização por escopo. <br>
Guardar um histórico de transições (tabela order_events) com timestamp e autor pois hoje o histórico se perde. <br>
Adicionar specs de request para os endpoints e um teste do job com provedor mockado.
