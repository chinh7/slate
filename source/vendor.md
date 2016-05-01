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

This document introduces a set of API endpoints to facilitate communications between app vendor and Quoine

# I. REST API (Back office)

<aside class="notice">
  All endpoints listed in this section require authentication (signed by Vendor ID/Secret)
</aside>

# Users
## Create a User

> POST /users/

```json
{
  "ext_id": "vendor-user-id",
  "email": "vendor-user-email",
  "auth_code": "pin-code"
}
```

```
Success Response:
```

```json
{
  "id": 1200,
  "secret": "myUserSecret",
  "ext_id": "vendor-user-id",
  "email": "vendor-user-email",
  "auth_code": "pin-code"
}
```
User created will be immediately confirmed and approved
#### Parameters:

Parameters   | Optional? | Description
---------|-----------|------------
ext_id || Vendor user ID

## Update a User

> PUT /users/:id

```json
{
  "email": "vendor-user-email",
  "auth_code": "pin-code"
}
```

```
Success Response:
```

```json
{
  "id": 1200,
  "secret": "myUserSecret",
  "ext_id": "vendor-user-id",
  "email": "vendor-user-email",
  "auth_code": "pin-code"
}
```
User created will be immediately confirmed and approved
#### Parameters:

Parameters   | Optional? | Description
---------|-----------|------------
id || Quoine user ID


## Get a user's Fiat Accounts

> GET /users/:id/accounts

```
Success Response:
```

```json
[
  {
    "id": 2300,
    "currency": "USD",
    "balance": "200"
  }  
]
```
#### Parameters:

Parameters   | Optional? | Description
---------|-----------|------------
id || Quoine user ID



# Fiat Funding
> PUT /accounts/:id/fund

```json
{
  "amount": "100000",
  "notes": "1st Campaign",
  "request_id": "jb-request-01"
}
```

```
Success Response:
```

```json
{
  "id": 9478,
  "currency": "JPY",
  "balance": "100000.0",
  "request_id": "jb-request-01"
}
```

Parameters   | Optional? | Description
---------|-----------|------------
id || account id
amount || fund amount
notes |yes| notes

Response Parameters

Parameters   | Description
---------|------------
id | account id
currency | account currency
balance | account balance

# Fiat Withdrawal
> PUT /accounts/:id/withdraw

```json
{
  "amount": "100000",
  "notes": "1st Campaign",
  "request_id": "jb-request-01"
}
```
```
Success Response:
```

```json
{
  "id": 9478,
  "currency": "JPY",
  "balance": "100000.0",
  "request_id": "jb-request-01"
}
```

Request fiat withdrawal. Account balance will be deducted immediately

Parameters   | Optional? | Description
---------|-----------|------------
id || account id
amount || withdrawal amount
notes |yes| notes

Response Parameters

Parameters   | Description
---------|------------
id | account id
currency | account currency
balance | account balance

# II. REST API (User)

<aside class="notice">
  All endpoints listed in this section require authentication (signed by User ID/Secret)
</aside>

# Crypto Withdrawals
## Create a Crypto Withdrawal

> POST /crypto_withdrawals/

```json
{
  "auth_code": "13332",
  "crypto_withdrawal": {
    "amount": "0.5",
    "address": "1ACiWrMafn3YLRw5DCf9CqGAHcg1oK9tUj",
    "currency": "BTC"
  }
}
```

```
Success Response:
```

```json
{
  "id": 20,
  "amount": "0.5",
  "address": "1ACiWrMafn3YLRw5DCf9CqGAHcg1oK9tUj",
  "state": "pending"
}
```

## Get a Crypto Withdrawal

> GET /crypto_withdrawals/:id

```
Success Response:
```

```json
{
  "id": 20,
  "amount": "0.5",
  "address": "1ACiWrMafn3YLRw5DCf9CqGAHcg1oK9tUj",
  "state": "pending"
}
```

## Get Crypto Withdrawals

> GET /crypto_withdrawals

```
Success Response:
```

```json
{
  "models": [
    {
      "id": 20,
      "amount": "0.5",
      "address": "1ACiWrMafn3YLRw5DCf9CqGAHcg1oK9tUj",
      "state": "pending"
    }
  ],
  "current_page": 1,
  "total_pages": 1
}
```

# III. Notifications

# Websocket

Quoine uses Pusher for real time data streaming. Please check <a href='https://pusher.com/docs/'>Pusher</a> documentation and libraries on how to connect to our stream. You can also find an example for each stream below.

Please contact us for pusher key

### Market Data
- CHANNEL: `market_data_bid_ask`
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
