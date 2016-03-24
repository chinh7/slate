---
title: Quoine Exchange API Reference

language_tabs:
  - ruby

toc_footers:
  - <a href='/'>Quoine API</a>

includes:
  - errors

search: true
---

# Introduction

> The base URL for production is `https://api.quoine.com`. All responses are in JSON format with the following status codes:

```
HTTP 200: OK
  Response is correct. The body of the response will
  include the data requested.

HTTP 400: Bad Request
  There was an error with the request. The body of the response will have more info

HTTP 401: Unauthorized
  Token is invalid. If your API key is wrong a 401 will also be served,
  so check the response body, it might be that the API_KEY is invalid.

HTTP 422: Unprocessable Entity
  There was an error with the request. The body of the response will have more info. Some possible reasons:
  - Missing params
  - The format of data is wrong

HTTP 429: Too Many Requests
  This status indicates that the user has sent too many requests in a given amount of time  

HTTP 503: Service Unavailable
  Many reasons, body will include details
  - An internal error on Authy.
  - Your application is accessing an API call you don't have access too.
  - API usage limit. If you reach API usage limits a 503 will be returned,
  please wait until you can do the call again.
```

# I. REST API

# Transactions
## Get Transactions

> GET /transactions?currency&transaction_type&page

```
Success Response:
```

```json
{
  "models": [
    {
      "id": 1521313,
      "created_at": 1457102440,
      "transaction_type": "interest_transfer",
      "gross_amount": 0.00042,
      "net_amount": 0.00042,
      "fee": 0.0,
      "from_fiat_account_id": 4695,
      "to_fiat_account_id": 10884,
      "execution": null,
      "loan": {
        "quantity": "4.2042",
        "rate": "0.0001",
        "currency": "USD"
      }
    }
  ],
  "current_page": 1,
  "total_pages": 23
}
```

#### Parameters:

Parameters   | Optional? | Description
---------|-----------|------------
currency || funding currency
transaction_type |yes| `loan`, `trade`, `fund`

# II. Notifications

# Websocket

Quoine uses Pusher for real time data streaming. Please check <a href='https://pusher.com/docs/'>Pusher</a> documentation and libraries on how to connect to our stream. You can also find an example for each stream below.

Please contact us for pusher key

### All Products
- CHANNEL: `products`
- EVENT: `updated`

### One Product
- CHANNEL: `product_cash_[currency pair code]_[product id]` (e.g. `product_cash_btcusd_1`)
- EVENT: `updated`

### Order book:
- CHANNEL: `price_ladders_cash_[currency pair code]_[side]` (e.g. `price_ladders_cash_btcjpy_sell`)
- EVENT: `updated`

### Executions:
- CHANNEL: `executions_cash_[currency pair code]` (e.g. `executions_cash_btcjpy`)
- EVENT: `created`
