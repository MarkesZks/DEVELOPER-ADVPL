#Include "Protheus.ch"

/*/{Protheus.doc} CCDToken
Endpoint Login KeyCloak
@type function
@author TOTVS
@since XX/XX/XXXX
/*/

User Function CCDToken()
	Local aRet    := {}
	Local cTipo   := ""
	Local cToken  := ""
	Local oRest   := Nil
	Local cUrl    := GetNewPar("MV_XTOKURL", "http://hml-totvs-keycloak.bancodigimais.com.br:8180")
	Local cPath   := GetNewPar("MV_XTOKPAT", "/auth/realms/master/protocol/openid-connect/token")
	Local cGrant  := GetNewPar("MV_XTOKGRA", "password")
	Local cClient := GetNewPar("MV_XTOKCLI", "tfs-contacorrente-digital-service")
	Local cUser   := GetNewPar("MV_XTOKUSR", "kcjobcontacorre")
	Local cPass   := GetNewPar("MV_XTOKPAS", "password")
	Local aHeader := {}
	Local cParams := ""
	Local cResp   := ""
	Local cMsg    := ""
	Local oResp   := Nil

	oRest := FwRest():New(cUrl)

	oRest:SetPath(cPath)

	aAdd(aHeader, "Content-Type: application/x-www-form-urlencoded")

	cParams := "grant_type=" + cGrant + "&client_id=" + cClient + "&username=" + cUser + "&password=" + cPass + ""

	oRest:SetPostParams(cParams)

	If (oRest:Post(aHeader))
		cResp := oRest:GetResult()

		FWJsonDeserialize(cResp, @oResp)

		If (ValType(oResp:TOKEN_TYPE) == "C")
			cTipo := oResp:TOKEN_TYPE
		Endif

		If (ValType(oResp:ACCESS_TOKEN) == "C")
			cToken := oResp:ACCESS_TOKEN
		Endif

		If !((Empty(cTipo)) .And. (Empty(cToken)))
			aRet := {cTipo, cToken}
		Endif
	Else
		cResp := oRest:GetResult()

		If (ValType(oResp:SUCESS) == "L")
			lRet := oResp:SUCESS
		Endif

		If (ValType(oResp:MESSAGE) == "C")
			cMsg := oResp:MESSAGE
		Endif
	Endif

	FreeObj(oResp)
	FreeObj(oRest)
Return(aRet)

/*/{Protheus.doc} CCDAgenda
Endpoint Agendar
@type function
@author TOTVS
@since XX/XX/XXXX
/*/

User Function CCDAgenda(nEmp, nUni, nCC, cDoc, cDtVld, nHist, nValor)
	Local lRet     := .F.
	Local aToken   := U_CCDToken()
	Local cTipo    := ""
	Local cToken   := ""
	Local oRest    := Nil
	Local cUrl     := GetNewPar("MV_XCCDURL", "http://hml-totvs-be_basico.bancodigimais.com.br:8080")
	Local cPath    := GetNewPar("MV_XCCDAGE", "/tfs-contacorrente-digital-service/rest/agendamento")
	Local aHeader  := {}
	Local oJson    := Nil
	Local cResp    := ""
	Local cMsg     := ""
	Local oResp    := Nil

	Default nEmp   := 0
	Default nUni   := 0
	Default nCC    := 0
	Default cDoc   := ""
	Default cDtVld := ""
	Default nHist  := 0
	Default nValor := 0

	If !(Empty(aToken))
		cTipo  := aToken[1]
		cToken := aToken[2]
	Endif

	oRest := FwRest():New(cUrl)

	oRest:SetPath(cPath)

	aAdd(aHeader, "Authorization: " + cTipo + " " + cToken + "")
	aAdd(aHeader, "Content-Type: application/json")

	oJson                        := JsonObject():New()
	oJson['codigoEmpresa']       := nEmp
	oJson['codigoUnidade']       := nUni
	oJson['codigoContaCorrente'] := nCC
	oJson['numeroDocumento']     := cDoc
	oJson['dataValidade']        := cDtVld
	oJson['codigoHistorico']     := nHist
	oJson['valorLancamento']     := nValor
	oJson['siglaOrigem']         := "CCD"
	oJson['tipoAgenda']          := "NORMAL"

	oRest:SetPostParams(oJson:ToJson())

	If (oRest:Post(aHeader))
		cResp := oRest:GetResult()

		FWJsonDeserialize(cResp, @oResp)

		If (ValType(oResp:SUCESS) == "L")
			lRet := oResp:SUCESS
		Endif
	Else
		cResp := oRest:GetResult()

		If (ValType(oResp:SUCESS) == "L")
			lRet := oResp:SUCESS
		Endif

		If (ValType(oResp:MESSAGE) == "C")
			cMsg := oResp:MESSAGE
		Endif
	Endif

	FreeObj(oJson)
	FreeObj(oResp)
	FreeObj(oRest)
Return(lRet)

/*/{Protheus.doc} CCDGerMov
Endpoint Gerar Movimento
@type function
@author TOTVS
@since XX/XX/XXXX
/*/

User Function CCDGerMov(nEmp, nUni, nCC, cDtLanc, nValor, cNat, nHist, nDoc, cHist)
	Local lRet      := .F.
	Local aToken    := U_CCDToken()
	Local cTipo     := ""
	Local cToken    := ""
	Local oRest     := Nil
	Local cUrl      := GetNewPar("MV_XCCDURL", "http://hml-totvs-be_basico.bancodigimais.com.br:8080")
	Local cPath     := GetNewPar("MV_XCCDMOV", "/tfs-contacorrente-digital-service/rest/movimento/")
	Local aHeader   := {}
	Local oJson     := Nil
	Local cResp     := ""
	Local cMsg      := ""
	Local oResp     := Nil

	Default nEmp    := 0
	Default nUni    := 0
	Default nCC     := 0
	Default cDtLanc := ""
	Default nValor  := 0
	Default cNat    := ""
	Default nHist   := 0
	Default nDoc    := 0
	Default cHist   := ""

	cPath +=  AllTrim(Str(nEmp)) + "/" + AllTrim(Str(nUni)) + "/" + AllTrim(Str(nCC))

	If !(Empty(aToken))
		cTipo  := aToken[1]
		cToken := aToken[2]
	Endif

	oRest := FwRest():New(cUrl)

	oRest:SetPath(cPath)

	aAdd(aHeader, "Authorization: " + cTipo + " " + cToken + "")
	aAdd(aHeader, "Content-Type: application/json")

	oJson                             := JsonObject():New()
	oJson['dataLancamento']           := cDtLanc
	oJson['valorLancamento']          := nValor
	oJson['codigoAgencia']            := nUni
	oJson['identificadorNatureza']    := cNat
	oJson['identificadorOrigem']      := "1"
	oJson['sistemaOrigem']            := "CCD"
	oJson['codigoHistorico']          := nHist
	oJson['numeroDocumento']          := nDoc
	oJson['identificadorIsencaoCpmf'] := "N"
	oJson['textoAuxiliar']            := cHist

	oRest:SetPostParams(oJson:ToJson())

	If (oRest:Post(aHeader))
		cResp := oRest:GetResult()

		FWJsonDeserialize(cResp, @oResp)

		If (ValType(oResp:SUCESS) == "L")
			lRet := oResp:SUCESS
		Endif
	Else
		cResp := oRest:GetResult()

		If (ValType(oResp:SUCESS) == "L")
			lRet := oResp:SUCESS
		Endif

		If (ValType(oResp:MESSAGE) == "C")
			cMsg := oResp:MESSAGE
		Endif
	Endif

	FreeObj(oJson)
	FreeObj(oResp)
	FreeObj(oRest)
Return(lRet)

/*/{Protheus.doc} CCDEnvTed
Endpoint Envio TED
@type function
@author TOTVS
@since XX/XX/XXXX
/*/

User Function CCDEnvTed(nEmp, cDtMov, nValor, nFin, cNivel, cIdent, cHist, cCCBco, cCCAgen, cCCConta, ;
		cCCTipo, cCCPessoa, cCCNome, cCCDoc, cCDBco, cCDAgen, cCDConta, cCDTipo, cCDPessoa, cCDNome, cCDDoc)
	Local lRet        := .F.
	Local aToken      := U_CCDToken()
	Local cTipo       := ""
	Local cToken      := ""
	Local oRest       := Nil
	Local cUrl        := GetNewPar("MV_XCCDURL", "http://hml-totvs-be_basico.bancodigimais.com.br:8080")
	Local cPath       := GetNewPar("MV_XCCDTED", "/tfs-contacorrente-digital-service/rest/tedspb/envio-online")
	Local aHeader     := {}
	Local oJson       := Nil
	Local oCredito    := Nil
	Local oDebito     := Nil
	Local cResp       := ""
	Local cMsg        := ""
	Local oResp       := Nil

	Default nEmp      := 0
	Default cDtMov    := ""
	Default nValor    := 0
	Default nFin      := 0
	Default cNivel    := ""
	Default cIdent    := ""
	Default cHist     := ""
	Default cCCBco    := ""
	Default cCCAgen   := ""
	Default cCCConta  := ""
	Default cCCTipo   := ""
	Default cCCPessoa := ""
	Default cCCNome   := ""
	Default cCCDoc    := ""
	Default cCDBco    := ""
	Default cCDAgen   := ""
	Default cCDConta  := ""
	Default cCDTipo   := ""
	Default cCDPessoa := ""
	Default cCDNome   := ""
	Default cCDDoc    := ""

	If !(Empty(aToken))
		cTipo  := aToken[1]
		cToken := aToken[2]
	Endif

	oRest := FwRest():New(cUrl)

	oRest:SetPath(cPath)

	aAdd(aHeader, "Authorization: " + cTipo + " " + cToken + "")
	aAdd(aHeader, "Content-Type: application/json")

	oJson                        := JsonObject():New()
	oJson['codigoEmpresa']       := nEmp
	oJson['sistemaOrigem']       := "CCD"
	oJson['dataMovimento']       := cDtMov
	oJson['valorLancamento']     := nValor
	oJson['finalidade']          := nFin
	oJson['dataAgendamento']     := cDtMov
	oJson['nivelPreferencia']    := cNivel
	oJson['codigoIdentificador'] := cIdent
	oJson['descricaoHistorico']  := cHist

	oCredito                     := JsonObject():New()
	oCredito['codigoISPB']       := cCCBco
	oCredito['numeroAgencia']    := cCCAgen
	oCredito['numeroConta']      := cCCConta
	oCredito['tipoConta']        := cCCTipo
	oCredito['tipoPessoa']       := cCCPessoa
	oCredito['nomePessoa']       := cCCNome
	oCredito['numeroDocumento']  := cCCDoc

	oJson['contaCredito']        := oCredito

	oDebito                      := JsonObject():New()
	oDebito['codigoISPB']        := cCDBco
	oDebito['numeroAgencia']     := cCDAgen
	oDebito['numeroConta']       := cCDConta
	oDebito['tipoConta']         := cCDTipo
	oDebito['tipoPessoa']        := cCDPessoa
	oDebito['nomePessoa']        := cCDNome
	oDebito['numeroDocumento']   := cCDDoc

	oJson['contaDebito']         := oDebito

	oRest:SetPostParams(oJson:ToJson())

	If (oRest:Post(aHeader))
		cResp := oRest:GetResult()

		FWJsonDeserialize(cResp, @oResp)

		If (ValType(oResp:SUCESS) == "L")
			lRet := oResp:SUCESS
		Endif
	Else
		cResp := oRest:GetResult()

		If (ValType(oResp:SUCESS) == "L")
			lRet := oResp:SUCESS
		Endif

		If (ValType(oResp:MESSAGE) == "C")
			cMsg := oResp:MESSAGE
		Endif
	Endif

	FreeObj(oJson)
	FreeObj(oResp)
	FreeObj(oRest)
Return(lRet)

/*/{Protheus.doc} CCDHist
Gravação de Histórico
@type function
@author TOTVS
@since XX/XX/XXXX
/*/

User Function CCDHist(cBordero, cPrefixo, cNum, cParcela, cTipo, cFornece, cLoja, dVencto, nValor, cEnvio, cRetorno)
	Local lRet := .T.

	Default cBordero := ""
	Default cPrefixo := ""
	Default cNum     := ""
	Default cParcela := ""
	Default cTipo    := ""
	Default cFornece := ""
	Default cLoja    := ""
	Default dVencto  := DToS("")
	Default nValor   := 0
	Default cEnvio   := ""
	Default cRetorno := ""

	RecLock("SZ1", .T.)
	SZ1->Z1_FILIAL   := xFilial("SZ1")
	SZ1->Z1_BORDERO  := cBordero
	SZ1->Z1_PREFIXO  := cPrefixo
	SZ1->Z1_NUM      := cNum
	SZ1->Z1_PARCELA  := cParcela
	SZ1->Z1_TIPO     := cTipo
	SZ1->Z1_FORNECE  := cFornece
	SZ1->Z1_LOJA     := cLoja
	SZ1->Z1_VENCTO   := dVencto
	SZ1->Z1_VALOR    := nValor
	SZ1->Z1_STATUS   := "1"
	SZ1->Z1_DATA     := Date()
	SZ1->Z1_HORA     := Time()
	SZ1->Z1_ENVIO    := cEnvio
	SZ1->Z1_RETORNO  := cRetorno
	SZ1->(MsUnlock())
Return(lRet)
