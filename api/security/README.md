## HTTPS setup with certificate verification

### Create a new certificate authority

```
openssl req -new -x509 -days 9999 -config ca.cnf -keyout ca-portal-key.pem -out ca-portal-crt.pem
```

The configuration for it is in the `ca.cnf` file

This command will generate `ca-portal-crt.pem` and `ca-portal-key.pem`

### Generate a private key for the server

```
openssl genrsa -out server-portal-key.pem 4096
```

### Generate a certificate signing request and sign it

```
openssl req -new -config server.cnf -key server-portal-key.pem -out server-portal-csr.pem
```

```
openssl x509 -req -extfile server.cnf -days 999 -passin "pass:portal1234" -in server-portal-csr.pem -CA ca-portal-crt.pem -CAkey ca-portal-key.pem -CAcreateserial -out server-portal-crt.pem
```

### Generate a client certificate

```
openssl genrsa -out client-portal-key.pem 4096
```

### Generate a client certificate signing request and sign it

```
openssl req -new -config client.cnf -key client-portal-key.pem -out client-portal-csr.pem
```

```
openssl x509 -req -extfile client.cnf -days 999 -passin "pass:portal1234" -in client-portal-csr.pem -CA ca-portal-crt.pem -CAkey ca-portal-key.pem -CAcreateserial -out client-portal-crt.pem
```

