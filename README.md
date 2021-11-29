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
