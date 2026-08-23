# Control de Implementación de Funcionalidades — Web vs Móvil

> Archivo de seguimiento continuo. Comparación de funcionalidades entre:
> - **Móvil**: `D:\Flutter\restic-movil` (Flutter + GetX, v2.0.7+19)
> - **Web**: `D:\Angular\restic-web` (Angular 20 + Signals + Angular Material 20)
> - **Backend**: `D:\Spring\restic-back` (Spring Boot, base única para ambos)
>
> **Fecha del último análisis:** 2026-08-19

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
| 2 | Splash + App Update | `[~]` | Verificación de versión forzada en web |
| 3 | Tomar Pedido | `[x]` | — |
| 4 | Pedidos (lista/gestión) | `[x]` | — |
| 5 | Comandas (cocina) | `[x]` | — |
| 6 | Pagos / Caja (registrar pago) | `[~]` | Reembolso/anulación transacción, cambio método post-factura, precuenta, propina guardable |
| 7 | Opciones de Caja (apertura/cierre/egresos) | `[x]` | Cierres pendientes: sin acción de aprobar |
| 8 | Clientes (CRUD) | `[ ]` | Stub vacío |
| 9 | Mesas (CRUD) | `[ ]` | Stub vacío |
| 10 | Menú (categorías + productos + recetas) | `[ ]` | Stub vacío |
| 11 | Usuarios (CRUD) | `[ ]` | Stub vacío |
| 12 | Métodos de Pago (configuración) | `[ ]` | Stub vacío |
| 13 | Inventario | `[ ]` | Stub vacío |
| 14 | Datos Fiscales | `[ ]` | Stub vacío |
| 15 | Reportes | `[ ]` | Stub vacío |
| 16 | Perfil (cambio contraseña + config) | `[ ]` | Stub vacío |
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

### Estado global: `[~]` Parcial

| Funcionalidad | Estado | Notas |
|---|---|---|
| Splash inicial mientras se valida sesión | `[ ]` | No hay splash component dedicado en web. La app inicia directo en `/login` o `/home` |
| Verificación de versión mínima contra endpoint remoto | `[ ]` | No implementado. No existe `app-update` component ni `AppVersionRepository` |

**Por hacer:**
- Crear un componente `SplashComponent` que muestre un loader mientras se valida token + branchId
- Implementar `AppVersionService` + `AppVersionRepository` que consulte versión mínima
- Crear vista de "Actualización obligatoria" cuando la versión de la app sea menor a la mínima requerida
- Definir endpoint backend o CDN para servir `AppVersionInfo` (`{ latestVersion, minRequiredVersion, updateUrl }`)

**Archivos clave (móvil — referencia):**
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
| Total computado en tiempo real (items + recargos) | `[x]` | Signal computed `cartTotal` |
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
| WebSocket en tiempo real (recarga automática) | `[x]` | `websocket.service.ts` → signals |
| Card de pedido (`GlobalOrderCard`-equivalente en línea) | `[x]` | ListView en `orders.component.html` |
| Detalle de pedido (modal) | `[x]` | `OrderDetailDialogComponent` (inline en `orders.component.ts`) |
| Actualización de estado de detalle (SERVED / CANCELED) | `[x]` | Checkbox multi-selección en diálogo |
| Anular pedido (`PUT orders/update-status/{id}?status=CANCELED`) | `[x]` | Confirmación inline |
| **Agregar productos a pedido existente** | `[x]` | `AddProductsDialogComponent` con catálogo, carrito temporal y `PUT orders/{orderId}/add-products` |
| **Filtro mesero "solo mis pedidos"** | `[x]` | `StorageService.getWaiterViewOwnOrdersOnly`/`saveWaiterViewOwnOrdersOnly`; toggle en drawer del home (visible solo si rol MESERO); filtrado cliente por `createdBy.id === user.id` en `OrdersService` y `CashRegisterService` |
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

### Estado global: `[~]` Parcial

| Funcionalidad | Estado | Notas |
|---|---|---|
| Lista de pedidos pendientes (OPEN + FINALIZED) por fecha | `[x]` | `pending-orders.component.ts` |
| Lista de historial (PAID + CANCELED) por fecha | `[x]` | Tab "Historial" |
| Modal Registrar Pago (`TransactionModalComponent`) | `[x]` | 621 líneas equivalentes en web |
| Resumen del pedido en el modal | `[x]` | Número, total, mesa, cliente |
| Propina (botones 0/5/10/15% + input manual) | `[x]` | `tipPercent` signal, opciones hardcodeadas |
| Cálculo bidireccional propina (% ↔ monto ↔ total) | `[~]` | Verificar; móvil tiene sync bidireccional completo |
| Múltiples pagos (split payment) | `[x]` | FormArray de pagos |
| Campos condicionales para tarjeta (últimos 4, marca) | `[x]` | Si method es CREDIT/DEBIT_CARD |
| Validación de cobertura (totalPaid ≥ totalToPay) | `[x]` | |
| Cálculo de cambio (change) | `[x]` | |
| `POST transactions/create` | `[x]` | `transactions.repository.ts` create |
| Feedback de éxito con monto de cambio | `[x]` | |
| Re-ver factura (`InvoiceDetailsDialogComponent`) | `[x]` | `GET transactions/{id}/invoice` |
| Anular pedido desde caja (cancelar antes de pagar) | `[x]` | `PUT orders/update-status CANCELED` |
| WebSocket en tiempo real (refresh al recibir evento) | `[x]` | |
| Cargar métodos de pago activos | `[x]` | `payment-methods.repository.ts` getActive |
| **Reembolso de transacción (REFUND)** | `[ ]` | Endpoint `transactions/refund` definido en `url-paths.ts` pero no implementado |
| **Anulación de transacción (CANCEL)** | `[ ]` | Endpoint `transactions/cancel` definido pero no implementado |
| **Cambio de método de pago post-factura** | `[ ]` | Falta `ChangePaymentMethodModalComponent` y uso de `transactions/{id}/payment-details` |
| **Precuenta** (visualizador modal con total estimado + prop. opcional) | `[ ]` | No existe. OrderDetailsDialog muestra pedido, pero no es precuenta |
| **Propina predeterminada guardable** (default % persistente) | `[ ]` | Constantes en `app.constants.ts` listas; sin uso en `TransactionModalComponent` |
| Editar cargos (surcharges) del pedido antes de pagar | `[~]` | Existe `surcharges-dialog.component.ts`, verificar flujo completo |
| Selección de terminal en transacciones | `[ ]` | `terminals/all` se carga pero no se asigna al cashier shift en web |
| Verificar que solo SUPER/ADMIN pueden cambiar método post-factura | `[ ]` | Pendiente de regla de negocio |

**Archivos clave (web):**
- `src/app/features/payments/payments.component.ts`
- `src/app/features/payments/pending-orders/pending-orders.component.ts` (523 líneas, incluye `TransactionModalComponent`)
- `src/app/features/payments/order-details-dialog/order-details-dialog.component.ts`
- `src/app/features/payments/invoice-details-dialog/invoice-details-dialog.component.ts`
- `src/app/features/payments/surcharges-dialog/surcharges-dialog.component.ts`
- `src/app/core/services/cash-register.service.ts` (318 líneas)
- `src/app/data/repositories/transactions.repository.ts`
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
- `POST transactions/create`
- `GET transactions/{id}/invoice`
- `GET transactions/{id}`
- `PUT transactions/{id}/payment-details` (cambio de método, **no usado en web**)
- `POST transactions/refund` (**no usado en web**)
- `POST transactions/cancel` (**no usado en web**)

**Detalle de tareas pendientes (Pagos):**
1. **Reembolso (REFUND)**
   - Método `refund(transactionId, reason)` en `TransactionsRepository` → `POST transactions/refund`
   - UI: en `InvoiceDetailsDialogComponent`, agregar botón "Reembolsar" si rol es admin/super
   - Modal de confirmación con campo "motivo"
2. **Anulación de transacción (CANCEL)**
   - Método `cancel(transactionId, reason)` en `TransactionsRepository` → `POST transactions/cancel`
   - UI: en historial, botón "Anular transacción" (solo si `order.status === PAID` y rol admin/super)
3. **Cambio de método de pago post-factura**
   - `ChangePaymentMethodModalComponent` con selector de método + campos tarjeta condicionales
   - Endpoint: `PUT transactions/{id}/payment-details` con `{ paymentDetails, reason }`
   - UI: botón "Cambiar método de pago" en `InvoiceDetailsDialogComponent` (solo admin/super)
4. **Precuenta**
   - `PrecountDialogComponent`: muestra resumen del pedido + items + total + campo "propina sugerida"
   - Acción: "Ir a cobrar" → abre el `TransactionModalComponent` pre-llenado con la propina
5. **Propina predeterminada guardable**
   - `StorageService`: agregar `saveDefaultTipPercentage()`, `getDefaultTipPercentage()`
   - UI: en módulo Perfil (o en el propio modal de transacción con checkbox "Guardar como predeterminado")
   - `TransactionModalComponent`: al abrir, leer `defaultTipPercentage` del storage; al cerrar con éxito, si checkbox activo, persistir
6. **Selección de terminal**
   - En `TransactionModalComponent`: si el usuario es cajero y tiene turno activo, auto-asignar `terminalId` desde `cashierRepo.getActiveShiftByTerminal()`
7. **Sync bidireccional de propina (% ↔ monto ↔ total)**
   - Verificar que al cambiar `%`, el monto se actualice; al cambiar el monto, el `%` se recalcula; al cambiar el total, la propina se mantenga consistente

---

## 7. Opciones de Caja (sub-features)

### Estado global: `[x]` Completado (con un pendiente menor)

| Funcionalidad | Estado | Notas |
|---|---|---|
| **Apertura de caja** (`open-shift`) | `[x]` | Selección de terminal, monto inicial, observaciones → `POST cashier-shifts/open` |
| **Cierre de caja** (`close-shift`) | `[x]` | Monto declarado, observaciones, cálculo sobrante/faltante → `PUT cashier-shifts/close/cashier/{cashierId}` |
| **Registrar egreso** (`expenses`) | `[x]` | Monto, concepto, motivo, fuente de pago (con campos bancarios), voucher → `POST cash-withdrawals/register` |
| **Cierres pendientes** (`pending-closes`) | `[~]` | Vista de tabla OK; **falta acción de aprobar/reconciliar un cierre pendiente** |
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
1. **Aprobar/Reconciliar cierre pendiente**
   - Acción "Reconciliar" en `pending-closes.component.ts` (solo admin/super)
   - Modal con resumen del turno + campo "observaciones del supervisor"
   - Endpoint: `POST cashier-shifts/{id}/reconcile`

---

## 8. Clientes (CRUD)

### Estado global: `[ ]` Falta (stub vacío)

| Funcionalidad | Estado | Notas |
|---|---|---|
| Listar todos los clientes | `[ ]` | Stub — `customers.component.ts` solo importa `CommonModule` |
| Crear cliente | `[ ]` | |
| Editar cliente | `[ ]` | |
| Eliminar cliente | `[ ]` | |
| Buscar cliente por nombre/apellido/teléfono | `[ ]` | |
| Marcar cliente como predeterminado para pedidos | `[ ]` | |
| Ver historial de pedidos por cliente (opcional) | `[ ]` | |

**Archivos clave (móvil — referencia):**
- `lib/app/modules/customers/controllers/customers_controller.dart`
- `lib/app/modules/customers/views/customers_view.dart`
- `lib/app/modules/customers/bindings/customers_binding.dart`
- `lib/app/data/repositories/customer_repository.dart`
- `lib/app/data/models/customer_model.dart`

**Endpoints backend disponibles:**
- `GET customers/all`
- `POST customers/create`
- `PUT customers/update/{id}`
- `DELETE customers/delete/{id}`

**Por hacer en web:**
1. Implementar `customers.component.ts` con tabla + filtros + paginación
2. Form reactivo para crear/editar (campos: name, lastName, document, phone, email, address, notes)
3. Toggle "cliente predeterminado" (POST/PATCH backend si lo soporta, o persistir en localStorage)
4. Repositorio y modelo **ya existen** en `customer.repository.ts` y `customer.model.ts`

---

## 9. Mesas (CRUD)

### Estado global: `[ ]` Falta (stub vacío)

| Funcionalidad | Estado | Notas |
|---|---|---|
| Listar mesas con filtro por estado/ubicación | `[ ]` | Stub |
| Crear mesa | `[ ]` | |
| Editar mesa | `[ ]` | |
| Eliminar mesa | `[ ]` | |
| Reservar mesas (`reserveTables`) | `[ ]` | |
| Liberar mesas (`releaseTables`) | `[ ]` | |
| Visualización de estados (AVAILABLE/OCCUPIED/RESERVED) | `[ ]` | |

**Archivos clave (móvil — referencia):**
- `lib/app/modules/tables/controllers/tables_controller.dart`
- `lib/app/modules/tables/views/tables_view.dart`
- `lib/app/data/repositories/tables_repository.dart`
- `lib/app/data/models/table_model.dart` + `table_status_model.dart`

**Endpoints backend disponibles:**
- `GET tables/all`, `GET tables/by-status/AVAILABLE`
- `POST tables/create`, `PUT tables/update/{id}`, `DELETE tables/delete/{id}`
- `POST tables/reserve`, `POST tables/release`
- `GET tables/statuses`

**Por hacer en web:**
1. Implementar `tables.component.ts` con grid visual de mesas por ubicación
2. Colorear según estado (verde/naranja/azul)
3. Acciones contextuales (reservar/liberar/editar)

---

## 10. Menú (Categorías, Subcategorías, Productos, Recetas)

### Estado global: `[ ]` Falta (stub vacío)

| Funcionalidad | Estado | Notas |
|---|---|---|
| Listar categorías (con subcategorías y productos anidados) | `[ ]` | |
| Crear/editar/eliminar categoría | `[ ]` | |
| Crear/editar/eliminar subcategoría | `[ ]` | |
| Crear/editar/eliminar producto | `[ ]` | |
| Productos con múltiples precios (VARIABLE + `sizeLabel`) | `[ ]` | |
| Productos tipo COMBO con grupos y opciones | `[ ]` | |
| Productos tipo COMBINADO (2x1) | `[ ]` | |
| Recetas de producto (asociación con insumos) | `[ ]` | `product-recipe` |
| Guardar receta completa por variante de precio | `[ ]` | |
| Asignar impresora/zona a categoría | `~~Descartado~~` | No aplica en web |

**Archivos clave (móvil — referencia):**
- `lib/app/modules/menu/controllers/menu_controller.dart`
- `lib/app/modules/menu/views/menu_view.dart`
- `lib/app/modules/menu/views/widgets/combo_editor_dialog.dart`
- `lib/app/modules/menu/views/widgets/recipe_form_dialog.dart`
- `lib/app/data/repositories/categories_repository.dart`
- `lib/app/data/repositories/combos_repository.dart`
- `lib/app/data/models/category_model.dart` (re-exporta subcategory, product, combo)

**Endpoints backend disponibles:**
- `GET categories/all`
- `POST categories/create`, `PUT categories/update/{id}`, `DELETE categories/delete/{id}`
- `POST subcategories/create`, `PUT subcategories/update/{id}`
- `POST products/create`, `PUT products/update/{id}`
- `GET combos/by-product/{id}/options`, etc.
- `POST products/{id}/recipe`, `DELETE products/{id}/recipe/{priceVariantId}`

**Por hacer en web:**
1. Vista en árbol: Categoría → Subcategoría → Productos
2. CRUD completo con formularios reactivos
3. Editor visual de combos (grupos + opciones)
4. Editor de recetas (selector de insumos + cantidades)

---

## 11. Usuarios (CRUD)

### Estado global: `[ ]` Falta (stub vacío)

| Funcionalidad | Estado | Notas |
|---|---|---|
| Listar usuarios | `[ ]` | |
| Crear usuario (asignar roles + sucursales) | `[ ]` | |
| Editar usuario | `[ ]` | |
| Eliminar usuario | `[ ]` | |
| Resetear contraseña (genera temporal) | `[ ]` | |
| Activar/desactivar usuario (`toggle-status`) | `[ ]` | |
| Asignar módulos al usuario | `[ ]` | |

**Archivos clave (móvil — referencia):**
- `lib/app/modules/users/controllers/users_controller.dart`
- `lib/app/modules/users/views/users_view.dart`
- `lib/app/data/repositories/users_repository.dart`
- `lib/app/data/models/user_model.dart` + `user_role.dart`

**Endpoints backend disponibles:**
- `GET users/all`, `GET users/{id}`
- `POST users/create`, `PUT users/update/{id}`, `DELETE users/delete/{id}`
- `PATCH users/{id}/reset-password`
- `PATCH users/{id}/toggle-status`

**Por hacer en web:**
1. Tabla de usuarios con paginación y búsqueda
2. Form de creación/edición con selectores múltiples (roles, sucursales, módulos)
3. Acciones: editar, reset pass, toggle estado

---

## 12. Métodos de Pago (configuración)

### Estado global: `[ ]` Falta (stub vacío)

| Funcionalidad | Estado | Notas |
|---|---|---|
| Listar métodos de pago (activos e inactivos) | `[ ]` | |
| Editar método (displayName, active, displayOrder) | `[ ]` | |
| Activar/desactivar método | `[ ]` | |

**Archivos clave (móvil — referencia):**
- `lib/app/modules/payment_methods/controllers/payment_methods_controller.dart` (120 líneas)
- `lib/app/modules/payment_methods/views/payment_methods_view.dart`
- `lib/app/modules/payment_methods/views/widgets/payment_method_form_modal.dart`
- `lib/app/data/repositories/payment_methods_repository.dart`
- `lib/app/data/models/payment_method_model.dart`

**Endpoints backend disponibles:**
- `GET payment-methods/config` (todos)
- `GET payment-methods/config/active` (solo activos)
- `PUT payment-methods/config/{method}`

**Por hacer en web:**
1. Lista de métodos con switch on/off
2. Modal de edición (displayName, displayOrder)
3. Repositorio y modelo ya existen

---

## 13. Inventario

### Estado global: `[ ]` Falta (stub vacío)

| Funcionalidad | Estado | Notas |
|---|---|---|
| **Items / Insumos**: listar, crear, editar, eliminar | `[ ]` | name, unit, currentStock, minStock |
| **Alertas** de stock mínimo | `[ ]` | |
| **Movimientos** manuales (PURCHASE, ADJUSTMENT, etc.) | `[ ]` | |
| Productos asociados a un insumo | `[ ]` | |
| **Recetas**: vincular insumos a productos | `[ ]` | consumido al vender |
| Export CSV de items / movimientos | `[~]` | Descarga nativa navegador (en lugar de share_plus) |

**Archivos clave (móvil — referencia):**
- `lib/app/modules/inventory/controllers/inventory_controller.dart`
- `lib/app/modules/inventory/views/inventory_view.dart`
- `lib/app/data/repositories/inventory_repository.dart`
- `lib/app/data/repositories/recipes_repository.dart`
- `lib/app/data/models/inventory_item_model.dart`
- `lib/app/data/models/stock_movement_model.dart`
- `lib/app/data/models/product_recipe_model.dart`

**Endpoints backend disponibles:**
- `GET inventory-items/all`, `/low-stock`, etc.
- `POST inventory-items/create`, `PUT update`, `DELETE`
- `GET stock-movements/all`
- `POST stock-movements/create`
- `GET product-recipes/{productId}`
- `POST product-recipes/{productId}`, `PUT`, `DELETE`

**Por hacer en web:**
1. Tres pestañas: Items / Alertas / Movimientos
2. CRUD de insumos con validaciones (currentStock ≥ 0, minStock ≥ 0)
3. Editor de recetas: seleccionar producto, agregar líneas de insumo con cantidad
4. Descarga CSV (en web: generar Blob + `<a download>`)

---

## 14. Datos Fiscales

### Estado global: `[ ]` Falta (stub vacío)

| Funcionalidad | Estado | Notas |
|---|---|---|
| Listar datos fiscales por sucursal | `[ ]` | |
| Crear/editar datos fiscales (DIAN) | `[ ]` | |
| Solo un fiscal data activo por sucursal | `[ ]` | |
| Marcar un fiscal data como activo | `[ ]` | |

**Campos del formulario (referencia móvil):**
- businessName, taxId, taxIdDigit
- address, city, department
- dianResolution, resolutionStartDate, resolutionEndDate
- invoicePrefix, resolutionNumberFrom, resolutionNumberTo
- taxRegime (SIMPLE / ORDINARIO / NO_RESPONSABLE_IVA)
- email, phone, website

**Archivos clave (móvil — referencia):**
- `lib/app/modules/fiscal_data/controllers/fiscal_data_controller.dart`
- `lib/app/modules/fiscal_data/views/fiscal_data_view.dart`
- `lib/app/data/repositories/fiscal_data_repository.dart`
- `lib/app/data/models/fiscal_data_model.dart`

**Endpoints backend disponibles:**
- `GET fiscal-data/all`, `/active`, `/{id}`
- `POST fiscal-data/create`, `PUT fiscal-data/update/{id}`
- `PATCH fiscal-data/{id}/activate`

**Por hacer en web:**
1. Form extenso con todos los campos DIAN
2. Selector de sucursal
3. Validaciones: rangos de numeración coherentes, fechas válidas
4. Vista de "datos fiscales activos"

---

## 15. Reportes

### Estado global: `[ ]` Falta (stub vacío)

| Funcionalidad | Estado | Notas |
|---|---|---|
| Reporte por rango de fechas (dateRange) | `[ ]` | |
| Reporte por rango exacto de fecha-hora | `[ ]` | |
| Reporte por ID de turno (shift) | `[ ]` | |
| Reporte por fecha de apertura de turno | `[ ]` | |
| Exportación a PDF/Excel (alternativa web) | `[ ]` | |

**Archivos clave (móvil — referencia):**
- `lib/app/modules/reports/controllers/reports_controller.dart`
- `lib/app/modules/reports/views/reports_view.dart`
- `lib/app/data/repositories/reports_repository.dart`
- `lib/app/data/models/sales_report_response.dart`
- `lib/app/data/models/shift_sales_report_response.dart`

**Endpoints backend disponibles:**
- `GET reports/sales?startDate=...&endDate=...`
- `GET reports/sales/exact?startDateTime=...&endDateTime=...`
- `GET reports/shift/{shiftId}`
- `GET reports/shift-by-date?date=...`

**Por hacer en web:**
1. Selector de tipo de reporte + filtros
2. Tabla con métricas (subtotal, descuentos, propinas, totales)
3. Gráficos opcionales
4. Descarga PDF/Excel vía librería cliente (ej. `jspdf`, `xlsx`)

---

## 16. Perfil

### Estado global: `[ ]` Falta (stub placeholder "en desarrollo")

| Funcionalidad | Estado | Notas |
|---|---|---|
| Cambio de contraseña autenticado (currentPassword + newPassword) | `[ ]` | Endpoint `PATCH users/me/change-password` |
| Persistir y leer `defaultTipPercentage` | `[ ]` | Storage key ya definida: `restic_default_tip_percentage` |
| Toggle "Solo ver mis pedidos" (mesero) | `[ ]` | Mover de aquí cuando se implemente en Pedidos |
| Información del usuario actual | `[ ]` | |

**Archivos clave (móvil — referencia):**
- `lib/app/modules/profile/controllers/profile_controller.dart`
- `lib/app/modules/profile/views/profile_view.dart`
- `lib/app/modules/profile/repositories/profile_repository.dart`
- `lib/app/modules/change_password/controllers/change_password_controller.dart`

**Endpoints backend disponibles:**
- `PATCH users/me/change-password`
- `PATCH branches/{branchId}/waiter-filter`

**Por hacer en web:**
1. Form de cambio de contraseña con validaciones (min 6, max 100, confirmación)
2. Input numérico para `defaultTipPercentage` con botones de sugeridos (0/5/10/15)
3. Toggle para `waiterViewOwnOrdersOnly` (solo MESERO)
4. Mostrar datos del usuario (nombre, sucursales, roles, módulos)

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
2. **Anulación de transacción (CANCEL)**
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
| _Pendiente_ | _Actualizar al implementar cada funcionalidad_ | _—_ |

---

# Notas operativas

- Al implementar una funcionalidad, **marca el ítem correspondiente con `[x]`** y agrega una entrada en el historial.
- Si una funcionalidad `[~]` se completa totalmente, cámbiala a `[x]`.
- Si durante la implementación se descubre un nuevo sub-caso pendiente, agregarlo como nuevo ítem dentro del módulo correspondiente.
- Mantener las **rutas de archivos** actualizadas si hay renombrados o reubicaciones en `restic-web`.
- El backend (`restic-back`) es la fuente única de verdad para endpoints; si la web consume uno distinto, debe corregirse.
