# Витрина для Power BI

Две таблицы выгружены из SQL-слоя (`sql/07_mart.sql`) скриптом `python scripts/export_mart.py`.

## Модель

```
dim_customers (1) ──< fact_orders (∗)      связь по customer_unique_id
```

**fact_orders** — один доставленный заказ: `order_id`, `customer_unique_id`, `purchase_date`, `state`,
`revenue` (товары + доставка, R$), `freight`, `items`, `delay_days` (факт − обещанная дата, дни),
`delivery_bucket`, `review_score` (1–5), `is_first_order`.

**dim_customers** — клиент: `cohort_month` (месяц первой покупки), `frequency`, `monetary`, `recency_days`,
RFM-баллы `r`, `f`, `m` и `segment`.

Добавить таблицу дат (`CALENDAR(MIN(fact_orders[purchase_date]), MAX(fact_orders[purchase_date]))`) и связать
с `purchase_date`.

## Меры DAX

```DAX
GMV = SUM ( fact_orders[revenue] )
Orders = COUNTROWS ( fact_orders )
Customers = DISTINCTCOUNT ( fact_orders[customer_unique_id] )
AOV = DIVIDE ( [GMV], [Orders] )
Repeat orders % = DIVIDE ( CALCULATE ( [Orders], fact_orders[is_first_order] = FALSE () ), [Orders] )
Late orders % = DIVIDE ( CALCULATE ( [Orders], fact_orders[delay_days] > 0 ), CALCULATE ( [Orders], NOT ISBLANK ( fact_orders[delay_days] ) ) )
Avg review = AVERAGE ( fact_orders[review_score] )
Negative reviews % = DIVIDE ( CALCULATE ( COUNTROWS ( fact_orders ), fact_orders[review_score] <= 2 ), CALCULATE ( COUNTROWS ( fact_orders ), NOT ISBLANK ( fact_orders[review_score] ) ) )
```

## Макет отчёта (3 страницы)

1. **Обзор:** карточки GMV, Orders, AOV, Repeat orders %; линия GMV по месяцам; карта или столбцы GMV по штатам.
2. **Клиенты:** матрица когорт (строки — `cohort_month`, столбцы — месяцы с первой покупки, значения — доля
   вернувшихся); RFM-сегменты: число клиентов и доля выручки.
3. **Доставка и отзывы:** столбцы Avg review и Negative reviews % по `delivery_bucket`; срез по штатам.

Значения должны совпасть со страницей проекта (GMV, число заказов, средний отзыв по корзинам доставки).
