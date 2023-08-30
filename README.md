# Production-Ready Integrations

## Credential
* Org
  * Orgid : f8065f81-8fba-4852-accf-0f6794609319
  * client_id : e644e81c90414710828b3ae3fb5af76a
  * client_secret : 1f110A1aa4e246EB865e9b563aDE48A6

* ConnectedApps
  * Exchange Viewer
    * client id : a5b546c42e5e43e7a35f90efef4a86a4
    * client secret : B02bcE067BDc43979A76627D5acA0143
  * Exchange Viewer
    * client id : 52d57d6bf94f4cc39ff6f22d4bffac11
    * client secret : 8C81Ec2B1f1E4929b19B7022AdEE5eF0


* Memo
  * access token : l2k28ss.sid3fjfd5_Zsrq9cK9hNsqrSTfu8ji334EEVW83hjskShnodE
  * curl -i -X POST -H "Content-Type: application/json" -H "Authorization: Bearer l2k28ss.sid3fjfd5_Zsrq9cK9hNsqrSTfu8ji334EEVW83hjskShnodE" -d "{ \"intent\":\"sale\", \"payer\": {\"payment_method\":\"paypal\" }, \"transactions\":[ { \"amount\":{\"total\":\"80.00\", \"currency\":\"USD\" }, \"description\": \"Check-In Baggage.\", \"custom\": \"ANYAIRLINE_90048630024435\",\"invoice_number\": \"48787589673\", \"payment_options\":{\"allowed_payment_method\":\"INSTANT_FUNDING_SOURCE\" },\"soft_descriptor\":\"ANYAIRLINE BAGGAGE\" } ], \"note_to_payer\":\"Behappy.\" }" https://training-paypal-fake-api-sandbox-mjf1rw.5sc6y6-1.usa-e2.cloudhub.io/v1/payments/payment

* (Sample) Custom connector with insecure certificate
```
  @Inject
    private HttpService service;

    private HttpClient client;

    static final String PEM_MIME_TYPE = "application/x-pem-file";
    static final String ACCEPT_HEADER_VALUE = PEM_MIME_TYPE;
    static final int DEFAULT_RESPONSE_TIMEOUT=10000;
    static final boolean strictContentType=false;

    /**
     * Go to jwks url and retrieve the keys required to create the certs
     * @param jwksServerUrl
     * @param keyId
     * @param  allowInsecureConnections
     * @return
     */
    @MediaType(value = "text/plain")
    @Throws(AsapjwtErrorsProvider.class)
    public String retrieveJwksKeys(String jwksServerUrl, String keyId, @Optional(defaultValue = "true") boolean allowInsecureConnections) {

        Preconditions.checkArgument(jwksServerUrl != null,"JWKS Base URL Cannot be Null");
        Preconditions.checkArgument(keyId != null, "JWT key identifier required to pull the public key from the JWKS server");
        Boolean allowInsecureFlag = allowInsecureConnections;

        TlsContextFactory tlsContext;
        try {
            tlsContext = TlsContextFactory.builder().insecureTrustStore(allowInsecureFlag).build();
        } catch (CreateException e) {
            throw new RuntimeException("Can not retrieve JWKS", e);
        }
        HttpClientConfiguration httpClientConfig = new HttpClientConfiguration.Builder().setName(getClass().getName())
                .setTlsContextFactory(tlsContext).build();

        try {
            client = service.getClientFactory().create(httpClientConfig);
            client.start();
            HttpResponse response = client.send(
                    HttpRequest.builder().addHeader(ACCEPT,ACCEPT_HEADER_VALUE)
                            .uri(jwksServerUrl + "/" + keyId )
                            .method(GET).build(),
                    DEFAULT_RESPONSE_TIMEOUT,
                    true,
                    null);
            HttpConstants.HttpStatus statusCode= HttpConstants.HttpStatus.getStatusByCode(response.getStatusCode());

            switch (statusCode) {
                case OK:
                    HttpEntity entity = response.getEntity();
                    if (entity != null) {
                       return getBodyFromResponse(response);
                    } else {
                        logger.info("Unexpected empty HTTP response when trying to retrieve public key URL {}", jwksServerUrl + "/" + keyId);
                        throw new ModuleException(format("Unexpected empty response getting public key %s", jwksServerUrl + "/" + keyId),AsapjwtValidatorError.JWKS_PUBLIC_KEY_RETRIEVE_ERROR);
                    }
                case FORBIDDEN:
                case NOT_FOUND:
                    final String statusReason = response.getReasonPhrase();
                    // log at info level because this can be caused by invalid input
                    logger.info("Public key URL {} returned {} {}", jwksServerUrl + "/" + keyId, statusCode, statusReason);
                    throw new ModuleException(format("Encountered %s %s for public key", statusCode, statusReason), AsapjwtValidatorError.JWKS_PUBLIC_KEY_RETRIEVE_ERROR);
                default:
                    logger.warn("Unexpected HTTP status code {} when trying to retrieve public key URL {}", statusCode, jwksServerUrl + "/" + keyId);
                    throw new ModuleException(format("Unexpected status code " + statusCode + " getting public key", jwksServerUrl + "/" + keyId),AsapjwtValidatorError.JWKS_PUBLIC_KEY_RETRIEVE_ERROR);
            }


        } catch (IOException e) {
            throw new RuntimeException("Can not retrieve JWKS", e);

        } catch (TimeoutException e) {
            throw new RuntimeException("Can not retrieve JWKS", e);

        }
    }
```