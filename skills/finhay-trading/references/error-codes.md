# Error Codes

Errors appear in two places:
1. **Top-level** `error_code` — HTTP/auth level failures
2. **Per-order** `result[].code` + `result[].rejected_reason` — exchange-level rejections

## HTTP-Level Errors

| Status | Meaning |
|--------|---------|
| 400 | Invalid request — missing field, bad value |
| 401 | Auth failure — bad API key, expired signature, reused nonce |
| 403 | Forbidden — IP blocked, scope denied |
| 429 | Rate limit exceeded — wait until `X-RateLimit-Reset` |
| 500 | Internal server error |

## Order-Level Error Codes

These appear in `result[].code` when the order is rejected.

### Buying Power / Selling Power

| Code | Message |
|------|---------|
| `-400116` | Vượt quá sức mua/sức bán |
| `QMAX_EXCEED` | Vượt quá sức mua/sức bán |

### Price / Quantity Validation

| Code | Message |
|------|---------|
| `-900017` | Bạn vui lòng kiểm tra và thử lại nhé (invalid price/lot) |
| `-10011` | Bạn vui lòng kiểm tra và thử lại nhé |
| `INVALID_PRICE_LOT` | Bạn vui lòng kiểm tra và thử lại nhé |
| `-700106` | Bạn hãy kiểm tra lại số lượng đặt, giá đặt và thử lại nhé |
| `-700104` | Điều chỉnh số lượng đặt và thử lại nhé |
| `-700105` | Điều chỉnh số lượng đặt và thử lại nhé |
| `-700114` | Đối với lô lẻ, bạn chỉ có thể đặt lệnh LO |

### Market Session

| Code | Message |
|------|---------|
| `-300025` | Vui lòng quay lại ở phiên giao dịch sau |
| `-100113` | Loại lệnh không phù hợp với phiên giao dịch này |
| `INVALID_ORDER_TYPE_FOR_THIS_SESSION` | Loại lệnh không phù hợp với phiên giao dịch này |

### Symbol Restrictions

| Code | Message |
|------|---------|
| `-400099` | Chứng khoán bạn đặt mua nằm ngoài danh mục có thể mua |
| `-700069` | Chứng khoán bị hạn chế giao dịch |
| `CAN_NOT_PLACE_ORDER_ON_HALTED_SYMBOL` | Chứng khoán bị hạn chế giao dịch |

### Order Modification

| Code | Message |
|------|---------|
| `-701111` | Lệnh đã khớp một phần và chỉ sửa được phần chưa khớp |

### General

| Code | Message |
|------|---------|
| `MUST_PUBLISH_TRADE_INFO` | Yêu cầu công bố thông tin trước khi giao dịch |
| `FAILED` | Có lỗi xảy ra, vui lòng thử lại |

## Handling Errors

1. **Display the error code and message** to the user in full.
2. **Do not retry automatically** — financial operations must not be retried without explicit user consent.
3. **For ambiguous failures** (timeout, network error): check the order book to determine if the order was placed before retrying.
