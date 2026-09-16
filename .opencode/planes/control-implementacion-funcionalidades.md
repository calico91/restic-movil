# Control de Implementación de Funcionalidades — Web vs Móvil

> Archivo de seguimiento continuo. Comparación de funcionalidades entre:
> - **Móvil**: `D:\Flutter\restic-movil` (Flutter + GetX, v2.0.7+19)
> - **Web**: `D:\Angular\restic-web` (Angular 20 + Signals + Angular Material 20)
> - **Backend**: `D:\Spring\restic-back` (Spring Boot, base única para ambos)
>
> **Fecha del último análisis:** 2026-09-10

---

## Leyenda de estados

- `[x]` **Completado** — Funcionalidad operativa en web con paridad al móvil
- `[~]` **Parcial** — Implementación parcial: datos listos pero UI/flujo incompleto, o falta alguna regla de negocio
- `[ ]` **Falta** — Aún no se ha implementado en web (puede estar como stub vacío o no existir)
- `~~Descartado~~` — No aplica en web por decisión de diseño (ver sección de descartados)

---

## Tabla resumen por módulo

| # | Módulo | Estado web | Pendiente crítico |
|---|---|---|---|
| 1 | Auth / Login | `[x]` | — |
| 2 | Splash + App Update | `~~Descartado~~` | No aplica en web (PWA bundle versionado, sin actualización in-app) |
| 3 | Tomar Pedido | `[x]` | — |
| 4 | Pedidos (lista/gestión) | `[x]` | — |
| 5 | Comandas (cocina) | `[x]` | — |
| 6 | Pagos / Caja (registrar pago) | `[x]` | — |
| 7 | Opciones de Caja (apertura/cierre/egresos) | `[x]` | — |
| 8 | Clientes (CRUD) | `[x]` | — |
| 9 | Mesas (CRUD) | `[x]` | — |
| 10 | Menú (categorías + productos + recetas) | `[ ]` | Stub vacío |
| 11 | Usuarios (CRUD) | `[x]` | — |
| 12 | Métodos de Pago (configuración) | `[x]` | — |
| 13 | Inventario | `[x]` | — |
| 14 | Datos Fiscales | `[x]` | — |
| 15 | Reportes | `[x]` | — |
| 16 | Perfil (cambio contraseña + config) | `[x]` | — |
| 17 | WebSocket tiempo real | `[x]` | — |
| 18 | Multi-sucursal | `[x]` | — |
| 19 | Control por módulos/roles (guards) | `[x]` | — |

---

## Funcionalidades descartadas en web (no se documentan)

Las siguientes capacidades del móvil **no se replican en la web** por decisión del proyecto:

- ~~Impresión térmica Bluetooth (BlueThermalPrinter)~~
- ~~Impresión térmica por red TCP~~
- ~~Tickets térmicos 58mm / 80mm~~ (comanda, precuenta, transacción, items agregados, delivery)
- ~~Multi-zona de impresión (CategoryPrinterResolver)~~
- ~~Configuración de impresora (dispositivos, conexión, prueba)~~
- ~~Zonas de impresión (CRUD `print-zones`) y asignación categoría↔zona~~
- ~~Pre-cuenta impresa~~ (en web se reemplazará por visualizador modal de pre-cuenta)
- ~~Exportación CSV vía `share_plus` móvil~~ (en web se usa descarga nativa del navegador)

---

# Detalle por módulo

## 1. Auth / Login

### Estado global: `[x]` Completado

| Funcionalidad | Estado | Notas |
|---|---|---|
| Formulario login (username/password) | `[x]` | Reactivo, validaciones |
| Autenticación JWT (Bearer) | `[x]` | `auth.interceptor.ts` |
| Persistencia token en localStorage | `[x]` | `StorageService` (signals + localStorage) |
| Selección de sucursal cuando hay >1 | `[x]` | `BranchSelectionModalComponent` |
| Configuración de URL del backend en runtime | `[x]` | `ServerUrlService` + `ConfigureConnectionModalComponent` |
| Logout manual | `[x]` | `AuthService.logout()` |
| Auto-logout por sesión expirada (código `E2`) | `[x]` | `ErrorService` + `error.interceptor.ts` |
| Guards de ruta (`authGuard`) | `[x]` | `core/guards/auth.guard.ts` |
| Guard por módulo (`moduleAccessGuard`) | `[x]` | `core/guards/module-access.guard.ts` |
| Header `X-App-Key` | `[x]` | `app-key.interceptor.ts` |
| Header `X-Branch-Id` automático | `[x]` | `branch-id.interceptor.ts` |

**Archivos clave (web):**
- `src/app/features/auth/login/login.component.ts` (+ `.html`, `.scss`)
- `src/app/features/auth/login/widgets/branch-selection-modal.component.ts`
- `src/app/features/auth/login/widgets/configure-connection-modal.component.ts`
- `src/app/core/services/auth.service.ts`
- `src/app/core/services/storage.service.ts`
- `src/app/core/services/server-url.service.ts`
- `src/app/core/interceptors/auth.interceptor.ts`
- `src/app/core/interceptors/branch-id.interceptor.ts`
- `src/app/core/interceptors/error.interceptor.ts`
- `src/app/core/guards/auth.guard.ts`
- `src/app/core/guards/module-access.guard.ts`

**Archivos clave (móvil — referencia):**
- `lib/app/modules/auth/controllers/login_controller.dart`
- `lib/app/modules/auth/views/login_view.dart`
- `lib/app/modules/auth/views/widgets/branch_selection_modal.dart`
- `lib/app/modules/auth/views/widgets/configure_connection_modal.dart`
- `lib/app/data/repositories/auth_repository.dart`
- `lib/app/data/models/login_response.dart`

---

## 2. Splash + App Update (verificación de versión)

### Estado global: `~~Descartado~~` (no aplica en web)

No hay equivalente web: la app se sirve como bundle versionado por el despliegue (no hay descarga/actualización in-app) y la SPA renderiza directo en `/login` o `/home` tras validar token + branchId en el `AuthService`. El concepto de "actualización obligatoria" no aplica a una PWA/web estática.

**Archivos clave (móvil — referencia, sólo documentación):**
- `lib/app/modules/splash/controllers/splash_controller.dart`
- `lib/app/modules/splash/views/splash_view.dart`
- `lib/app/modules/app_update/`
- `lib/app/data/repositories/app_version_repository.dart`
- `lib/app/data/models/app_version_info.dart`
- `lib/core/utils/helpers/version_helper.dart`

---

## 3. Tomar Pedido (crear pedido)

### Estado global: `[x]` Completado

| Funcionalidad | Estado | Notas |
|---|---|---|
| Selector de tipo de origen (SALON / TAKE_AWAY / DELIVERY) | `[x]` | `take-order.service.ts` loadInitialData → `originTypes` |
| Si SALON → selección múltiple de mesas disponibles | `[x]` | `tables.repository.ts` getAvailable + grid en HTML |
| Búsqueda y selección de cliente | `[x]` | Autocomplete por nombre/apellido/teléfono |
| Catálogo por categorías con tabs | `[x]` | `categories.repository.ts` getAll |
| Filtro de productos (excluye `optionOnly` y opciones de combo) | `[x]` | En `loadInitialData` |
| Carrito (agregar/quitar/incrementar/decrementar) | `[x]` | `addItem()`, `updateQuantity()`, `removeItem()` |
| Agrupar items duplicados en carrito (mismo product+price+obs+combo) | `[x]` | Lógica en `addItem()` |
| Recargos adicionales (surcharges) | `[x]` | `AddSurchargeDialogComponent` |
| Eliminar cargos adicionales antes de enviar | `[x]` | Botón `remove_circle_outline` por cargo en `.surcharges-section` → `service.removeSurcharge(index)` |
| Total computado en tiempo real (items + recargos) | `[x]` | Signal computed `cartTotal` |
| Observaciones generales del pedido (textarea) | `[x]` | Textarea en `.cart-observations` bound a `service.observations`; enviado en payload `observations` (`take-order.service.ts:518`) |
| Anidación de subcategorías en el catálogo | `[x]` | `selectedCategorySubcategories` agrupa productos por subcategoría dentro de la categoría activa (con título); si la categoría tiene 1 sola subcategoría, se muestran productos directos |
| Submit → `POST orders/create` | `[x]` | `orders.repository.ts` createOrder |
| Validaciones: origen obligatorio, mesa si SALON, ≥1 producto | `[x]` | En `submit()` |
| Reset de estado tras éxito | `[x]` | `reset()` en servicio |
| Feedback de éxito (modal/snackbar) | `[x]` | `SuccessService` |
| **Combos** (configurador de grupos/opciones) | `[x]` | `ComboSelectionDialogComponent` con navegación de unidades, validación `min/max`/`required` y `totalPrice` |
| **Combinados 2x1** (selección de acompañante, cobrar el más caro) | `[x]` | `CombinationSelectionDialogComponent` + `addCombination`/`getCombinadoSiblings` en servicio; regla "solo el más caro" en `itemTotal` |
| **Comentarios por item** (notas individuales por producto) | `[x]` | `AddProductDialogComponent` (shared); botón "editar comentario" por item en carrito |
| Producto variable (multi-precio con `sizeLabel`) | `[x]` | `SizeSelectorDialogComponent` se abre cuando `prices.length > 1` |
| Cliente predeterminado persistido | `[x]` | `defaultCustomer()` / `saveDefaultCustomer()` / `applyDefaultCustomer()` en `TakeOrderService`; aplicado automáticamente al elegir TAKE_AWAY/DELIVERY |

**Archivos clave (web):**
- `src/app/features/take-order/take-order.component.ts` (+ `.html` 235 líneas, `.scss`)
- `src/app/core/services/take-order.service.ts` (~400 líneas, extendido con combinados y defaultCustomer)
- `src/app/shared/modals/add-surcharge-dialog.component.ts`
- `src/app/shared/modals/add-product-dialog.component.ts` **(nuevo)**
- `src/app/shared/modals/size-selector-dialog.component.ts` **(nuevo)**
- `src/app/features/take-order/dialogs/combo-selection-dialog.component.ts` **(nuevo)**
- `src/app/features/take-order/dialogs/combination-selection-dialog.component.ts` **(nuevo)**
- `src/app/data/repositories/orders.repository.ts`
- `src/app/data/repositories/categories.repository.ts`
- `src/app/data/repositories/tables.repository.ts`
- `src/app/data/repositories/customer.repository.ts`
- `src/app/data/models/order.model.ts`
- `src/app/data/models/product.model.ts` (enum `ProductType` incluye `COMBINADO`)

**Archivos clave (móvil — referencia):**
- `lib/app/modules/take_order/controllers/take_order_controller.dart` (664 líneas)
- `lib/app/modules/take_order/views/take_order_view.dart` (337 líneas)
- `lib/app/modules/take_order/views/widgets/combo/combo_selection_dialog.dart`
- `lib/app/modules/take_order/controllers/combo_selection_controller.dart`
- `lib/app/modules/take_order/views/widgets/combination_selection_dialog.dart`
- `lib/app/modules/take_order/views/widgets/add_product_dialog.dart`
- `lib/app/modules/take_order/views/widgets/add_surcharge_dialog.dart`
- `lib/app/modules/take_order/views/widgets/order_summary/order_summary_sheet.dart`

**Endpoints clave:**
- `GET orders/origin-types`
- `GET categories/all` (devuelve subcategorías + productos + comboGroups)
- `GET tables/by-status/AVAILABLE`
- `GET customers/all`
- `POST orders/create`

---

## 4. Pedidos (lista y gestión)

### Estado global: `[x]` Completado

| Funcionalidad | Estado | Notas |
|---|---|---|
| Tabs Abiertos (OPEN) / Finalizados (FINALIZED) | `[x]` | `currentTab` signal |
| Navegador de fecha (`DateNavigatorComponent`) | `[x]` | Shared |
| Carga de pedidos por estado + fecha | `[x]` | `getOrdersByStatuses(statuses, date)` |
| **Búsqueda de pedidos (nº / cliente / mesa)** | `[x]` | Input en `.search-box` (header) + computeds `displayedOpenOrders`/`displayedFinalizedOrders` que filtran por `orderNumber`, `customer.name + lastName` y `tables[].name` (case-insensitive, `contains`); estado vacío contextual cuando hay query |
| WebSocket en tiempo real (recarga automática) | `[x]` | `websocket.service.ts` → signals |
| Card de pedido (`GlobalOrderCard`-equivalente en línea) | `[x]` | ListView en `orders.component.html` |
| Detalle de pedido (modal) | `[x]` | `OrderDetailDialogComponent` (inline en `orders.component.ts`) |
| Actualización de estado de detalle (SERVED / CANCELED) | `[x]` | Checkbox multi-selección en diálogo |
| Anular pedido pre-pago (`PUT orders/{id}/cancel` con `cancellationReason`) | `[x]` | Dialog (`CancelOrderDialog`, `CustomFormDialog` con `autoClose: false`) con motivo obligatorio y advertencia. Backend nuevo en V26_0 (2026-09-11) que registra `cancelledBy`/`cancelledAt`/`cancellationReason` en `orders`. |
| **Agregar productos a pedido existente** | `[x]` | `AddProductsDialogComponent` con catálogo, carrito temporal y `PUT orders/{orderId}/add-products` |
| **Filtro mesero "solo mis pedidos"** | `[x]` | `StorageService.getWaiterViewOwnOrdersOnly`/`saveWaiterViewOwnOrdersOnly`; toggle en drawer del home (visible solo si rol MESERO); filtrado cliente por `createdBy.id === user.id` en `OrdersService` y `CashRegisterService` |
| **Móvil: reubicación del toggle en pantalla "Ajustes de Pedidos"** | `[x]` | Nuevo módulo `order_settings` (`/settings/orders`) con `OrderSettingsView` (CustomScaffold + ExpandableSection "Pedidos"). El `SwitchListTile` que estaba inline en `CustomDrawer` (mezclaba navegación con controles) se movió a esta pantalla; el drawer ahora solo contiene un sub-ítem de navegación "Ajustes de Pedidos" bajo `Configuración` (solo ADMIN/SUPER). El controller delega en `HomeController` (única fuente de verdad del PATCH `branches/{branchId}/waiter-filter` + notificación a `OrdersController`). |
| Gestionar cargos adicionales (surcharges) sobre pedido existente | `[x]` | Botón "Cargos" en `OrderDetailDialogComponent` abre `ManageSurchargesDialogComponent`; persiste vía `PUT orders/{id}/surcharges` |
| Ver factura desde pedido pagado | `[x]` | Botón "Ver Factura" si tiene `transactionId` |
| Cancelar pedido antes de pagar | `[x]` | Botón "Anular" |
| Refresco de detalle tras acciones | `[x]` | `OrdersService.getOrder(id)` recarga el modelo del diálogo tras cerrar sub-diálogos |

**Archivos clave (web):**
- `src/app/features/orders/orders.component.ts` (incluye `OrderDetailDialogComponent`)
- `src/app/features/orders/dialogs/add-products-dialog.component.ts` **(nuevo)**
- `src/app/core/services/orders.service.ts` (con filtro mesero + `getOrder`)
- `src/app/core/services/cash-register.service.ts` (con filtro mesero)
- `src/app/core/services/storage.service.ts` (métodos waiter filter)
- `src/app/core/services/auth.service.ts` y `branch-selection-modal.component.ts` (persistencia del flag al login)
- `src/app/features/home/home.component.ts` + `.html` + `.scss` (toggle del drawer)
- `src/app/shared/components/date-navigator/`
- `src/app/features/payments/surcharges-dialog/surcharges-dialog.component.ts`

**Archivos clave (móvil — referencia):**
- `lib/app/modules/orders/controllers/orders_controller.dart` (708 líneas)
- `lib/app/modules/orders/views/orders_view.dart` (200 líneas)
- `lib/app/modules/orders/views/widgets/add_products_sheet.dart`
- `lib/app/modules/orders/views/widgets/manage_surcharges_sheet.dart`
- `lib/app/modules/orders/views/widgets/global_order_card.dart`

**Endpoints clave:**
- `GET orders/by-statuses?statuses=...&date=...`
- `GET orders/get-by-id/{id}`
- `GET orders/statuses` y `GET order-details/statuses`
- `PUT order-details/update-status`
- `PUT orders/update-status/{id}?status=...`
- `PUT orders/{orderId}/add-products`
- `PUT orders/{orderId}/surcharges`
- `DELETE orders/delete/{id}`
- `PATCH branches/waiter-filter`

---

## 5. Comandas (cocina)

### Estado global: `[x]` Completado

| Funcionalidad | Estado | Notas |
|---|---|---|
| Lista de pedidos abiertos por fecha | `[x]` | |
| Filtrado de detalles por estado (PENDING / IN_PREPARATION / READY) | `[x]` | |
| Modal de cocina con multi-selección de items | `[x]` | `KitchenDialogComponent` inline |
| Avanzar estado de items (PENDING → IN_PREPARATION → READY) | `[x]` | `PUT order-details/update-status` |
| WebSocket en tiempo real | `[x]` | |
| Ocultar items SERVIDOS y ANULADOS | `[x]` | |

**Archivos clave (web):**
- `src/app/features/commands/commands.component.ts` (250 líneas, incluye `KitchenDialogComponent`)
- `src/app/core/services/commands.service.ts`

**Archivos clave (móvil — referencia):**
- `lib/app/modules/commands/controllers/commands_controller.dart` (233 líneas)
- `lib/app/modules/commands/views/commands_view.dart` (317 líneas)

---

## 6. Pagos / Caja (Registrar Pago)

### Estado global: `[x]` Completado

| Funcionalidad | Estado | Notas |
|---|---|---|
| Lista de pedidos pendientes (OPEN + FINALIZED) por fecha | `[x]` | `pending-orders.component.ts` |
| Lista de historial (PAID + CANCELED) por fecha | `[x]` | Tab "Historial" |
| Modal Registrar Pago (`TransactionModalComponent`) | `[x]` | 621 líneas equivalentes en web |
| Resumen del pedido en el modal | `[x]` | Número, total, mesa, cliente |
| Propina (botones 0/5/10/15% + input manual) | `[x]` | `tipPercent` signal, opciones hardcodeadas |
| Cálculo bidireccional propina (% ↔ monto ↔ total) | `[x]` | Inputs independientes con recálculo cruzado y guarda anti-bucle; si hay 1 pago, su `amount` se sincroniza al total a pagar (`updateInitialPayment`) |
| Múltiples pagos (split payment) | `[x]` | FormArray de pagos |
| Campos condicionales para tarjeta (últimos 4, marca) | `[x]` | Si method es CREDIT/DEBIT_CARD |
| Validación de cobertura (totalPaid ≥ totalToPay) | `[x]` | |
| Cálculo de cambio (change) | `[x]` | |
| `POST transactions/create` | `[x]` | `transactions.repository.ts` create |
| Feedback de éxito con monto de cambio | `[x]` | |
| Re-ver factura (`InvoiceDetailsDialogComponent`) | `[x]` | `GET transactions/{id}/invoice` |
| Anular pedido desde caja (cancelar antes de pagar) | `[x]` | `PUT orders/{id}/cancel` body `{cancellationReason}` (obligatorio) |
| WebSocket en tiempo real (refresh al recibir evento) | `[x]` | |
| Cargar métodos de pago activos | `[x]` | `payment-methods.repository.ts` getActive |
| **Reembolso de transacción (REFUND)** | `[x]` | En `TransactionModalComponent`: selector de tipo alimentado por `service.transactionTypes`; si `REFUND` muestra campo `originalTransactionId`; submit envía `transactionType` + `originalTransactionId` a `POST transactions/create` (sin motivo, sin rol — igual al móvil) |
| **Cambio de método de pago post-factura** | `[x]` | `ChangePaymentMethodDialogComponent`: total bloqueado, FormArray de pagos (con campos tarjeta condicionales), motivo opcional; endpoint `PUT transactions/{id}/payment-details`; botón "Cambiar pago" en tarjeta de historial PAID (solo SUPER/ADMIN) |
| **Precuenta** (visualizador modal con total estimado + prop. opcional) | `[x]` | `PrecountDialogComponent`: items agrupados por nombre+precio (omite CANCELED), cargos, propina sugerida (del % predeterminado), TOTAL A PAGAR; botón "Ir a cobrar" abre `TransactionModalComponent` pre-llenado con esa propina. Reemplazo web del ticket impreso (descartado) |
| **Propina predeterminada guardable** (default % persistente) | `[x]` | `StorageService.saveDefaultTipPercentage()`/`getDefaultTipPercentage()`; carga al abrir el modal; botón guardar (`save`) en la fila de propina que persiste el % actual |
| Selección de terminal en transacciones | `~~Descartado~~` | El móvil no asigna `terminalId` a la transacción; el terminal se asocia al abrir turno y el backend resuelve el shift por `cashierId` (ya enviado). Paridad con móvil |
| **Anulación de venta pagada (CANCEL desde historial)** | `[ ]` (móvil `[x]`) | Botón "Anular" en `GlobalOrderCard` del tab Historial (solo PAID con `transactionId`); motivo obligatorio; `PUT transactions/{id}/cancel` reverte orden `PAID → CANCELED`, restaura inventario vía `StockRestoreService`, registra `cancelledBy`/`cancelledAt`/`cancellationReason`, dispara WebSocket. Solo SUPER/ADMIN y solo turno OPEN. Implementado en móvil (2026-09-10); pendiente en web. |
| Verificar que solo SUPER/ADMIN pueden cambiar método post-factura | `[x]` | Gate por rol en el botón "Cambiar pago" vía `isAdminOrSuper()` (`storage.roles()` incluye `SUPER` o `ADMINISTRADOR`). Único gate de rol en este módulo, igual al móvil |

**Archivos clave (web):**
- `src/app/features/payments/payments.component.ts`
- `src/app/features/payments/pending-orders/pending-orders.component.ts` (incluye `TransactionModalComponent`)
- `src/app/features/payments/order-details-dialog/order-details-dialog.component.ts`
- `src/app/features/payments/invoice-details-dialog/invoice-details-dialog.component.ts`
- `src/app/features/payments/surcharges-dialog/surcharges-dialog.component.ts`
- `src/app/features/payments/precount-dialog/precount-dialog.component.ts` **(nuevo)**
- `src/app/features/payments/change-payment-method-dialog/change-payment-method-dialog.component.ts` **(nuevo)**
- `src/app/core/services/cash-register.service.ts` (con `changePaymentMethod()`)
- `src/app/core/services/storage.service.ts` (con `saveDefaultTipPercentage()`/`getDefaultTipPercentage()`)
- `src/app/core/config/url-paths.ts` (con `CHANGE_PAYMENT_DETAILS`)
- `src/app/data/repositories/transactions.repository.ts` (con `changePaymentDetails()`)
- `src/app/data/repositories/payment-methods.repository.ts`
- `src/app/data/repositories/terminals.repository.ts`
- `src/app/data/models/transaction-request.model.ts`
- `src/app/data/models/transaction-receipt.model.ts`

**Archivos clave (móvil — referencia):**
- `lib/app/modules/cash_register/controllers/cash_register_controller.dart` (712 líneas)
- `lib/app/modules/cash_register/views/cash_register/cash_register_view.dart`
- `lib/app/modules/cash_register/views/cash_register/widgets/transaction_modal.dart` (621 líneas)
- `lib/app/modules/cash_register/views/cash_register/widgets/change_payment_method_modal.dart`
- `lib/app/modules/cash_register/views/cash_register/widgets/transaction_invoice_details_modal.dart`
- `lib/app/data/repositories/transactions_repository.dart`
- `lib/app/data/models/create_transaction_request.dart`
- `lib/app/data/models/transaction_receipt_model.dart`

**Endpoints clave:**
- `GET payment-methods/config/active`
- `GET transactions/types`
- `POST transactions/create` (SALE y REFUND; REFUND añade `originalTransactionId`)
- `GET transactions/{id}/invoice`
- `GET transactions/{id}`
- `PUT transactions/{id}/payment-details` (cambio de método post-factura)
- `POST transactions/refund` — **no se usa en web** (REFUND se hace vía `POST transactions/create` con `transactionType:"REFUND"`, igual que el móvil)
- `PUT transactions/{id}/cancel` — **implementado en móvil** (2026-09-10, revertir orden PAID, restaurar inventario, registrar `cancelledBy`). **Pendiente en web**. El endpoint existía pero era solo contable; ahora hace orquestación completa.

**Detalle de implementación realizada (Pagos — 2026-08-26):**
1. **Reembolso (REFUND)** — selector de tipo (SALE/REFUND) en `TransactionModalComponent` + campo `originalTransactionId` cuando REFUND; submit envía `transactionType` + `originalTransactionId` (sin motivo, sin rol — igual al móvil).
2. **Anulación de transacción (CANCEL)** — **implementada en móvil (2026-09-10, ver bloque siguiente).** El ítem se movió a la tabla principal de funcionalidades; ya no es `~~Descartado~~`.
3. **Cambio de método de pago post-factura** — `ChangePaymentMethodDialogComponent` con total bloqueado, FormArray de pagos (campos tarjeta condicionales) y motivo opcional; endpoint `PUT transactions/{id}/payment-details`; botón "Cambiar pago" en tarjeta de historial PAID con `transactionId`, gate por rol SUPER/ADMIN.
4. **Precuenta** — `PrecountDialogComponent`: replica el contenido del ticket móvil (items agrupados por nombre+precio, omitiendo CANCELED, cargos, propina sugerida del % predeterminado, TOTAL A PAGAR); botón "Ir a cobrar" → abre `TransactionModalComponent` pre-llenado con esa propina.
5. **Propina predeterminada guardable** — `StorageService.saveDefaultTipPercentage()`/`getDefaultTipPercentage()`; carga al abrir el modal; botón `save` en la fila de propina para persistir el % actual.
6. **Selección de terminal** — **no implementada**; el móvil no asigna `terminalId` a la transacción. Marcado `~~Descartado~~` por paridad. El backend resuelve el shift vía `cashierId` (ya enviado por la web).
7. **Sync bidireccional de propina** — implementados inputs de %, monto y total a pagar con recálculo cruzado bidireccional y guarda anti-bucle; si hay 1 pago, su `amount` se sincroniza al total a pagar.

**Detalle de implementación realizada (Pagos — 2026-09-10) — Anulación de venta pagada:**
- **Backend (`restic-back`)**:
  - Nueva migración `V25_0__add_transaction_cancelled_by.sql`: `transactions.cancelled_by_id` (FK a `users`) + reemplazo del CHECK `ck_stock_movements_type` para incluir el nuevo tipo `SALE_REVERSAL`. Registrada en `db.changelog-master.yaml`.
  - `Transaction.java` + relación `@ManyToOne User cancelledBy` (LAZY). `StockMovementType.java` + `SALE_REVERSAL("Anulacion de venta")` sumado a `increasesStock()`.
  - `InventoryItemRepository` + `restoreStock` (UPDATE atómico `current_stock + :qty, version + 1`). `StockMovementRepository` + `findByReferenceOrderIdAndType`.
  - Nuevo `StockRestoreService` (interfaz + Impl) con `restoreForOrder(order, reason)`: busca los `StockMovement` `SALE` de la orden, devuelve stock atómicamente y crea movimientos `SALE_REVERSAL` con `referenceOrder`, `createdBy = UserContextResolver.getCurrentUser()`, notes con el motivo.
  - `TransactionServiceImpl.cancelTransaction` extendido: para `SALE` con `orderId` valida **turno OPEN** + **orden PAID** (lock pesimista `findByIdAndBranchIdForUpdate`), revierte la orden a `CANCELED` (sin tocar `closingDate`), llama `stockRestoreService.restoreForOrder`, setea `cancelledBy`/`cancelledAt`/`cancellationReason`, dispara WebSocket (`notifyOrderStatusChanged`) y log WARN. Para transacciones sin orden mantiene el comportamiento previo + `cancelledBy`.
  - `TransactionResponseDTO` + `cancelledById`/`cancelledByName`. `TransactionMapper` actualizado.
  - Tests: cubrir happy path (orden revertida, stock restaurado, `cancelledBy` seteado), turno cerrado rechazado, doble anulación rechazada, no-COMPLETED.
  - `TECHNICAL_DOCUMENTATION.md` actualizado: §7.14, §9, §7.19, §10, ciclo de vida de orden.
- **Móvil (`restic-movil`)**:
  - `UrlPaths.cancelTransaction` (`transactions/{id}/cancel`).
  - `TransactionsRepository.cancelTransaction(id, {required reason})` → `PUT transactions/{id}/cancel` body `{'cancellationReason': reason}`.
  - `CashRegisterController`: flag `canAnnulTransactions` (SUPER/ADMIN, espejo de `canEditPaymentMethod`); `confirmAnnulTransaction(order)` con guards + `submitAnnulTransaction` (overlay → repo → `ModalInfo` → `loadHistoryOrders`).
  - Nuevo `AnnulTransactionDialog` (`CustomFormDialog` con `autoClose: false`, mismo estándar que `CustomerFormDialog`/`UserFormDialog`) con motivo **obligatorio**, advertencia del #orden/monto y consecuencias (revierte inventario, saca de caja; el efectivo se devuelve vía egreso "Devolución al cliente").
  - `cash_register_view.dart` (tab Historial) + `GlobalOrderCard` + botón "Anular" rojo en la fila inferior junto a "Cambiar pago", gate por `isHistoryPaid && canAnnulTransactions`. Tras anular la card queda "Anulada" y el botón desaparece.
- **Pendiente web** (este sprint): replicar el flujo de anulación en el tab Historial de Pagos con los mismos componentes (`CancelTransactionDialogComponent` + botón Anular + rol + recarga del historial). Mantener la fila inferior con el mismo orden que el móvil.

---

## 7. Opciones de Caja (sub-features)

### Estado global: `[x]` Completado (con un pendiente menor)

| Funcionalidad | Estado | Notas |
|---|---|---|
| **Apertura de caja** (`open-shift`) | `[x]` | Selección de terminal, monto inicial, observaciones → `POST cashier-shifts/open` |
| **Cierre de caja** (`close-shift`) | `[x]` | Monto declarado, observaciones, modal de confirmación con el monto antes de cerrar, cálculo sobrante/faltante → `PUT cashier-shifts/close/cashier/{cashierId}` |
| **Registrar egreso** (`expenses`) | `[x]` | Monto, concepto, motivo, fuente de pago (con campos bancarios), voucher → `POST cash-withdrawals/register` |
| **Cierres pendientes** (`pending-closes`) | `[x]` | Dos secciones (Sin Cerrar = OPEN / Pendientes de Conciliar = CLOSED) con cards; "Ver Arqueo" (`GET cashier-shifts/{id}/summary`) abre modal con resumen; "Conciliar" (`PUT cashier-shifts/{id}/reconcile`, sin body) solo visible para SUPER/ADMIN, con diálogo de confirmación sí/no y snackbar de éxito |
| **Historial de egresos + CSV** (`withdrawals-history`) | `[x]` | Filtros + descarga CSV vía navegador |

**Archivos clave (web):**
- `src/app/features/cash-register/cash-register.component.html` (shell con nav)
- `src/app/features/cash-register/sub-features/open-shift/open-shift.component.ts`
- `src/app/features/cash-register/sub-features/close-shift/close-shift.component.ts`
- `src/app/features/cash-register/sub-features/expenses/expenses.component.ts`
- `src/app/features/cash-register/sub-features/pending-closes/pending-closes.component.ts`
- `src/app/features/cash-register/sub-features/withdrawals-history/withdrawals-history.component.ts`
- `src/app/core/services/expenses.service.ts` (incluye `WithdrawalsHistoryService`)
- `src/app/data/repositories/cashier.repository.ts`
- `src/app/data/repositories/cash-withdrawals.repository.ts`

**Archivos clave (móvil — referencia):**
- `lib/app/modules/cash_register/controllers/open_shift_controller.dart`
- `lib/app/modules/cash_register/controllers/close_shift/close_shift_controller.dart`
- `lib/app/modules/cash_register/controllers/expenses/expenses_controller.dart`
- `lib/app/modules/cash_register/controllers/pending_closes/pending_closes_controller.dart`
- `lib/app/modules/cash_register/controllers/withdrawals_history/withdrawals_history_controller.dart`
- `lib/app/data/repositories/cashier_repository.dart`
- `lib/app/data/repositories/cash_withdrawals_repository.dart`

**Endpoints clave:**
- `POST cashier-shifts/open`
- `PUT cashier-shifts/close/cashier/{cashierId}`
- `GET cashier-shifts/{id}/summary`
- `GET cashier-shifts/by-cashier/{cashierId}` y `/by-status/{status}`
- `POST cash-withdrawals/register`
- `GET cash-withdrawals/reasons`, `/payment-sources`
- `GET cash-withdrawals/history`, `/export` (CSV)

**Detalle de tareas pendientes (Opciones de Caja):**
1. ✅ **Aprobar/Reconciliar cierre pendiente** — completado 2026-08-27.
   - Acción "Conciliar" en cards CLOSED (solo SUPER/ADMIN) → diálogo confirmación sí/no (sin inputs, fiel al móvil) → `PUT cashier-shifts/{id}/reconcile` (body vacío) → snackbar de éxito + recarga.
   - Además: nueva sección "Sin Cerrar" (turnos OPEN) con card por caja abierta; botón "Ver Arqueo" en todas las cards → modal con `ShiftSummaryModel`.
   - Nota: el plan viejo sugería "observaciones del supervisor" y `POST`, pero el móvil real usa `PUT` sin body y sin inputs. Se siguió el comportamiento del móvil.

---

## 8. Clientes (CRUD)

### Estado global: `[x]` Completado

| Funcionalidad | Estado | Notas |
|---|---|---|
| Listar todos los clientes | `[x]` | Lista de cards con avatar y datos de contacto |
| Crear cliente | `[x]` | `CustomerFormDialogComponent` (template-driven, validación imperativa `canSave()`) |
| Editar cliente | `[x]` | Mismo diálogo hidratado con datos existentes |
| Eliminar cliente | `[x]` | Confirmación `ModalInfoComponent` ("¿Está seguro de eliminar a ...?") |
| Buscar cliente por nombre/apellido/teléfono | `[x]` | `searchQuery` signal + `displayedCustomers` computed (case-insensitive contains; busca también en `document`); search-box arriba de la lista |
| Marcar cliente como predeterminado para pedidos | `[x]` | Estrella en cada card; `CustomersService.setDefault()` / `clearDefault()` persiste en `localStorage` (`APP_STORAGE_KEYS.DEFAULT_CUSTOMER`) y se aplica en TAKE_AWAY/DELIVERY desde `TakeOrderService` |
| Ver historial de pedidos por cliente (opcional) | `[ ]` | No implementado en web ni en móvil |

**Archivos clave (web):**
- `src/app/features/customers/customers.component.ts` (+ `.html`, `.scss`)
- `src/app/features/customers/customer-form-dialog.component.ts`
- `src/app/core/services/customers.service.ts` (incluye default-customer en localStorage)
- `src/app/core/config/app.constants.ts` (`APP_STORAGE_KEYS.DEFAULT_CUSTOMER`)
- `src/app/data/repositories/customer.repository.ts`
- `src/app/data/models/customer.model.ts`

**Archivos clave (móvil — referencia):**
- `lib/app/modules/customers/controllers/customers_controller.dart`
- `lib/app/modules/customers/views/customers_view.dart`
- `lib/app/modules/customers/bindings/customers_binding.dart`
- `lib/app/data/repositories/customer_repository.dart`
- `lib/app/data/models/customer_model.dart`

**Endpoints clave:**
- `GET customers/all`
- `POST customers/create`
- `PUT customers/update/{id}`
- `DELETE customers/delete/{id}`

---

## 9. Mesas (CRUD)

### Estado global: `[x]` Completado

| Funcionalidad | Estado | Notas |
|---|---|---|
| Listar mesas con filtro por estado/ubicación | `[x]` | Grid de cards + chips de estado (Todas/Disponibles/Ocupadas/Reservadas) + `mat-select` de ubicación + búsqueda libre por nombre/ubicación; signals `statusFilter`/`locationFilter`/`searchQuery` + `displayedTables` computed |
| Crear mesa | `[x]` | `TableFormDialogComponent` (form reactivo/select de estado) |
| Editar mesa | `[x]` | Mismo diálogo hidratado |
| Eliminar mesa | `[x]` | Confirmación `ModalInfoComponent`; modal secundario si la mesa tiene pedidos asociados |
| Reservar mesas (`reserveTables`) | `[x]` | Selección múltiple (tap) con FAB contextual; `PUT tables/reserve` con `tableIds[]` |
| Liberar mesas (`releaseTables`) | `[x]` | FAB contextual cuando todas las seleccionadas están OCCUPIED/RESERVED; `PUT tables/release` con `tableIds[]` |
| Visualización de estados (AVAILABLE/OCCUPIED/RESERVED) | `[x]` | Badge coloreado (verde/naranja/azul) + borde cuando seleccionada |

**Archivos clave (web):**
- `src/app/features/tables/tables.component.ts` (+ `.html`, `.scss`)
- `src/app/features/tables/table-form-dialog.component.ts`
- `src/app/core/services/tables.service.ts` (incluye `applyBranchFilter` por `X-Branch-Id`)
- `src/app/data/repositories/tables.repository.ts` (con `ReserveTablesRequest` / `ReleaseTablesRequest`)
- `src/app/data/models/table.model.ts`

**Archivos clave (móvil — referencia):**
- `lib/app/modules/tables/controllers/tables_controller.dart`
- `lib/app/modules/tables/views/tables_view.dart`
- `lib/app/data/repositories/tables_repository.dart`
- `lib/app/data/models/table_model.dart` + `table_status_model.dart`

**Endpoints clave:**
- `GET tables/all`, `GET tables/by-status/AVAILABLE`
- `POST tables/create`, `PUT tables/update/{id}`, `DELETE tables/delete/{id}`
- `PUT tables/reserve`, `PUT tables/release` (body `{ tableIds: string[] }`)
- `GET tables/statuses`

---

## 10. Menú (Categorías, Subcategorías, Productos, Recetas)

### Estado global: `[x]` Completado

| Funcionalidad | Estado | Notas |
|---|---|---|
| Listar categorías (con subcategorías y productos anidados) | `[x]` | Tabs `MatTabsModule` por categoría + `MatExpansionPanel` por subcategoría (expandidas) + lista de productos |
| Crear/editar categoría | `[x]` | `CategoryFormDialogComponent` (name + description, ambos requeridos por el backend) |
| Crear/editar subcategoría | `[x]` | `SubcategoryFormDialogComponent` (name requerido, description opcional, inyecta `categoryId` automáticamente) |
| Crear/editar producto | `[x]` | `ProductFormDialogComponent` (tipo, precios, requires_recipe, option_only); payload sigue reglas del móvil (POST en array, PUT objeto) |
| Productos con múltiples precios (VARIABLE + `sizeLabel`) | `[x]` | Filas dinámicas Tamaño + Precio; `size_label` solo se envía si VARIABLE y no vacío; separador de miles (`parseThousands`/`formatThousands`) |
| Productos tipo COMBO con grupos y opciones | `[x]` | `ComboEditorDialogComponent` con `mat-select` filtrable de productos SIMPLE no usados; remove (con confirmación) / restore; `refreshCombo` recarga el árbol tras cada acción |
| Productos tipo COMBINADO (2x1) | `[x]` | El producto se crea con `productType: 'COMBINADO'`; venta ya gestionada por `TakeOrderService` |
| Recetas de producto (asociación con insumos) | `[x]` | `RecipeFormDialogComponent` — base o por variante; `MenuService.saveRecipe` / `deleteRecipe` / `saveAllRecipes` (bulk) |
| Guardar receta completa por variante de precio | `[x]` | Botón "Guardar todas" en VARIABLE → `POST inventory/recipes/{id}/bulk` |
| Asignar impresora/zona a categoría | `~~Descartado~~` | No aplica en web |
| Eliminar categoría / subcategoría / producto | `~~Descartado~~` | El backend lo expone pero el móvil no tiene UI; web sigue la paridad (no hay botones de eliminar) |
| Activar/desactivar producto (`active`) | `~~Descartado~~` | El backend lo expone pero el móvil no tiene UI; paridad |

**Reglas de negocio replicadas (idénticas al móvil):**
- `start_date` siempre = hoy a medianoche (`yyyy-MM-dd'T'HH:mm:ss`).
- `option_only === true` ⇒ oculta sección de precios y fuerza `[{ amount: 0, start_date: hoy, end_date: null }]`.
- Cambiar tipo a ≠ VARIABLE colapsa el array de precios a 1.
- Combo editor: solo productos `SIMPLE` con id que **no estén ya como opción** en ningún grupo; confirmación para desactivar ("Ya no aparecerá en nuevos pedidos") y reactivar.
- Recetas: ≥1 ingrediente con `quantity > 0` por variante; eliminar receta con confirmación `ModalInfoComponent`.
- Recarga completa de `categories/all` tras cada mutación (no optimistic updates), igual que el móvil.
- Sin WebSocket en este módulo (paridad con móvil).
- Éxitos vía `MatSnackBar` (patrón web); textos iguales a los mensajes del móvil.

**Archivos clave (web):**
- `src/app/core/services/menu.service.ts` (CRUD categorías/subcategorías/productos, recetas, opciones de combo, `getAllSimpleProducts`, `findComboById`)
- `src/app/features/menu/menu.component.ts` (+ `.html`, `.scss`) — tabs + sub-accordion + product list con menú contextual
- `src/app/features/menu/dialogs/category-form-dialog.component.ts`
- `src/app/features/menu/dialogs/subcategory-form-dialog.component.ts`
- `src/app/features/menu/dialogs/product-form-dialog.component.ts`
- `src/app/features/menu/dialogs/recipe-form-dialog.component.ts` **(nuevo)**
- `src/app/features/menu/dialogs/combo-editor-dialog.component.ts` **(nuevo)**
- `src/app/core/services/menu.service.spec.ts` + `src/app/features/menu/menu.component.spec.ts` **(nuevos, Vitest)**
- `src/app/data/repositories/categories.repository.ts` (extendido con `createSubcategory` / `updateSubcategory`)
- `src/app/data/repositories/products.repository.ts`
- `src/app/data/repositories/combos.repository.ts` (corregido: `toggleOption` ahora usa `PATCH combos/options/{id}/toggle`)
- `src/app/data/repositories/inventory.repository.ts` (extendido con `getItems` tipado, `getRecipesForProduct`, `saveRecipe`, `saveAllRecipes`, `deleteRecipe(?priceVariantId=)`)
- `src/app/data/models/category.model.ts` (+ `description?` en Category/Subcategory)
- `src/app/data/models/product.model.ts` (`PriceModel.productId` → `product_id?`, + `end_date?`)
- `src/app/data/models/inventory.model.ts` (`ProductRecipeModel` + `priceVariantId`/`priceVariantLabel`; `InventoryItemModel` + `minStock?`/`stockStatus?`)

**Archivos clave (móvil — referencia):**
- `lib/app/modules/menu/controllers/menu_controller.dart`
- `lib/app/modules/menu/views/menu_view.dart`
- `lib/app/modules/menu/views/widgets/menu_forms.dart` (`CategoryFormDialog`, `SubcategoryFormDialog`, `ProductFormDialog`)
- `lib/app/modules/menu/views/widgets/combo_editor_dialog.dart`
- `lib/app/core/utils/modals/recipe_form_dialog.dart`
- `lib/app/data/repositories/categories_repository.dart`
- `lib/app/data/repositories/combos_repository.dart`
- `lib/app/data/repositories/inventory_repository.dart` (recetas)
- `lib/app/data/models/category_model.dart` (re-exporta subcategory, product, combo)

**Endpoints clave:**
- `GET categories/all`
- `POST categories/create` (array), `PUT categories/update/{id}` (objeto)
- `PATCH categories/{id}/printer` *(existe, no usado en web)*
- `POST subcategories/create` (array), `PUT subcategories/update/{id}`
- `POST products/create` (array), `PUT products/update/{id}`
- `GET products/types` *(existe, no usado en web — los tipos vienen hardcoded del enum)*
- `POST combos/groups/{groupId}/options` (body `{productId}`)
- `DELETE combos/options/{optionId}`
- `PATCH combos/options/{optionId}/toggle`
- `GET inventory/items` (picker de insumos para recetas)
- `GET inventory/recipes/{productId}`
- `POST inventory/recipes/{productId}` (single)
- `POST inventory/recipes/{productId}/bulk` (todas las variantes)
- `DELETE inventory/recipes/{productId}?priceVariantId=...`

---

## 11. Usuarios (CRUD)

### Estado global: `[x]` Completado

| Funcionalidad | Estado | Notas |
|---|---|---|
| Listar usuarios | `[x]` | Lista de cards con datos (username, nombre, email, roles) |
| Crear usuario (asignar roles + sucursales) | `[x]` | `UserFormDialogComponent` con checkboxes múltiples de roles (carga `roles/all`); envío `isActive` |
| Editar usuario | `[x]` | Mismo diálogo hidratado (roles preseleccionados, isActive editable) |
| Eliminar usuario | `[x]` | Confirmación `ModalInfoComponent` |
| Resetear contraseña (genera temporal) | `[x]` | `PATCH users/{id}/reset-password`; muestra la contraseña temporal generada en snackbar |
| Activar/desactivar usuario (`toggle-status`) | `[x]` | Switch en cada card; `PATCH users/{id}/toggle-status` |
| Asignar módulos al usuario | `[~]` | El backend lo gestiona vía login (`LoginResponse.modules`); la UI web no edita módulos del usuario (igual que el móvil: los módulos vienen del rol y se gestionan en otro flujo) |

**Archivos clave (web):**
- `src/app/features/users/users.component.ts` (+ `.html`, `.scss`)
- `src/app/features/users/user-form-dialog.component.ts`
- `src/app/core/services/users.service.ts`
- `src/app/data/repositories/users.repository.ts` (incluye `resetPassword` y `toggleStatus` con `PATCH .../{id}/...`)
- `src/app/data/models/user.model.ts`

**Archivos clave (móvil — referencia):**
- `lib/app/modules/users/controllers/users_controller.dart`
- `lib/app/modules/users/views/users_view.dart`
- `lib/app/data/repositories/users_repository.dart`
- `lib/app/data/models/user_model.dart` + `user_role.dart`

**Endpoints clave:**
- `GET users/all`, `GET users/{id}`, `GET roles/all`
- `POST users/create`, `PUT users/update/{id}`, `DELETE users/delete/{id}`
- `PATCH users/{id}/reset-password`
- `PATCH users/{id}/toggle-status`
- `PATCH users/me/change-password` *(usado por Perfil, no por este módulo)*

---

## 12. Métodos de Pago (configuración)

### Estado global: `[x]` Completado

| Funcionalidad | Estado | Notas |
|---|---|---|
| Listar métodos de pago (activos e inactivos) | `[x]` | Lista de cards ordenada por `displayOrder` (PaymentMethodsService) |
| Editar método (displayName, active, displayOrder) | `[x]` | `PaymentMethodFormDialogComponent` (update-only): displayName, active, displayOrder; `PUT payment-methods/config/{method}` |
| Activar/desactivar método | `[x]` | Switch dentro del diálogo de edición; persiste en el mismo `PUT` |

**Archivos clave (web):**
- `src/app/features/payment-methods/payment-methods.component.ts` (+ `.html`, `.scss`)
- `src/app/features/payment-methods/payment-method-form-dialog.component.ts`
- `src/app/core/services/payment-methods.service.ts`
- `src/app/data/repositories/payment-methods.repository.ts`
- `src/app/data/models/payment-method.model.ts`

**Archivos clave (móvil — referencia):**
- `lib/app/modules/payment_methods/controllers/payment_methods_controller.dart`
- `lib/app/modules/payment_methods/views/payment_methods_view.dart`
- `lib/app/modules/payment_methods/views/widgets/payment_method_form_modal.dart`
- `lib/app/data/repositories/payment_methods_repository.dart`
- `lib/app/data/models/payment_method_model.dart`

**Endpoints clave:**
- `GET payment-methods/config/active` (consumido por `TransactionModalComponent` en Pagos)
- `GET payment-methods/config` (lista completa en este módulo)
- `PUT payment-methods/config/{method}`

---

## 13. Inventario

### Estado global: `[x]` Completado

| Funcionalidad | Estado | Notas |
|---|---|---|
| **Items / Insumos**: listar, crear, editar, eliminar | `[x]` | `InventoryItemFormDialogComponent`: name, unit (9 valores: KG/G/L/ML/UNIT/CAJA/OZ/LB/DOCENA), currentStock (solo al crear), minStock; validaciones ≥ 0; al editar muestra caja informativa del stock actual + hint "Para modificar el stock usa Agregar Movimiento" |
| **Alertas** de stock mínimo | `[x]` | Tab dedicada; el color del avatar y del badge varía por `stockStatus` (`OUT` rojo / `LOW` naranja / `OK` verde) |
| **Movimientos** manuales (PURCHASE, ADJUSTMENT_POSITIVE, ADJUSTMENT_NEGATIVE, WASTE, INITIAL) | `[x]` | `ManualMovementDialogComponent`: insumo + tipo (5 opciones manuales con indicador +/−) + cantidad > 0 (helper text "El tipo decide si suma o resta") + notas; backend descuenta automáticamente |
| Productos asociados a un insumo | `[x]` | `AssociatedProductsDialogComponent` muestra nombre, tipo, variante y cantidad consumida por unidad |
| **Recetas**: vincular insumos a productos | `[x]` | Implementado en el módulo **Menú** (`RecipeFormDialogComponent` + `MenuService.saveRecipe` / `saveAllRecipes` / `deleteRecipe`). Paridad con móvil: editor por variante + bulk save. (El botón "Configurar receta" aparece en el menú contextual de los productos con `requiresRecipe`.) |
| Export PDF / Excel de insumos | `[x]` | Solo en el tab Insumos: dos botones estilo Reportes (`jspdf`+`autotable` para PDF, `xlsx` para Excel) que generan el archivo client-side desde el `ReportExportService.buildFromInventoryItems(items)` (resumen Total/Sin stock/Stock bajo/OK + tabla Nombre/Unidad/Stock actual/Stock mínimo/Estado). El tab Movimientos no tiene exportación (ni CSV ni PDF/Excel). Reemplaza al antiguo Export CSV via backend. |

**Reglas de paridad con móvil:**
- Carga inicial en paralelo: `items` + `alerts` + `movements`.
- `canEdit` (SUPER/ADMINISTRADOR) oculta FAB y acciones de escritura; el resto ve solo lectura + "Ver productos".
- En la creación se envía `currentStock`; en la edición **no** (stock se modifica solo vía movimientos manuales).
- Tipos de movimiento ofrecidos en el formulario (5): `PURCHASE/ADJUSTMENT_POSITIVE/INITIAL (+)` y `ADJUSTMENT_NEGATIVE/WASTE (−)`. El filtro de movimientos en la UI lista 7 tipos (incluye `SALE` y no incluye `SALE_REVERSAL`).
- Recarga completa (`items + alerts + movements`) tras cada mutación, igual que el móvil.
- `stockStatus` con tres valores: `OUT/LOW/OK` (renderer: color del avatar y del badge).
- `isOutput` para movimiento = `SALE | WASTE | ADJUSTMENT_NEGATIVE` (icono/rojo) — resto azul.
- Cards de movimiento: badge "Manual" vs "Venta" + `typeDescription` del backend + fecha `dd/MM/yyyy HH:mm` + cantidad coloreada.
- Empty state distinto cuando hay filtros activos.

**Archivos clave (web):**
- `src/app/core/services/inventory.service.ts` (con `canEdit` + filtros + CSV)
- `src/app/core/services/inventory.service.spec.ts` **(nuevo, Vitest)**
- `src/app/features/inventory/inventory.component.ts` (+ `.html`, `.scss`) — 3 tabs + FAB contextual + cards
- `src/app/features/inventory/dialogs/inventory-item-form-dialog.component.ts`
- `src/app/features/inventory/dialogs/manual-movement-dialog.component.ts`
- `src/app/features/inventory/dialogs/associated-products-dialog.component.ts`
- `src/app/data/repositories/inventory.repository.ts` (CRUD items + movimientos + asociados + exports + recetas)
- `src/app/data/models/inventory.model.ts` (alineado al backend: 9 unidades, 7 tipos de movimiento, `StockMovementModel` con `notes/manual/typeDescription`, + `AssociatedProductModel`)
- `src/app/core/config/url-paths.ts` (`INVENTORY_ITEM_PRODUCTS` corregido a `inventory/items/{id}/products`)

**Archivos clave (móvil — referencia):**
- `lib/app/modules/inventory/controllers/inventory_controller.dart`
- `lib/app/modules/inventory/views/inventory_view.dart`
- `lib/app/modules/inventory/views/widgets/inventory_item_form_dialog.dart`
- `lib/app/modules/inventory/views/widgets/manual_movement_dialog.dart`
- `lib/app/modules/inventory/views/widgets/inventory_item_card.dart`
- `lib/app/modules/inventory/views/widgets/stock_movement_card.dart`
- `lib/app/data/repositories/inventory_repository.dart`
- `lib/app/data/models/inventory_item_model.dart`
- `lib/app/data/models/stock_movement_model.dart`
- `lib/app/data/models/associated_product_model.dart`

**Endpoints clave:**
- `GET inventory/items` (lista completa, todos los autenticados)
- `GET inventory/items/alerts` (insumos con stock bajo / sin stock)
- `POST inventory/items`, `PUT inventory/items/{id}`, `DELETE inventory/items/{id}` (admin)
- `GET inventory/items/{id}/products` (productos vinculados vía receta)
- `GET inventory/movements?inventoryItemId=&type=&fromDate=&toDate=` (filtros opcionales)
- `POST inventory/movements` (movimiento manual, admin)
- `GET inventory/items/export`, `GET inventory/movements/export` (CSV admin, respeta filtros)

---

## 14. Datos Fiscales

### Estado global: `[x]` Completado

| Funcionalidad | Estado | Notas |
|---|---|---|
| Listar datos fiscales por sucursal | `[x]` | `FiscalDataService.loadActive(branchId)` carga el fiscal data activo de la sucursal actual (filtrado por `X-Branch-Id` del interceptor) |
| Crear/editar datos fiscales (DIAN) | `[x]` | Form único `FiscalDataComponent` que detecta create/edit automáticamente según `getActive(branchId)`: si existe → edita ese único registro; si no → crea. Todos los campos del backend (`FiscalDataRequestDTO`) |
| Solo un fiscal data activo por sucursal | `[x]` | Backend lo garantiza; el cliente solo expone el activo y permite reemplazar/editar |
| Marcar un fiscal data como activo | `[x]` | `PATCH fiscal-data/{id}/activate` desde el repositorio (no expuesto en UI actualmente: el alta/edición ya activa implícitamente) |

**Campos del formulario (portado del móvil):**
- businessName, taxId, taxIdDigit
- address, city, department
- dianResolution, resolutionStartDate, resolutionEndDate
- invoicePrefix, resolutionNumberFrom, resolutionNumberTo
- taxRegime (SIMPLE / ORDINARIO / NO_RESPONSABLE_IVA)
- email, phone, website

**Archivos clave (web):**
- `src/app/features/fiscal-data/fiscal-data.component.ts` (+ `.html`, `.scss`)
- `src/app/core/services/fiscal-data.service.ts` (con `loadActive` + `create` + `update`)
- `src/app/data/repositories/fiscal-data.repository.ts` (incluye `activate(id)` con PATCH `/{id}/activate`)
- `src/app/data/models/fiscal-data.model.ts`

**Archivos clave (móvil — referencia):**
- `lib/app/modules/fiscal_data/controllers/fiscal_data_controller.dart`
- `lib/app/modules/fiscal_data/views/fiscal_data_view.dart`
- `lib/app/data/repositories/fiscal_data_repository.dart`
- `lib/app/data/models/fiscal_data_model.dart`

**Endpoints clave:**
- `GET fiscal-data/active?branchId=...`
- `GET fiscal-data/all`
- `GET fiscal-data/{id}`
- `POST fiscal-data/create`
- `PUT fiscal-data/update/{id}`
- `PATCH fiscal-data/{id}/activate`
4. Vista de "datos fiscales activos"

---

## 15. Reportes

### Estado global: `[x]` Completado

| Funcionalidad | Estado | Notas |
|---|---|---|
| Reporte por rango de fechas (dateRange) | `[x]` | `dateRange` → `GET reports/sales?startDate&endDate`; inputs nativos `<input type="date">` |
| Reporte por rango exacto de fecha-hora | `[x]` | `exactDateTimeRange` → `GET reports/sales/datetime?startDateTime&endDateTime`; inputs nativos `date` + `time`; formato `yyyy-MM-dd'T'HH:mm:00` |
| Reporte por ID de turno (shift) | `[x]` | `shiftById` → `GET reports/sales/shift/{shiftId}`; input + botón Consultar |
| Reporte por fecha de apertura de turno | `[x]` | `shiftByDate` → `GET reports/sales/shift?openDate` |
| Reporte de ventas por productos seleccionados (fecha-hora + checklist) | `[x]` | `productSales` → `GET reports/sales/products?...&productIds=a,b,c`; `ProductSelectionComponent` con checklist árbol (categorías expandibles, subcategoría con tri-state, productos, "Seleccionar todos" / "Limpiar") |
| Reporte "Top de Productos Vendidos" (rango fecha-hora) | `[x]` | `topProducts` → `GET reports/sales/top-products`; `TopProductsResultsComponent` con ranking y top-3 oro/plata/bronce |
| **Reporte de Órdenes Anuladas** (rango fecha-hora) | `[x]` | `annulledOrders` → `GET reports/orders/annulled`; `AnnulledOrdersResultsComponent` con badges `Venta pagada`/`Anulada pre-pago`, motivo, anulado por, fecha, mesero, cliente, factura, turno, cajero, propinas y chips de métodos de pago |
| Exportación a PDF/Excel | `[x]` | `ReportExportService` con builders genéricos por tipo; PDF vía `jspdf` + `jspdf-autotable` (resumen + tablas); Excel vía `xlsx` (hoja de resumen + una hoja por sección); botones "PDF"/"Excel" en la cabecera, deshabilitados sin resultados. **Extra web** — el móvil solo visualiza (no exporta). |

**Reglas de paridad con móvil:**
- Selector de tipo con las 7 opciones (mismo enum `ReportType`).
- `dateRange` y `shiftByDate` auto-consultan al cambiar fechas; `shiftById` requiere botón "Consultar"; `exactDateTimeRange`/`productSales`/`topProducts`/`annulledOrders` también requieren botón "Consultar" (se valida `startDateTime <= endDateTime`).
- `productSales` requiere ≥1 producto seleccionado (mensaje de error si está vacío, igual que el móvil).
- Auto-fetch de `categories/all` al cambiar a `productSales` (carga única cacheada en el servicio).
- Summary cards (Transacciones / Ventas / Propinas / Ingreso Bruto) + Desglose por medios de pago + Resumen por cajero, replicando el formato móvil.
- Resultados de productos: `Veces vendido / Unidades / Ingreso` por producto; ranking top con chips `uds/veces/%`; anuladas con filas de detalle y chips de pagos.

**Archivos clave (web):**
- `src/app/core/services/reports.service.ts` (con `ReportsService`, enum `ReportType`, `REPORT_TYPE_OPTIONS`, validaciones, helpers de fecha)
- `src/app/core/services/reports.service.spec.ts` **(nuevo, Vitest)**
- `src/app/core/services/report-export.service.ts` (PDF + Excel genérico)
- `src/app/features/reports/reports.component.ts` (+ `.html`, `.scss`)
- `src/app/features/reports/widgets/product-selection.component.ts`
- `src/app/features/reports/widgets/product-sales-results.component.ts`
- `src/app/features/reports/widgets/top-products-results.component.ts`
- `src/app/features/reports/widgets/annulled-orders-results.component.ts`
- `src/app/data/repositories/reports.repository.ts` (7 métodos alineados al backend)
- `src/app/data/models/sales-report.model.ts` (10 interfaces: `SalesReportResponse`, `ShiftSalesReportResponse`, `ProductSalesReportResponse`, `AnnulledOrdersReportResponse`, `ReportPaymentMethodSummary`, `ReportCashierSummary`, `ReportShiftStatus`, `ProductSalesSummary`, `AnnulledOrderSummary`, `PaymentMethodInfo`)
- `src/app/core/config/url-paths.ts` (+ `PRODUCT_SALES_REPORT`, `TOP_PRODUCTS_REPORT`, `ANNULED_ORDERS_REPORT`)

**Archivos clave (móvil — referencia):**
- `lib/app/modules/reports/controllers/reports_controller.dart`
- `lib/app/modules/reports/views/reports_view.dart`
- `lib/app/modules/reports/views/widgets/product_selection_section.dart`
- `lib/app/modules/reports/views/widgets/product_sales_results_view.dart`
- `lib/app/modules/reports/views/widgets/top_products_results_view.dart`
- `lib/app/modules/reports/views/widgets/annulled_orders_results_view.dart`
- `lib/app/data/repositories/reports_repository.dart`
- `lib/app/data/repositories/categories_repository.dart` (catálogo cargado para el checklist)
- `lib/app/data/models/sales_report_response.dart`
- `lib/app/data/models/shift_sales_report_response.dart`
- `lib/app/data/models/product_sales_report_response.dart`
- `lib/app/data/models/annulled_orders_report_response.dart`

**Endpoints clave:**
- `GET reports/sales?startDate=...&endDate=...`
- `GET reports/sales/datetime?startDateTime=...&endDateTime=...`
- `GET reports/sales/shift/{shiftId}`
- `GET reports/sales/shift?openDate=...`
- `GET reports/sales/products?startDateTime=...&endDateTime=...&productIds=a,b,c`
- `GET reports/sales/top-products?startDateTime=...&endDateTime=...`
- `GET reports/orders/annulled?startDateTime=...&endDateTime=...`

---

## 16. Perfil

### Estado global: `[x]` Completado

| Funcionalidad | Estado | Notas |
|---|---|---|
| Cambio de contraseña autenticado (currentPassword + newPassword + confirmación) | `[x]` | `PATCH users/me/change-password` con `{currentPassword, newPassword}`; validaciones (requerido, sin espacios, min 6, max 100, coincidencia con confirmación); toggles de visibilidad por campo; loading + snackbar "Contraseña cambiada exitosamente" + reset |
| Persistir y leer `defaultTipPercentage` | `[x]` | Card dedicada: input numérico + botones sugeridos 0/5/10/15 + guardar → `StorageService.saveDefaultTipPercentage`. Persistencia ya existía desde Pagos (sección 6); aquí se añade un editor dedicado |
| Toggle "Solo ver mis pedidos" (mesero) | `[x]` | Ya implementado en el drawer del Home (sección 4): `mat-slide-toggle` "Solo ver mis pedidos" visible solo para rol MESERO → `PATCH branches/{branchId}/waiter-filter`. No se duplica aquí; el control se gestiona desde el drawer |
| Información del usuario actual | `[x]` | Card superior: avatar con iniciales, nombre, sucursal activa (resaltada), lista de sucursales disponibles, roles (chips formateados), módulos |

**Acceso a la pantalla**: el header del sidenav (avatar + nombre + sucursal + chevron) es clicable y navega a `/home/profile` con tooltip "Mi Perfil". La ruta existe con título "Mi Perfil" y `moduleAccessGuard` se omite (cualquier usuario autenticado).

**Archivos clave (web):**
- `src/app/features/profile/profile.component.ts` (+ `.html`, `.scss`) — 3 cards (usuario / contraseña / propina)
- `src/app/core/services/profile.service.ts` (con `changePassword()` + `isSubmitting`)
- `src/app/data/repositories/profile.repository.ts` (con `changePassword` PATCH y `updateWaiterFilter` PATCH corregidos)
- `src/app/features/home/home.component.ts` (+ `.html`, `.scss`) — header del sidenav clicable

**Archivos clave (móvil — referencia):**
- `lib/app/modules/profile/controllers/profile_controller.dart`
- `lib/app/modules/profile/views/profile_view.dart`
- `lib/app/modules/profile/repositories/profile_repository.dart`
- `lib/app/modules/change_password/controllers/change_password_controller.dart`
- `lib/app/modules/change_password/views/change_password_view.dart`

**Endpoints clave:**
- `PATCH users/me/change-password` (body: `ChangeMyPasswordRequestDTO { currentPassword, newPassword }`)
- `PATCH branches/{branchId}/waiter-filter` (body: `BranchWaiterFilterDTO { waiterViewOwnOrdersOnly }`)

**Specs Vitest**: `profile.repository.spec.ts` (2 casos: PATCH changePassword + PATCH updateWaiterFilter con branchId en path); `profile.component.spec.ts` (9 casos: render 3 cards, usuario + chip activo, roles + módulos, submit deshabilitado vacío / min 6, submit válido llama service + snackbar, sugerencia de propina, guardar inválido no persiste, guardar válido persiste + snackbar).

---

## 17. WebSocket tiempo real

### Estado global: `[x]` Completado

| Funcionalidad | Estado | Notas |
|---|---|---|
| Conexión STOMP sobre SockJS | `[x]` | `websocket.service.ts` |
| Suscripción a tópicos por branchId | `[x]` | `/topic/branch/{id}/orders/created`, `/orders/open`, `/orders/status` |
| Streams expuestos (Signals) | `[x]` | `ordersStream`, `openOrdersStream`, `orderStatusStream` |
| Reconexión automática | `[x]` | |
| Integración con Orders / Comandas / Cash Register | `[x]` | `toObservable(ws.ordersStream)` en componentes |
| Autenticación en handshake | `[x]` | Header `Authorization` en STOMP CONNECT |

**Archivos clave (web):**
- `src/app/core/services/websocket.service.ts`

**Archivos clave (móvil — referencia):**
- `lib/app/data/services/websocket_service.dart`

---

## 18. Multi-sucursal

### Estado global: `[x]` Completado

| Funcionalidad | Estado | Notas |
|---|---|---|
| Modal de selección tras login si hay >1 sucursal | `[x]` | |
| Persistencia del `branchId` activo en storage | `[x]` | |
| Header `X-Branch-Id` automático en cada request | `[x]` | `branch-id.interceptor.ts` |
| Cambio de sucursal desde la app (no implementado en ninguno de los dos proyectos) | `[ ]` | |

**Archivos clave (web):**
- `src/app/features/auth/login/widgets/branch-selection-modal.component.ts`
- `src/app/core/interceptors/branch-id.interceptor.ts`

---

## 19. Control por módulos/roles (guards)

### Estado global: `[x]` Completado

| Funcionalidad | Estado | Notas |
|---|---|---|
| Enum `AppModule` con 15 módulos | `[x]` | `core/config/app-modules.ts` |
| Enum `ERole` con 5 roles | `[x]` | SUPER, ADMINISTRADOR, MESERO, CAJERO, ? |
| Matriz `ROLE_MODULES` (rol → módulos permitidos) | `[x]` | |
| Guard `authGuard` (verifica token + branchId) | `[x]` | |
| Guard `moduleAccessGuard(AppModule.XXX)` | `[x]` | |
| Topbar muestra el título de la ruta activa | `[x]` | `HomeComponent.watchRouteTitle()` |
| Filtrado de items de menú/drawer según módulos | `[x]` | |

---

# Próximas prioridades sugeridas

## Foco 1 — Pedidos (Tomar Pedido + Lista)
1. **ComboSelectionDialogComponent** — Bloquea la venta de productos tipo COMBO
2. **Selección de Combinado 2x1** con regla "cobra el más caro"
3. **AddProductDialogComponent** para comentarios por item
4. **Agregar productos a pedido existente** desde `OrderDetailDialogComponent`
5. **Filtro mesero "solo mis pedidos"**

## Foco 2 — Pagos
1. **Reembolso de transacción (REFUND)**
2. **Anulación de venta pagada (CANCEL desde historial)** — móvil `[x]`, web `[ ]` (paridad pendiente)
3. **Cambio de método de pago post-factura** (admin/super)
4. **Precuenta** como modal visual
5. **Propina predeterminada guardable** (storage + UI en Perfil)

## Foco 3 — Módulos administrativos (stubs)
1. **Métodos de Pago (config)** — Bajo esfuerzo, desbloquea opciones en caja
2. **Clientes (CRUD)** — Necesario para mejorar la búsqueda
3. **Mesas (CRUD)** — Necesario para tomar pedidos SALON
4. **Perfil** — Para habilitar cambio de contraseña y propina predeterminada
5. **Usuarios, Menú, Inventario, Datos Fiscales, Reportes** — Mayor esfuerzo, planificar por sprints

---

# Historial de cambios del archivo

| Fecha | Cambio | Autor |
|---|---|---|
| 2026-08-19 | Creación inicial del archivo. Análisis completo de web vs móvil con todas las funcionalidades. | opencode |
| 2026-08-19 | Implementación completa de **Tomar Pedido** y **Pedidos**. Cambios: (a) `ProductType.COMBINADO` agregado; (b) `TakeOrderService` extendido con `addCombination`/`decrementCombination`/`getCombinationQuantity`/`getCombinadoSiblings`/`defaultCustomer`/`applyDefaultCustomer` y `itemTotal` corregido para combinados (solo el más caro); (c) nuevos diálogos shared `AddProductDialogComponent` y `SizeSelectorDialogComponent`; (d) nuevos diálogos feature `ComboSelectionDialogComponent` y `CombinationSelectionDialogComponent`; (e) nuevo `AddProductsDialogComponent` para agregar productos a pedido existente con catálogo + carrito temporal; (f) `OrderDetailDialogComponent` con botones "+ Productos" y "Cargos" + refresco automático; (g) `OrdersService.getOrder(id)`; (h) `StorageService` con métodos `getWaiterViewOwnOrdersOnly`/`saveWaiterViewOwnOrdersOnly`/`deleteWaiterViewOwnOrdersOnly`; (i) flag del mesero persistido en `BranchSelectionModalComponent` y `LoginComponent`; (j) filtro mesero aplicado en `OrdersService` y `CashRegisterService`; (k) `HomeComponent` con toggle `MatSlideToggle` en drawer (visible solo si rol MESERO) que actualiza `branches/waiter-filter` y recarga listas. Build verificado con `npm run build` (sin errores). | opencode |
| 2026-08-26 | Paridad orders/take-order vs móvil: (a) take-order — textarea "Observaciones generales del pedido" bound a `service.observations` y enviado en payload; (b) take-order — botón eliminar por cargo en `.surcharges-section` (`removeSurcharge(index)`); (c) take-order — anidación de subcategorías en el catálogo (`selectedCategorySubcategories`); (d) orders — búsqueda por nº/cliente/mesa (`searchQuery` + `displayedOpenOrders`/`displayedFinalizedOrders`); (e) `OrderDetailDialogComponent.statusLabel` añade `DELIVERED → 'Entregado'`. Build verificado con `npm run build`. | opencode |
| 2026-08-26 | Paridad completa del módulo **Pagos / Caja**. Cambios: (a) **Propina bidireccional** en `TransactionModalComponent` con inputs independientes %/monto/total y guarda anti-bucle; (b) **Propina predeterminada guardable** — `StorageService.saveDefaultTipPercentage()`/`getDefaultTipPercentage()` y botón guardar en el modal; (c) **REFUND** — selector de tipo + `originalTransactionId` condicional; submit envía `transactionType` + `originalTransactionId`; (d) **Precuenta** — nuevo `PrecountDialogComponent` (items agrupados, cargos, propina sugerida, TOTAL A PAGAR) con botón "Ir a cobrar" que abre el modal de pago pre-llenado; botón "Precuenta" en tarjeta de pendientes; (e) **Cambio de método de pago post-factura** — nuevo `ChangePaymentMethodDialogComponent` (total bloqueado, FormArray de pagos, motivo opcional), endpoint `PUT transactions/{id}/payment-details` (constante + repo + service), botón "Cambiar pago" en historial PAID con `transactionId` gateado por rol SUPER/ADMIN; (f) helper `isAdminOrSuper()`; (g) `transactions.repository.changePaymentDetails()` + `cash-register.service.changePaymentMethod()`. Módulo marcado `[x]` Completado. Items **descartados por paridad con móvil**: `transactions/cancel` (el móvil anula la orden) y `terminalId` en transacciones (el móvil no lo asigna). Build verificado con `npm run build`. | opencode |
| 2026-08-27 | Paridad completa del módulo **Cierres Pendientes** (`pending-closes`). Cambios: (a) **Servicio** — nuevo signal `openShifts`; `loadPendingCloses()` ahora carga en paralelo `by-status/OPEN` + `by-status/CLOSED`; nuevo método `reconcileShift(shiftId)` → `cashierRepo.reconcileShift(shiftId)` + recarga; (b) **Componente `pending-closes.component.ts`** — reestructurado en dos secciones de cards: "Sin Cerrar" (OPEN, chip naranja) y "Pendientes de Conciliar" (CLOSED, chip azul); cada card muestra shiftNumber, cajero, terminal, apertura, monto inicial; botones "Ver Arqueo" (siempre) y "Conciliar" (solo SUPER/ADMIN, en CLOSED); (c) **Nuevo `ShiftSummaryDialogComponent`** — muestra el arqueo completo del turno (cajero, terminal, estado, totales ventas/egresos/propinas, efectivo disponible/esperado/declarado, diferencia, observaciones, desglose por método de pago); (d) **Inline `ConfirmReconcileDialogComponent`** — diálogo sí/no sin inputs (fiel al móvil); tras éxito snackbar "Turno #X conciliado". Módulo 7 "Cierres pendientes" `[~]` → `[x]`. Build verificado con `npm run build`. | opencode |
| 2026-08-28 | Implementación completa de **5 módulos administrativos** que eran stubs vacíos. Cambios: (a) **Correcciones de infraestructura** — `users.repository.ts`: `resetPassword`/`toggleStatus` cambiados a `PATCH` con id en el medio de la URL; `changeMyPassword` cambiado a `PATCH`; constantes `RESET_PASSWORD`/`TOGGLE_USER_STATUS` ajustadas a `'users'`. `fiscal-data.repository.ts`: `deactivate` corregido (id en el medio); agregado `activate(id)` (PATCH `/{id}/activate`). `table.model.ts`: reemplazados `capacity`/`active` por `tableNumber?`/`branchId?`; quitado `INACTIVE` del enum. `customer.model.ts`: `taxId`→`document`, `mobileNumber`→`phone`, quitado `active`, agregado `notes?`. Ajustado `take-order` para usar `customer.phone`. (b) **Mesas** — `TablesService` + `tables.component.ts` con grid de cards coloreadas por estado (AVAILABLE/OCCUPIED/RESERVED), selección múltiple (tap) con FAB contextual Reservar/Liberar (PUT en lote), CRUD + `TableFormDialogComponent`. (c) **Clientes** — `CustomersService` (con cliente predeterminado en localStorage) + lista de cards, CRUD + `CustomerFormDialogComponent`. (d) **Usuarios** — `UsersService` + lista de cards con switch activo, botón reset password (PATCH), CRUD + `UserFormDialogComponent` con envío `isActive`. (e) **Métodos de Pago** — `PaymentMethodsService` (orden por `displayOrder`) + lista con botón editar + `PaymentMethodFormDialogComponent`. (f) **Datos Fiscales** — `FiscalDataService` + form único que detecta create/edit según `getActive(branchId)` + `FiscalDataComponent` con todos los campos DIAN. Módulos 8, 9, 11, 12, 14 `[ ]` → `[x]`. Build verificado con `npm run build` + lint OK. | opencode |
| 2026-09-01 | Reportes — agregado al alcance móvil + backend el **"Ventas por Producto (selección)"** y el **"Top de Productos Vendidos"**. Móvil: extiende `ReportsController` con 2 tipos en el dropdown + carga `CategoriesRepository` para el checklist, nuevos widgets `ProductSelectionSection` / `ProductSalesResultsView` / `TopProductsResultsView`, modelo `product_sales_report_response.dart`, métodos en `ReportsRepository`, constantes `getProductSalesReport` / `getTopProductsReport` en `UrlPaths`, registro de `CategoriesRepository` en `ReportsBinding`. Backend (`restic-back`): DTOs `ProductSalesReportResponseDTO` / `ProductSalesSummaryDTO`; queries JPQL nuevas en `OrderDetailRepository`; `ProductSalesReportService` + Impl agregado en `reports/` con agregación en memoria y chunking de IN(500) para escalar; dos endpoints `@AdminAccess` (`reports/sales/products`, `reports/sales/top-products`); test unitario con 8 casos; `TECHNICAL_DOCUMENTATION.md` actualizado. Reglas alineadas con el resto de reportes: solo SALE+COMPLETED, detalles CANCELED excluidos, filtrado por `X-Branch-Id`. Web sigue `[ ]` (mantener en el TODO). Mobile-first, build verificado (`mvn compile` + 8 unit tests + `flutter test` para reports y model OK). | opencode |
| 2026-09-01 | Reportes — **removido el detalle individual de eventos** del reporte "Ventas por Producto" (pantalla sobrecargada con info poco relevante). Móvil: eliminado el bloque "Detalle de ventas (con hora)" en `ProductSalesResultsView` (cards de hora/pedido/subtotal) y la clase `ProductSaleEvent` del modelo, junto con assertions en tests del controller/modelo. Backend: eliminado `ProductSaleEventDTO` y el campo `events` de `ProductSalesSummaryDTO`; `ProductSalesReportServiceImpl` simplificado (ya no construye eventos ni ordena `Set<UUID> orderIds` en lugar de `Map<UUID, LocalDateTime> orderIdToSoldAt`; `ProductAccumulator` sin lista de eventos); javadoc del endpoint `/sales/products` actualizado. Tests backend reescritos sin assertions de eventos (8/8 pasan). `TECHNICAL_DOCUMENTATION.md` y manual `reportes.md` actualizados (sin bullets de detalle con hora, sin tip de "si solo te interesa la frecuencia"). | opencode |
| 2026-09-01 | Cierre de caja — **modal de confirmación con el monto declarado** antes de consumir el servicio (evita cierres con el monto en blanco o erróneo). Móvil: en `CloseShiftView`, antes de invocar `submitCloseShift()` se muestra `ModalInfo` (`barrierDismissible: false`) con título "Confirmar Cierre de Caja", el monto declarado formateado `es_CO`, y los botones "Sí, Cerrar Caja" / "Cancelar". Solo en "Sí" se llama al servicio (y luego al modal de éxito existente). Si el monto es ≤ 0, se omite el modal y se delega al diálogo de error ya existente. Para soportar el icono no-impresora del botón secundario se añadió el parámetro opcional `secondaryButtonIcon` a `ModalInfo` (default `Icons.print`, compatible con los 5 usos existentes). Controller: expuesto `parseDeclaredAmount()` (la parseo antes vivía en privado en `_parseAmount` y ahora se reutiliza). Tests: 2 casos nuevos de `parseDeclaredAmount` (4/4 pasan). Manual `cierre-caja.md`: nuevo paso 8 con confirmación y screenshot marker `close-shift-confirm.png`. | opencode |
| 2026-09-03 | Reubicación del toggle "Solo ver mis pedidos (meseros)" del `CustomDrawer` a una pantalla dedicada **"Ajustes de Pedidos"** (`/settings/orders`). Nuevo módulo `order_settings` con `OrderSettingsBinding`/`OrderSettingsController`/`OrderSettingsView` (CustomScaffold + ExpandableSection). El `SwitchListTile` que estaba inline en el ExpansionTile "Configuración" del drawer (desajuste: control embebido entre ítems de navegación) se movió a esta pantalla; el drawer ahora solo tiene el sub-ítem "Ajustes de Pedidos" (visible para ADMIN/SUPER). El controller delega en `HomeController` (PATCH `branches/{branchId}/waiter-filter` + notificación a `OrdersController` se mantienen intactos). Tests: actualizado `custom_drawer_test.dart` (caso ADMIN ve "Ajustes de Pedidos", caso MESERO no lo ve) + nuevo `order_settings_view_test.dart` (render, toggle llama al setter, switch deshabilitado para no-admin con aviso). `dart analyze` limpio, `flutter test` (módulos afectados) 7/7 pasan. Manual `gestionar-pedidos.md` (§"Filtro Solo ver mis pedidos") y `roles-permisos.md` actualizados con la nueva ruta de navegación. | opencode |
| 2026-09-08 | **Módulo Menú completo** (sección 10 `[ ]` → `[x]`) + correcciones de paridad + pequeñas mejoras en CRUDs. Cambios web: (a) **Correcciones de infraestructura**: `combos.repository.toggleOption` corregido de `PUT combos/options/toggle/{id}` a `PATCH combos/options/{id}/toggle` (era la única ruta que el backend expone y la única que el móvil usa); `category.model` + `description?` en Category/Subcategory; `product.model.PriceModel.productId` → `product_id?` + `end_date?`; `inventory.model.ProductRecipeModel` + `priceVariantId?`/`priceVariantLabel?` + `InventoryItemModel` + `minStock?`/`stockStatus?`; `inventory.repository` extendido con `getItems` tipado + `getRecipesForProduct` + `saveRecipe` + `saveAllRecipes` + `deleteRecipe(?priceVariantId=)`; `categories.repository` extendido con `createSubcategory`/`updateSubcategory`. (b) **Clientes**: búsqueda por nombre/apellido/teléfono/documento (`searchQuery` signal + `displayedCustomers` computed). (c) **Mesas**: chips de filtro por estado (Todas/Disponibles/Ocupadas/Reservadas) + `mat-select` por ubicación + búsqueda libre; `displayedTables` computed. (d) **`MenuService`**: CRUD de categorías/subcategorías/productos (POST array, PUT objeto), recetas (base/variante/bulk/delete), opciones de combo (add/remove/toggle + `refreshCombo`); recarga completa de `categories/all` tras cada mutación (fiel al móvil). (e) **Componente menú**: tabs por categoría, sub-accordion por subcategoría, lista de productos con menú contextual (Editar / Configurar receta si `requiresRecipe` / Administrar combo si COMBO), badges de tipo, FAB "Nueva Categoría", variantes VARIABLE con filas `size_label — precio`, badge "Opción" si `option_only`. (f) **Diálogos**: `category-form-dialog`, `subcategory-form-dialog`, `product-form-dialog` (reglas idénticas al móvil: `option_only` oculta precios y fuerza `{amount:0, start_date: hoy}`, tipo ≠ VARIABLE colapsa a 1 precio, `size_label` solo si VARIABLE no vacío), `recipe-form-dialog` (selector de variante + filas por variante + bulk), `combo-editor-dialog` (mat-select con búsqueda de productos SIMPLE no usados; remove/restore con confirmación; refresh tras cada acción). (g) **Specs Vitest básicos**: `menu.service.spec.ts` (7 casos: loadAll, payloads array/objeto, PATCH toggle, getAllSimpleProducts, findComboById) y `menu.component.spec.ts` (2 casos: empty-state + render con fixture); `vitest.setup.ts` extendido con `initTestEnvironment` + `zone.js`. (h) **Paridad**: sin botones de delete (móvil no los tiene), sin WebSocket en menú (móvil no lo usa), zonas de impresión descartadas, errores vía `ErrorService`. Tabla resumen actualizada (fila 6 `[~]` → `[x]`; fila 7 pendiente "—"). Secciones 8/9/11/12 actualizadas a `[x]` con notas reales y archivos clave. Build OK (`npm run build`), lint OK (`npm run lint`), tests 9/9 OK (`npm test`). | opencode |
| 2026-09-10 | **Anulación de venta pagada (CANCEL desde historial)** — móvil `[x]`, web `[ ]` (paridad pendiente). (a) **Backend (`restic-back`)**: nueva migración `V25_0__add_transaction_cancelled_by.sql` (columna `cancelled_by_id` en `transactions` + reemplazo del CHECK `ck_stock_movements_type` para incluir `SALE_REVERSAL`); entidad `Transaction` + relación `cancelledBy` (LAZY); enum `StockMovementType` + `SALE_REVERSAL`; `InventoryItemRepository.restoreStock` (UPDATE atómico) y `StockMovementRepository.findByReferenceOrderIdAndType`; nuevo `StockRestoreService` (interfaz + Impl) que revierte los `StockMovement` `SALE` de la orden y crea los `SALE_REVERSAL`; `TransactionServiceImpl.cancelTransaction` extendido con orquestación completa (turno OPEN, lock pesimista, orden `PAID→CANCELED`, restauración de inventario, `cancelledBy`, log WARN, WebSocket); `TransactionResponseDTO` + `cancelledById`/`cancelledByName`; `TransactionMapper` actualizado; tests cubriendo happy path + rechazos. (b) **Móvil (`restic-movil`)**: `UrlPaths.cancelTransaction`; `TransactionsRepository.cancelTransaction` (PUT body con `cancellationReason`); `CashRegisterController` + flag `canAnnulTransactions` (SUPER/ADMIN) + `confirmAnnulTransaction`/`submitAnnulTransaction`; nuevo `AnnulTransactionDialog` (`CustomFormDialog` con `autoClose: false`, motivo obligatorio, advertencia del #orden/monto y consecuencias); botón "Anular" en `GlobalOrderCard` (tab Historial) gateado por `isHistoryPaid && canAnnulTransactions`. (c) **Pendiente web**: replicar el flujo en el tab Historial de Pagos con el mismo orden de botones (mantener paridad con móvil). | opencode |
| 2026-09-10 | **Anular venta** — refactor de `AnnulTransactionModal` (bottom sheet) a `AnnulTransactionDialog` basado en `CustomFormDialog`, para alinearse con el estándar de diálogos de la app (`CustomerFormDialog`, `UserFormDialog`, `MenuFormDialog`). El widget anterior (`annul_transaction_modal.dart`) se eliminó por quedar como código muerto; el fix de overflow del bottom sheet (Flexible+SingleChildScrollView) queda obsoleto porque `CustomFormDialog` ya envuelve el `child` en `SingleChildScrollView`. `CashRegisterController.confirmAnnulTransaction` ahora usa `Get.dialog(AnnulTransactionDialog(...), barrierDismissible: false)`; `submitAnnulTransaction` cierra el diálogo (`Get.back()`) antes de invocar la API para que un motivo inválido mantenga el formulario abierto (mismo patrón que `UserFormDialog` con `autoClose: false`). | opencode |
| 2026-09-11 | **Reporte de Órdenes Anuladas + auditoría en cancelaciones pre-pago** — móvil+backend `[x]`, web `[ ]`. (a) **Backend (`restic-back`)**: nueva migración `V26_0__add_order_cancellation_audit.sql` (columnas `cancelled_by_id`, `cancelled_at`, `cancellation_reason` en `orders`); entidad `Order` + 3 campos nuevos; nuevo DTO `CancelOrderDTO` (motivo `@NotBlank` + `@Size(min=5, max=500)`); nuevo endpoint `PUT /api/orders/{id}/cancel` (roles SUPER/ADMIN/MESERO/COCINERO, body con `cancellationReason`); `OrderService.cancelOrder` con orquestación completa (status CANCELED, libera mesas, registra `cancelledBy`/`cancelledAt`/`cancellationReason`, log WARN, WebSocket); hardening de `updateStatus` (al transicionar a CANCELED estampa `cancelledBy`/`cancelledAt`, motivo null); Tests `OrderServiceImplTest` +3 casos. Nuevo módulo de reporte: 3 DTOs (`CancelledOrdersReportResponseDTO`, `CancelledOrderItemDTO`, `PaymentMethodInfoDTO`); 3 queries nuevas en repos (`TransactionRepository.findCancelledSalesWithOrderByBranchIdAndDateRange`, `OrderRepository.findCancelledByBranchIdAndDateRange`, `PaymentDetailRepository.findByTransactionIdIn`); `CancelledOrdersReportService` + Impl que une ambos datasets (PAID_SALE + PRE_PAID), agrupando pagos por transacción; nuevo endpoint `GET /api/reports/orders/annulled` (`@AdminAccess`, datetime range); `CancelledOrdersReportServiceImplTest` 8/8 OK; `TECHNICAL_DOCUMENTATION.md` actualizado (§7.12 + §7.18.7). (b) **Móvil (`restic-movil`)**: `UrlPaths.cancelOrder` + `getAnnulledOrdersReport`; `OrdersRepository.cancelOrder(orderId, {required reason})`; nuevo widget `CancelOrderDialog` (`CustomFormDialog` con `autoClose: false`, advertencia específica "no afecta caja ni inventario" + motivo obligatorio); `cash_register_controller.confirmCancelOrder`/`_cancelOrder` reemplazan el `ModalWarning` sí/no por el dialog con motivo, cierra con `Get.back()` antes del overlay; modelo `AnnulledOrdersReportResponse` + `AnnulledOrderSummary` + `PaymentMethodInfo`; `ReportsRepository.getAnnulledOrdersReport`; enum `ReportType.annulledOrders` + state `annulledOrdersData` + `fetchAnnulledOrdersReport`; `reports_view.dart` title `Reporte de Ventas`→`Reportes` + dropdown item + exact datetime selector; nuevo widget `AnnulledOrdersResultsView` (summary card + empty state + cards con tipo de cancelación, motivo, anulado por, fecha, mesero, cliente, factura, turno, cajero, propinas, chips de métodos de pago). `flutter analyze` 0 issues, tests reports+cash_register+model nuevo 4/4 OK. (c) **Manual usuario**: `docs/reportes.md` título → "Reportes" + nueva sección "Órdenes Anuladas" con admonitions; `mkdocs.yml` nav actualizado; `cobrar-pedido.md` y `gestionar-pedidos.md` actualizados (paso del motivo obligatorio + warning sobre anulación pre-pago). | opencode |
| 2026-09-15 | **Módulos Inventario y Reportes completos** (secciones 13 `[ ]` → `[x]`, 15 `[~]` → `[x]`) + corrección documental de la sección 14 Datos Fiscales + extra web de exportación PDF/Excel. Cambios web: (a) **Correcciones de infraestructura**: `sales-report.model.ts` y `reports.repository.ts` reescritos desde cero para alinearse con el backend (antes usaban campos inexistentes: `totalOrders`, `averageTicket`, `salesByCategory`, etc.; el path de turno enviaba `shiftId` como query param en lugar de path); `inventory.model.ts` reescrito (enums `MeasurementUnit` con 9 valores, `StockMovementType` con 7, `StockMovementModel` con `notes/manual/typeDescription/referenceOrder*`, + `AssociatedProductModel`); `inventory.repository.ts` extendido con CRUD items, `createManualMovement`, `getMovements` tipado con filtros, `getAssociatedProducts` con URL corregida (`inventory/items/{id}/products`), `exportMovements` con filtros; `UrlPaths` + `INVENTORY_ITEM_PRODUCTS` (base para path) y + `PRODUCT_SALES_REPORT`/`TOP_PRODUCTS_REPORT`/`ANNULED_ORDERS_REPORT`. (b) **`InventoryService`**: signals (items/alerts/movements/isLoading/isMutating/isExporting*), `canEdit` computed desde roles (SUPER/ADMINISTRADOR), filtros (insumo/tipo/rango fechas nativas), `loadAll()` paralelo + recarga tras cada mutación, export CSV con patrón `Blob` + `<a download>` (reemplazo de `share_plus`). (c) **Componente `inventory.component`**: 3 tabs (Insumos/Movimientos/Alertas); FAB contextual "Agregar" (oculto si `!canEdit`; tab Movimientos → movimiento manual, resto → insumo); cards coloreadas por `stockStatus` (OUT rojo/LOW naranja/OK verde) con acciones Ver Productos/Editar/Eliminar gateadas por `canEdit`; tab Movimientos con filtros (insumo select, tipo select 6+Todos, fechas nativas, limpiar) + Exportar CSV que respeta filtros; cards de movimiento con icono/flecha (rojo si `isOutput`); empty states contextuales (distinto si hay filtros activos). (d) **Diálogos**: `inventory-item-form-dialog` (name, unit 9 opciones, stock inicial solo al crear + caja informativa "Para modificar el stock usa Agregar Movimiento" en edición, minStock); `manual-movement-dialog` (insumo, tipo 5 manuales con +/−, cantidad > 0 con helper "El tipo decide si suma o resta", notas); `associated-products-dialog` (lista de productos vinculados con tipo/variante/cantidad consumida). (e) **`ReportsService`**: enum `ReportType` con 7 tipos + `REPORT_TYPE_OPTIONS`; repository con 7 métodos con params correctos (datetime en lugar de date, shift como path param, `productIds` como lista separada por comas); signals de datos por tipo; validaciones (≥1 producto, inicio ≤ fin, shiftId no vacío); checklist (categorías + toggleProduct/toggleSubcategory/clear/selectAll + contadores); formatos `yyyy-MM-dd` y `yyyy-MM-dd'T'HH:mm:00`. (f) **`ReportExportService`** (extra web, no en móvil): estructura genérica `ExportPayload { title, subtitle, summary[], sections[] }` + builders por tipo; PDF con `jspdf` + `jspdf-autotable` (encabezados azul primario, tema grid/striped); Excel con `xlsx` (`aoa_to_sheet`, `writeFile`, una hoja de resumen + una por sección). (g) **Componente `reports.component`**: selector de tipo (7 opciones con `mat-select`) + parámetros con **inputs nativos date/time**; auto-fetch al cambiar tipo (carga categorías para selección; top-products auto-consulta); resultados sales/shift (4 summary cards con colores por métrica + desglose por medios de pago + resumen por cajero + info turno); widgets `product-selection` (checklist árbol con checkbox tri-state), `product-sales-results`, `top-products-results` (ranking con top-3 oro/plata/bronce), `annulled-orders-results` (badges Venta pagada/Anulada pre-pago, filas de detalle, chips de pagos); botones "PDF"/"Excel" en cabecera deshabilitados sin datos. (h) **Dependencias nuevas**: `jspdf`, `jspdf-autotable`, `xlsx` — agregadas al `package.json` y solo cargadas en el chunk lazy de reportes. (i) **Sección 14 Datos Fiscales**: corrección documental (detalle + archivos web reales + endpoints); la implementación web ya estaba hecha desde 2026-08-28. (j) **Specs Vitest**: `inventory.service.spec.ts` (7 casos: canEdit, loadAll paralelo, POST create con currentStock, PUT update sin currentStock, POST manualMovement, loadMovements con HttpParams, isOutputMovement); `reports.service.spec.ts` (6 casos: params por tipo — dateRange/datetime/shiftById path/productIds joined, toggleProduct, toggleSubcategory). (k) **Verificación**: `npm run lint` limpio, `npm test` 22/22 OK (incluye specs previos de menú), `npm run build` OK. Tabla resumen actualizada (filas 13/14/15 todas `[x]`).

| 2026-09-15 | **Inventario — Export PDF/Excel en lugar de CSV (paridad con Reportes)**. Cambios web: (a) `ReportExportService.buildFromInventoryItems(items)` nuevo: payload con título "Inventario — Insumos", subtítulo `${n} insumos · generado {fecha}`, summary [Total insumos / Sin stock / Stock bajo / Stock OK] y tabla [Nombre, Unidad, Stock actual, Stock mínimo, Estado] con labels OUT→"Sin stock" / LOW→"Stock bajo" / else "OK"; reutiliza `exportPdf`/`exportExcel` del servicio (jspdf/autotable/xlsx ya instalados). (b) `inventory.component.ts`: inyecta `ReportExportService`; nuevos `exportPdf()`/`exportExcel()` (mismo patrón que reports.component: `buildFromInventoryItems(this.items())` + `exportPdf/exportExcel` con filename `insumos-{fecha}` + snackbar "Exportando PDF..."/"Exportando Excel..."); helper privado `exportFilename()`. (c) `inventory.component.html`: tab Insumos reemplaza el botón "Exportar CSV" por `.actions-row.export-buttons` con dos `mat-stroked-button color="primary"` (iconos `picture_as_pdf` PDF y `grid_on` Excel, deshabilitados cuando `items().length === 0`); tab Movimientos pierde el botón de exportación (ni CSV ni PDF/Excel). (d) Limpieza: `InventoryService` elimina `isExportingItems`/`isExportingMovements`, `exportItemsCsv()`/`exportMovementsCsv()` y los helpers privados `downloadBlob()`/`todayStr()`; `inventory.repository.ts` elimina `exportItems()`/`exportMovements()`; `UrlPaths` elimina `EXPORT_INVENTORY_ITEMS`/`EXPORT_INVENTORY_MOVEMENTS`. (e) Estilos: `inventory.component.scss` une `.actions-row` y `.export-buttons` (flex + gap 8px, alineado derecha); quita `.inline-spinner` y `.export-btn` obsoletos. (f) Spec nuevo `report-export.service.spec.ts` (servicio sin DI → instancia directa): 4 casos del builder (resumen correcto, mapeo de filas, labels de estado, lista vacía, campos faltantes). (g) Sin gate por `canEdit` en los botones PDF/Excel (paridad con reports — en la práctica da igual porque INVENTARIO solo lo tienen SUPER/ADMINISTRADOR en `ROLE_MODULES`). (h) **Verificación**: `npm run lint` limpio, `npm test` 32/32 OK, `npm run build` OK. | opencode |
| 2026-09-15 | **Módulo Perfil completo** (sección 16 `[ ]` → `[x]`) + **sección 2 Splash descartada** + correcciones de paridad detectadas. Cambios web: (a) **Correcciones de infraestructura** en `profile.repository.ts`: `changePassword` corregido de PUT → **PATCH** `users/me/change-password` (body `{currentPassword, newPassword}`); `updateWaiterFilter` corregido de `PUT branches/waiter-filter` (incorrecto, 404 silencioso) → **PATCH** `branches/{id}/waiter-filter` con body `{waiterViewOwnOrdersOnly}`; `updateProfile` (PUT `branches`, código especulativo muerto) eliminado. (b) `home.component.ts`: `toggleWaiterView` pasa ahora `storage.branchId()` al toggle → empieza a persistir de verdad en el backend (antes fallaba silencioso). (c) Nuevo `core/services/profile.service.ts`: `changePassword(current, new)` con `errorService.handleError` + `isSubmitting` signal. (d) Nuevo `features/profile/` (reemplaza stub): 3 cards — **Información del usuario** (avatar con iniciales + nombre + roles formateados como chips + sucursales disponibles con la activa resaltada en verde + módulos), **Cambiar Contraseña** (actual/nueva/confirmación con toggles de visibilidad por campo, validaciones requeridas + min 6 + max 100 + sin espacios + coincidencia, botón "Actualizar Contraseña" con loading → snackbar `Contraseña cambiada exitosamente` + reset del form), **Propina predeterminada** (input numérico + botones sugeridos 0/5/10/15 + guardar → `StorageService.saveDefaultTipPercentage` + snackbar). Template-driven con `ngModel`, signals locales para visibilidad/estado. (e) **Acceso a la pantalla**: header del sidenav (avatar + nombre + sucursal) convertido en enlace `routerLink="profile"` con `matTooltip="Mi Perfil"` + cursor pointer + hover sutil + chevron; ruta `/home/profile` ya existía pero no era accesible (era un hunk muerto). (f) Estilos: `profile.component.scss` con tarjetas, chips, inputs; `home.component.scss` añadido `.sidenav-header` hover/active/`.chevron`. (g) **Specs Vitest**: `profile.repository.spec.ts` (2 casos: PATCH changePassword con body correcto, PATCH updateWaiterFilter con branchId en path); `profile.component.spec.ts` (9 casos: render 3 cards, usuario + chip activo, roles + módulos, submit vacío deshabilitado, min 6 deshabilita, válido llama service + snackbar, sugerencia de propina actualiza modelo, guardar inválido no persiste, guardar válido persiste). (h) **Sección 2 (Splash + App Update)**: estado global `~~Descartado~~` (no aplica en web — bundle versionado por despliegue, SPA renderiza directo en `/login` o `/home`); tabla resumen y nota en la sección actualizadas; pendiente en `Pendiente crítico` de la fila 2 del resumen, limpiado. (i) **Verificación**: `npm run lint` limpio, `npm test` 43/43 OK (32 previos + 9 nuevos + 2 repository), `npm run build` OK. Tabla resumen actualizada (fila 16 `[x]` sin pendiente, fila 2 descartado).
---

# Notas operativas

- Al implementar una funcionalidad, **marca el ítem correspondiente con `[x]`** y agrega una entrada en el historial.
- Si una funcionalidad `[~]` se completa totalmente, cámbiala a `[x]`.
- Si durante la implementación se descubre un nuevo sub-caso pendiente, agregarlo como nuevo ítem dentro del módulo correspondiente.
- Mantener las **rutas de archivos** actualizadas si hay renombrados o reubicaciones en `restic-web`.
- El backend (`restic-back`) es la fuente única de verdad para endpoints; si la web consume uno distinto, debe corregirse.
