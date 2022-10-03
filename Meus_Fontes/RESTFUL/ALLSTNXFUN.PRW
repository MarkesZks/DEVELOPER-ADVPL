#Include "Protheus.ch"
#INCLUDE "restful.ch"

/*/{Protheus.doc} CCDToken
Endpoint Login KeyCloak
@type function
@author TOTVS
@since XX/XX/XXXX
/*/

User Function CCDToken()
	Local cRet    := ''
	Local oResp   := Nil
	Local cUrl    := GetNewPar("MV_XTOKURL", "https://auth.planoparasuaempresa.com.br")
	Local cPath   := GetNewPar("MV_XTOKPAT", "/?LOGIN=integrador.1023@allstrategy.com.br&PASSWORD=3jcZ5SgW")
	Local cUser   := GetNewPar("MV_XTOKUSR", "integrador.1023@allstrategy.com.br")
	Local cPass   := GetNewPar("MV_XTOKPAS", "3jcZ5SgW")
	Local aHeader := {}
	Local cParams := ""
	Local cToken    := ""
	Local oRest   := Nil

	oRest := FwRest():New(cUrl)

	oRest:SetPath(cPath)

	cParams := "?LOGIN=" + cUser + "&PASSWORD=" + cPass

	oRest:SetGetParams(cParams)

	if oRest:Get(aHeader)
		cRet := oRest:GetResult()
		
	FWJsonDeserialize(cRet, @oResp)
	cToken := oResp:AUTH_TOKEN
	else
		cRet :=oRest:GetLastError()
	endif




	FreeObj(oResp)
	FreeObj(oRest)


Return(cToken)

/*/{Protheus.doc} CCDAgenda
Endpoint Agendar
@type function
@author TOTVS
@since XX/XX/XXXX
/*/

User Function CCDAgenda()
//	Local lRet     := .F.
	Local cToken   := U_CCDToken()
	Local cUrl     := GetNewPar("MV_XCCDURL", "https://api.planoparasuaempresa.com.br")
	Local cPath    := GetNewPar("MV_XCCDAGE", "/realizado/v2/dre")
	Local cData    := GetNewPar("MV_XCCDTA", "20220601")
	Local cDataR    := ''
	Local oJson    := Nil
	Local oResp    := Nil
	Local oResp1   := Nil
	Local cPage	:= ''
	Local nQnt := 0

	Local cRet 	:= ''
	Local cChave := ''
	Local oRest   := Nil
	Local cQuery := ""
	Local cTab      := GetNextAlias()
	Local aRetorno := {}


	Default nEmp   := 0
	Default nUni   := 0
	Default nCC    := 0
	Default cDoc   := ""
	Default cDtVld := ""
	Default nHist  := 0
	Default nValor := 0



	cQuery += "SELECT COUNT(*) AS QTDE_REGS"+ CRLF
	cQuery += "FROM ("+ CRLF
	cQuery += "SELECT SUBSTRING(CT2_DATA, 5, 2) AS MES"+ CRLF
	cQuery += "	,SUBSTRING(CT2_DATA, 1, 4) AS ANO"+ CRLF
	cQuery += "	,SUBSTRING(CT2_DATA, 7, 2) + '/' + SUBSTRING(CT2_DATA, 5, 2) + '/' + SUBSTRING(CT2_DATA, 1, 4) AS DATA  "+ CRLF
	cQuery += "	,'010' AS CODUNIDADE"+ CRLF
	cQuery += "	,CT2_CCD AS CODCENTRODECUSTO"+ CRLF
	cQuery += "	,RTRIM(CTT_DESC01) AS DESCCENTRODECUSTO"+ CRLF
	cQuery += "	,CT2_DEBITO AS CODCONTACONTABIL"+ CRLF
	cQuery += "	,CT1_DESC01 AS DESCCONTACONTABIL"+ CRLF
	cQuery += "	,RTRIM(CT2_DOC) + '/' + RTRIM(CT2_LOTE) + '/' + RTRIM(CT2_SBLOTE) AS DOCUMENTO"+ CRLF
	cQuery += "	,'D' AS NATUREZA"+ CRLF
	cQuery += "	,CT2_VALOR AS VALOR"+ CRLF
	cQuery += "	,CT2_HIST AS HISTORICO"+ CRLF
	cQuery += "	,'' CODPROJETO"+ CRLF
	cQuery += "	,'' GERADOR"+ CRLF
	cQuery += "	,'N' RATEIO"+ CRLF
	cQuery += "FROM CT2010 T0"+ CRLF
	cQuery += "INNER JOIN CT1010 T1 ON CT1_CONTA = CT2_DEBITO"+ CRLF
	cQuery += "INNER JOIN CTT010 T2 ON CTT_CUSTO = CT2_CCD"+ CRLF
	cQuery += "WHERE (SUBSTRING(CT2_DEBITO, 1, 1) = '3')"+ CRLF
	cQuery += "	AND T0.CT2_DATA >= '" + cData + "'"+ CRLF
	cQuery += "	AND T0.CT2_TPSALD = '1'"+ CRLF
	cQuery += "	AND T0.D_E_L_E_T_ = ''"+ CRLF
	cQuery += "	AND T1.D_E_L_E_T_ = ''"+ CRLF
	cQuery += "	AND T2.D_E_L_E_T_ = ''"+ CRLF
	cQuery += "UNION ALL"+ CRLF
	cQuery += "SELECT SUBSTRING(CT2_DATA, 5, 2) AS MES"+ CRLF
	cQuery += "	,SUBSTRING(CT2_DATA, 1, 4) AS ANO"+ CRLF
	cQuery += "	,SUBSTRING(CT2_DATA, 7, 2) + '/' + SUBSTRING(CT2_DATA, 5, 2) + '/' + SUBSTRING(CT2_DATA, 1, 4) AS DATA  "+ CRLF
	cQuery += "	,'010' AS CODUNIDADE"+ CRLF
	cQuery += "	,CASE"+ CRLF
	cQuery += "WHEN CT2_CCC = ''"+ CRLF
	cQuery += "THEN '0.88.00'"+ CRLF
	cQuery += "ELSE CT2_CCC"+ CRLF
	cQuery += "END AS CODCENTRODECUSTO"+ CRLF
	cQuery += "	,CASE"+ CRLF
	cQuery += "WHEN CT2_CCC = ''"+ CRLF
	cQuery += "THEN 'RECEITA'"+ CRLF
	cQuery += "ELSE ("+ CRLF
	cQuery += "SELECT CTT_DESC01"+ CRLF
	cQuery += "FROM CTT010"+ CRLF
	cQuery += "WHERE CTT_CUSTO = CT2_CCC"+ CRLF
	cQuery += "AND D_E_L_E_T_ = ''"+ CRLF
	cQuery += ")"+ CRLF
	cQuery += "END AS DESCCENTRODECUSTO"+ CRLF
	cQuery += "	,CT2_CREDIT AS CODCONTACONTABIL"+ CRLF
	cQuery += "	,CT1_DESC01 AS DESCCONTACONTABIL"+ CRLF
	cQuery += "	,RTRIM(CT2_DOC) + '/' + RTRIM(CT2_LOTE) + '/' + RTRIM(CT2_SBLOTE) AS DOCUMENTO"+ CRLF
	cQuery += "	,'C' AS NATUREZA"+ CRLF
	cQuery += "	,CT2_VALOR AS VALOR"+ CRLF
	cQuery += "	,CT2_HIST AS HISTORICO"+ CRLF
	cQuery += "	,'' CODPROJETO"+ CRLF
	cQuery += "	,'' GERADOR"+ CRLF
	cQuery += "	,'N' RATEIO"+ CRLF
	cQuery += "FROM CT2010 T0"+ CRLF
	cQuery += "INNER JOIN CT1010 T1 ON CT1_CONTA = CT2_CREDIT"+ CRLF
	cQuery += "INNER JOIN CTT010 T2 ON CTT_CUSTO = CT2_CCC"+ CRLF
	cQuery += "WHERE (SUBSTRING(CT2_CREDIT, 1, 1) = '3')"+ CRLF
	cQuery += "	AND T0.CT2_DATA >= '" + cData + "'"+ CRLF
	cQuery += "	AND T0.CT2_TPSALD = '1'"+ CRLF
	cQuery += "	AND T0.D_E_L_E_T_ = ''"+ CRLF
	cQuery += "	AND T1.D_E_L_E_T_ = ''"+ CRLF
	cQuery += ")AS LINHA"+ CRLF
	cQuery += "ORDER BY COUNT(*)  ASC;"+ CRLF

	MPSysOpenQuery(cQuery,(cTab))
	DbSelectArea(cTab)

	nQnt := (cTab)->QTDE_REGS // nQnt = 28951

	if nQnt >= 2500
		// cPage = 144,755
		nQnt := (nQnt/200)
		cPage := Round(Ceiling(nQnt), 0)  // Resultado: 145
	else
		nQnt :=(nQnt/100)
		cPage := Round(Ceiling(nQnt), 0) // Resultado: 289

	endif


	oRest := FwRest():New(cUrl)
	oRest:SetPath(cPath)


	cDataR:= SUBSTRING(cData, 1, 4) + '-' + SUBSTRING(cData, 5, 2) + '-' + SUBSTRING(cData, 7, 2)

	oJson                     := JsonObject():New()
	oJson['AUTH_TOKEN']       := cToken
	oJson['PAGINAS']          := cPage //
	oJson['COMPETENCIA']      := cData //
	oJson['CARGA_ADICIONAL']  := 0

	oRest:SetPostParams(oJson:ToJson())

	oRest:Post()
	cRet := oRest:GetResult()

	FWJsonDeserialize(cRet, @oResp1)

	cChave := oResp1:CHAVE_INTEGRACAO



	aAdd(aRetorno, cChave)
	//aAdd(aRetorno, cPage)
	//aAdd(aRetorno, cToken)
	//aAdd(aRetorno, cData)

	FreeObj(oJson)
	FreeObj(oResp)
	FreeObj(oResp1)



Return(aRetorno)


/*/{Protheus.doc} CCDGerMov
Endpoint Gerar Movimento
@type function
@author TOTVS
@since XX/XX/XXXX
/*/

User Function CCDChave()

	Local aRetorno    := U_CCDAgenda()
	Local cChave := ''
	Local nPage := 0
	Local cToken := ''
	Local oRest     := Nil
	Local cMes :=  ''
	Local CAno := ''
	Local cDataR := ''

	Local cUrl      := GetNewPar("MV_XCCDURL", "https://api.planoparasuaempresa.com.br")
	Local cPath     := GetNewPar("MV_XCCDMOV", "/realizado/v2/dre")

	Local oJson     := Nil
	Local cResp     := ""
	local oImport := Nil
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


//Query parte de itens 

	cChave := aRetorno[1]
	//nPage := aRetorno[2]
	//cToken := aRetorno[3] // 
	//cData	:= aRetorno[4]

//	cMes:= SUBSTRING(cData, 7, 2)
//	CAno:= SUBSTRING(cData, 1, 4)
//	cDataR:= SUBSTRING(cData, 5, 2) + '/' + SUBSTRING(cData, 7, 2)+ '/' +SUBSTRING(cData, 1, 4)

	oRest := FwRest():New(cUrl)
	oRest:SetPath(cPath)

while condition
	
end
	oJson                             := JsonObject():New()
	oJson['AUTH_TOKEN']           := cToken
	oJson['CHAVE_INTEGRACAO']          := cChave
	oJson['PAGINA']            := nPage

	oImport                             := JsonObject():New()
	oImport['MES']           := cMes
	oImport['ANO']          := CAno
	oImport['DATA']            := cDataR //01/02/2022
	oImport['COD_UNIDADE']    := "ACCO"
	oImport['COD_CC']           := "01CEARA505"
	oImport['DESC_CC']          := "COMUNICAÇÃO"
	oImport['COD_CONTA']            := "4111017"
	oImport['DESC_CONTA']    := "EQUIPAMENTOS DE PROTEÇÃO INDIVIDUAL"
	oImport['DOCUMENTO']           := "DOCUMENTO TESTE JSON 1"
	oImport['NATUREZA']          := "D"
	oImport['VALOR']            := "999.99"
	oImport['HISTORICO']    := "HISTORICO"
	oImport['COD_PROJETO']           := "010"
	oImport['GERADOR']          := "GERADOR"
	oImport['COD_DIMENSAO']            := "1001"
	oImport['RATEIO']    := "N"

	oJson['IMPORTACAO']    := oImport

	oRest:SetPostParams(oJson:ToJson())

	oRest:Post()
	cResp := oRest:GetResult()

	FWJsonDeserialize(cResp, @oResp)

	FreeObj(oJson)
	FreeObj(oResp)
	FreeObj(oRest)
	FreeObj(oImport)

Return()

/*/{Protheus.doc} CCDEnvTed
Endpoint Envio TED
@type function
@author TOTVS
@since XX/XX/XXXX
/*/
	oRest:SetPostParams(oJson:ToJson())


