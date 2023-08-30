/*-
 * #%L
 * MuleSoft Training - Anypoint Platform Development: Level 2
 * %%
 * Copyright (C) 2019 - 2021 MuleSoft, Inc. All rights reserved. http://www.mulesoft.com
 * %%
 * The software in this package is published under the terms of the
 * Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International Public License,
 * a copy of which has been included with this distribution in the LICENSE.txt file.
 * #L%
 */
var paymtID = "PMT123"
var amt = 6.66
var desc = "15 bags to check-in"
// request body sent to create-payment
var createPmtRequ = {
	amount: amt,
	description: desc
}
// response returned from corresponding invocation of PayPal create payment API
var ppCreatePmtResp = {
	id: paymtID
}
var payerID = "PY456"
// request body sent to approve-payment
var approvePmtRequ = {
	payerID: payerID
}
// response returned from corresponding invocation of PayPal execute payment API 
var ppExecPmtResp = {
	state: "approved"
}
