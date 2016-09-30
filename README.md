# servant-client-ghcjs-problemCauser

Reproduces some problems with the [client-ghcjs](https://github.com/LumiGuide/servant/tree/client-ghcjs) branch of servant. Created specifically to contribute to [This issue](https://github.com/haskell-servant/servant/issues/51).


# Topology
This repository contains three projects: `client-0.8.1`, `client-0.9` and `server`. 

`client-0.8.1` and `client-0.9` implement the same test client. Both are compiled with ghcjs. The difference between the two is that `client-0.8.1` depends on the `servant-client` package provided by the [client-ghcjs](https://github.com/LumiGuide/servant/tree/client-ghcjs) branch of the servant repository, while `client-0.9` depends on a [fork](https://github.com/LumiGuide/servant/tree/client-ghcjs) in which simply the `client-ghcjs` branch is updated to version 0.9 of servant.

The `server` project runs a simple server using `servant-0.8.1` and `servant-server-0.8.1`. When the server is running, the following URLs should load `client-0.8.1` and `client-0.9` respectively:

[http://localhost:8081/0.8.1/](http://localhost:8081/0.8.1/)

[http://localhost:8081/0.9/](http://localhost:8081/0.9/)

Note: The clients both display an empty page. The interesting stuff happens in the console.
