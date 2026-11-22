# Данные

Brazilian E-Commerce Public Dataset by Olist — реальные обезличенные заказы бразильского маркетплейса Olist,
2016–2018: ~100 тыс. заказов, 8 связанных таблиц.

- Источник: https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce
- Лицензия: [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/) — Olist.
- Здесь таблицы переведены из CSV в parquet без изменений (число строк совпадает с оригиналом,
  это проверяет `tests/test_base.py`). Таблица геолокации не используется и не включена.

| Файл | Строк | Что внутри |
|---|---:|---|
| orders | 99 441 | заказ: статус, даты покупки, доставки, обещанной доставки |
| order_items | 112 650 | позиции заказа: товар, продавец, цена, доставка |
| customers | 99 441 | `customer_id` (новый на каждый заказ) → `customer_unique_id` (человек), штат |
| order_payments | 103 886 | способ оплаты, рассрочка |
| order_reviews | 99 224 | оценка 1–5 и текст отзыва |
| products | 32 951 | категория, размеры товара |
| sellers | 3 095 | продавцы |
| product_category_name_translation | 71 | перевод категорий на английский |
