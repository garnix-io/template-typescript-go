# template-typescript-go

A garnix-compatible repo configuring an example server with a typescript
frontend and a go backend. You can see this repo deployed
[here](http://server.main.template-typescript-go.garnix-io.garnix.me/).

To deploy this on garnix:

1) Create a [garnix](https://garnix.io) account if you don't have one yet.
2) Fork this repo.
3) Make sure the garnix GitHub App is enabled on this repo.
4) [Optional] Add your public ssh key in [./hosts/server.nix](https://github.com/garnix-io/template-typescript-go/blob/main/hosts/server.nix). This will allow you to ssh into your deployed host.
5) Push your changes! garnix will build and deploy the package, and make your
   server available on a `garnix.me` domain.
