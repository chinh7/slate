---
title: Quoine Exchange API Reference

language_tabs:
  - ruby

toc_footers:
  - <a href='/payment.html'>Quoine Payment API</a>

includes:
  - errors

search: true
---

# Introduction

> The base URL for production is `https://api.quoine.com/`. All responses are in JSON format with the following status codes:

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

Quoine API provides a simple REST API to retrieve information about our markets and user data. The API outlined in this documentation is for App Vendor. App Vendor API is currently available to only our partners. For more information about partnership, please contact us directly.

<aside class="notice">
RATE LIMITING
<br>
API users should not make more than 300 requests per 5 minute. Requests go beyond the limit will return with a 429 status
</aside>
# I. REST API

# 1. User Onboarding
## 1.1. Create onboarding user

```
POST /users/onboarding
```
#### Parameters:

* `first_name*`:
* `last_name*`:
* `phone*`: phone number, can be with or without country code, e.g +819017901357, 09017901357
* `email*`:
* `country*`: country code, e.g 'JP', 'VN', 'US'
* `password*`:
* `id_document*`: Id document file
* `proof_address*`: Proof of address file
* `bank_statement*`: Bank statement file
* `first_furi_name`: for Japanese name
* `last_furi_name`: for Japanese name
* `address`:
* `city`:
* `postcode`:

> Success Response

```
{
  "success": true,
  "user_id": 25
}
```

> Error Response

```
{
  "success": false,
  "message": "Password cannot be blank"
}
```

## 1.2. Check onboarding user status

```
POST /users/onboarding_status
```
#### POST Parameters:

* `user_id*`: user id
* `password*`: user password

<aside class="notice">
Make sure your POST params are user_id and password of the user that was created in #1.1, not the caller id and password.
</aside>

#### Response Parameters:

* `status`: 'PENDING', 'DOCUMENTS_SUBMITTED', 'APPROVED', 'DECLINED'

> Success Response

```json
{
  "status": "APPROVED",
  "api_id": "25",
  "api_secret": "XMDwUjclch9IVNfuVjep23tMZRhPk0GId0mwFO2N1RPF8WZQ=="
}
```

```json
{
  "status": "DECLINED"
}
```


> Error Response

```json
{
  "message": "Unauthorized access"
}
```

# 2. Bitcoin Withdrawals
## 2.1. Create a bitcoin withdrawal

```
POST /btc_withdrawals/
```
<aside class="notice">
To request auth_code, please GET /users/:user_id/auth_code. This authentication code will be sent via email or sms.
</aside>

> Sample payload

```json

{
  "auth_code": "13332",
  "btc_withdrawal": {
    "amount": 0.5,
    "address": "1ACiWrMafn3YLRw5DCf9CqGAHcg1oK9tUj"
  }
}
```

> Success Response

```json
{
  "id": 20,
  "amount": 0.5,
  "address": "1ACiWrMafn3YLRw5DCf9CqGAHcg1oK9tUj",
  "state": "pending"
}
```

## 2.2. Get a bitcoin withdrawal

```
GET /btc_withdrawals/:id
```
> Success Response

```json
{
  "id": 20,
  "amount": 0.5,
  "address": "1ACiWrMafn3YLRw5DCf9CqGAHcg1oK9tUj",
  "state": "pending"
}
```


# II. WebSocket API

Quoine uses Pusher for real time data streaming. Please check <a href='https://pusher.com/docs/'>Pusher</a> documentation and libraries on how to connect to our stream. You can also find an example for each stream below.

Please contact us for pusher key

### Products
- CHANNEL: `product_cash_[currency pair code]_[product id]` (e.g. `product_cash_btcusd_1`)
- EVENT: `updated`

### Order book:
- CHANNEL: `price_ladders_cash_[currency pair code]_[side]` (e.g. `price_ladders_cash_btcjpy_sell`)
- EVENT: `updated`

### Executions:
- CHANNEL: `executions_cash_[currency pair code]` (e.g. `executions_cash_btcjpy`)
- EVENT: `created`
