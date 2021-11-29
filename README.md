# DemoHttpStream

A demo to demonstrate how to implement HTTP stream API. It contains:

1. An HTTP stream API implemented by Phoenix, check `DemoHttpStreamWeb.DemoController`
2. Some stream receivers implemented by different HTTP library. check `DemoHttpStream.ReceiverX`

## Start stream API server

```bash
mix phx.server
```

## Start stream receiver

```bash
mix run -e "DemoHttpStream.receiver1.run()"
```

## Useful resources (but not related)

- https://httpbin.org
  A service for testing different HTTP request & responses. I can test stream via `GET /stream/{n}` but seems each HTTP chunk is splitted by data but not JSON string.

- https://badssl.com
  A service for testing SSL.
