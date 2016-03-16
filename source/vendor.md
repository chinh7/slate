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

> The base URL for production is `https://api.quoine.com/vendor`. All responses are in JSON format with the following status codes:

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

This document introduces a set of API endpoints to facilitate communications between vendor servers and Quoine (Back office)
<aside class="notice">
  All endpoints listed require authentication (signed by Vendor ID/Secret)
</aside>

# I. REST API

# Users
## Create a User

> POST /users/

```json
{
  "ext_id": "vendor-user-id"
}
```

```
Success Response:
```

```json
{
  "id": 1200,
  "secret": "myUserSecret",
  "ext_id": "vendor-user-id"
}
```
User created will be immediately confirmed and approved
#### Parameters:

Parameters   | Optional? | Description
---------|-----------|------------
ext_id || Vendor user ID

# Fiat Funding
> PUT /accounts/:id/fund

```json
{
  "amount": "100000"
}
```

Parameters   | Optional? | Description
---------|-----------|------------
id || account id
amount || fund amount

# Fiat Withdrawal
> PUT /accounts/:id/withdraw

```json
{
  "amount": "100000"
}
```
Request fiat withdrawal. Account balance will be deducted immediately

Parameters   | Optional? | Description
---------|-----------|------------
id || account id
amount || withdrawal amount

# Crypto Funding
Handled automatically on Quoine's side

# Crypto Withdrawal
> PUT /accounts/:id/withdraw

```json
{
  "amount": "1",
  "address": "1ACiWrMafn3YLRw5DCf9CqGAHcg1oK9tUj"
}
```
Request crypto withdrawal. Account balance will be deducted once the withdrawal is approved

Parameters   | Optional? | Description
---------|-----------|------------
amount || amount to withdraw
currency || currency
address || bitcoin address


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

# Webhook
Quoine will notify vendor server all user events via the registered Webhook (POST'ed). The events are listed below
> POST /hooks

```json
{
  "url": "https://vendor-server.com/notifications"
}
```

```
Success Response:
```

```json
{
  "id": 25,
  "url": "https://vendor-server.com/notifications",
  "callback_errors": 0
}
```
## Fund Received

```json
{
  "ext_id": "vendor-user-id",
  "event": "fund-received",
  "currency": "BTC",
  "amount": "1.25"
}
```

## Margin call
```json
{
  "ext_id": "vendor-user-id",
  "event": "margin-call",
  "free_margin": "0.05"
}
```
