CREATE TABLE "orders" (
  "order_id" varchar PRIMARY KEY,
  "customer_id" varchar,
  "order_status" varchar,
  "order_purchase_timestamp" timestamp,
  "order_approved_at" timestamp,
  "order_delivered_carrier_date" date,
  "order_delivered_customer_date" date,
  "order_estimated_delivery_date" date
);

CREATE TABLE "order_reviews" (
  "review_id" varchar PRIMARY KEY,
  "order_id" varchar,
  "review_score" int,
  "review_comment_title" varchar,
  "review_comment_message" varchar,
  "review_creation_date" date,
  "review_answer_timestamp" timestamp
);

CREATE TABLE "order_payments" (
  "order_id" varchar,
  "payment_sequential" int,
  "payment_type" varchar,
  "payment_installments" int,
  "payment_value" float,
  PRIMARY KEY ("order_id", "payment_sequential")
);

CREATE TABLE "geolocation" (
  "geolocation_zip_code_prefix" int PRIMARY KEY,
  "geolocation_lng" float,
  "geolocation_lat" float,
  "geolocation_city" varchar,
  "geolocation_state" varchar
);

CREATE TABLE "category_name_translation" (
  "product_category_name" varchar PRIMARY KEY,
  "product_category_name_english" varchar
);

CREATE TABLE "order_items" (
  "order_id" varchar,
  "order_item_id" int,
  "product_id" varchar,
  "seller_id" varchar,
  "shipping_limit_date" timestamp,
  "price" float,
  "freight_value" float,
  PRIMARY KEY ("order_id", "order_item_id")
);

CREATE TABLE "sellers" (
  "seller_id" varchar PRIMARY KEY,
  "seller_zip_code_prefix" int,
  "seller_city" varchar,
  "seller_state" varchar
);

CREATE TABLE "customers" (
  "customer_id" varchar PRIMARY KEY,
  "customer_unique_id" varchar UNIQUE,
  "customer_zip_code_prefix" int,
  "customer_city" varchar,
  "customer_state" varchar
);

CREATE TABLE "products" (
  "product_id" varchar PRIMARY KEY,
  "product_category_name" varchar,
  "product_name_lenght" float,
  "product_description_lenght" float,
  "product_photos_qty" float,
  "product_weight_g" float,
  "product_length_cm" float,
  "product_width_cm" float
);

ALTER TABLE "orders" ADD FOREIGN KEY ("customer_id") REFERENCES "customers" ("customer_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "products" ADD FOREIGN KEY ("product_category_name") REFERENCES "category_name_translation" ("product_category_name") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "order_items" ADD FOREIGN KEY ("product_id") REFERENCES "products" ("product_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "order_items" ADD FOREIGN KEY ("seller_id") REFERENCES "sellers" ("seller_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "customers" ADD FOREIGN KEY ("customer_zip_code_prefix") REFERENCES "geolocation" ("geolocation_zip_code_prefix") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "sellers" ADD FOREIGN KEY ("seller_zip_code_prefix") REFERENCES "geolocation" ("geolocation_zip_code_prefix") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "order_items" ADD FOREIGN KEY ("order_id") REFERENCES "orders" ("order_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "order_payments" ADD FOREIGN KEY ("order_id") REFERENCES "orders" ("order_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "order_reviews" ADD FOREIGN KEY ("order_id") REFERENCES "orders" ("order_id") DEFERRABLE INITIALLY IMMEDIATE;
