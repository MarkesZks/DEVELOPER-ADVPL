#Include "Protheus.ch"

Static nQuebra  := GetNewPar("MV_XQBRPAG", 100)
Static cUrlTOK  := GetNewPar("MV_XASTOK", "https://auth.planoparasuaempresa.com.br")
Static cUrlAPI  := GetNewPar("MV_XASAPI", "https://api.planoparasuaempresa.com.br")
Static cUser    := GetNewPar("MV_XTOKUSR", "integrador.1023@allstrategy.com.br")
Static cPass    := GetNewPar("MV_XTOKPAS", "3jcZ5SgW")
Static cDtComp  := GetNewPar("MV_XDTCOMP", "2022-01-01")
Static cDRE     := GetNewPar("MV_XASDRE" , "/realizado/v2/dre")
Static cFluxo   := GetNewPar("MV_XASFLX" , "/realizado/v2/fluxodecaixa")
Static cBalanco := GetNewPar("MV_XASBAL" , "/realizado/v2/balanco")

/*/{Protheus.doc} ASToken
Endpoint Geração de Token
@type function
@author TOTVS
@since XX/XX/XXXX
/*/

User Function ASToken()
	Local nStatus := 0
	Local cToken  := ""
	Local oRest   := Nil
	Local cParams := "/?LOGIN=" + cUser + "&PASSWORD=" + cPass
	Local cResp   := ""
	Local oResp   := Nil

	oRest := FwRest():New(cUrlTOK)

	oRest:SetPath(cParams)

	If (oRest:Get())
		cResp := EncodeUTF8(NoAcento(oRest:GetResult()))

		FWJsonDeserialize(cResp, @oResp)

		If (ValType(oResp:status) == "N")
			nStatus := oResp:status
		Elseif (ValType(oResp:status) == "C")
			nStatus := Val(oResp:status)
		Endif

		If (!Empty(nStatus))
			If (ValType(oResp:auth_token) == "C")
				cToken := oResp:auth_token
			Endif
		Endif
	Else
		cResp := EncodeUTF8(NoAcento(oRest:GetLastError()))
	Endif

	FreeObj(oResp)
	FreeObj(oRest)
Return(cToken)

/*/{Protheus.doc} ASChvIde
Endpoint Chave de Identificação
@type function
@author TOTVS
@since XX/XX/XXXX
/*/

User Function ASChvIde(nOpc, dDtAtual)
	Local nStatus := 0
	Local cChave  := ""
	Local cToken  := U_ASToken()
	Local nPags   := U_ASPags(nOpc, dDtAtual)
	Local oRest   := Nil
	Local cPath   := ""
	Local oJson   := Nil
	Local cResp   := ""
	Local oResp   := Nil

	Default nOpc := 0

	If (nOpc == 1)
		cPath   := cDRE
	Elseif (nOpc == 2)
		cPath   := cFluxo
	Elseif (nOpc == 3)
		cPath   := cBalanco
	Endif

	oRest := FwRest():New(cUrlAPI)

	oRest:SetPath(cPath)

	oJson                    := JsonObject():New()
	oJson['AUTH_TOKEN']      := cToken
	oJson['PAGINAS']         := nPags
	oJson['COMPETENCIA']     := cDtComp
	oJson['CARGA_ADICIONAL'] := 0

	oRest:SetPostParams(EncodeUTF8(NoAcento(oJson:ToJson())))

	If (oRest:Post())
		cResp := EncodeUTF8(NoAcento(oRest:GetResult()))

		FWJsonDeserialize(cResp, @oResp)

		If (ValType(oResp:status) == "N")
			nStatus := oResp:status
		Elseif (ValType(oResp:status) == "C")
			nStatus := Val(oResp:status)
		Endif

		If ((!Empty(nStatus)) .Or. (nOpc == 3))
			If (ValType(oResp:CHAVE_INTEGRACAO) == "C")
				cChave := oResp:CHAVE_INTEGRACAO
			Endif
		Endif
	Else
		cResp := EncodeUTF8(NoAcento(oRest:GetLastError()))

	Endif

	FreeObj(oJson)
	FreeObj(oResp)
	FreeObj(oRest)
Return(cChave)

/*/{Protheus.doc} ASPags
Retorna Número de Páginas que serão enviadas via integração
@type function
@author TOTVS
@since XX/XX/XXXX
/*/

User Function ASPags(nOpc, dDtAtual)
	Local nPags   := 0
	Local cQuery  := ""
	Local cTab    := ""

	Default nOpc     := 0
	Default dDtAtual := dDataBase

	cQuery := "SELECT COUNT(*) REGS" + CRLF
	cQuery += "FROM (" + CRLF

	If (nOpc == 1)
		cQuery += qryDRE(dDtAtual)
	Elseif (nOpc == 2)
		cQuery += qryFluxo(dDtAtual)
	Elseif (nOpc == 3)
		cQuery += qryBal(dDtAtual)
	Endif

	cQuery += "	) A" + CRLF

	cQuery := ChangeQuery(cQuery)

	cTab := MPSysOpenQuery(cQuery)

	DbSelectArea((cTab))
	(cTab)->(DbGoTop())

	While ((cTab)->(!Eof()))
		nPags := Round(Ceiling((cTab)->REGS/nQuebra), 0)

		(cTab)->(DbSkip())
	Enddo

	(cTab)->(DbCloseArea())
Return(nPags)

/*/{Protheus.doc} ASDRE
Endpoint DRE
@type function
@author TOTVS
@since XX/XX/XXXX
/*/

User Function ASDRE()
	Local nStatus  := 0
	Local cToken   := ""
	Local nPags    := 0
	Local cChave   := ""
	Local aDados   := {}
	Local nI       := 0
	Local oRest    := Nil
	Local cPath    := cDRE
	Local nX       := 0
	Local oJson    := Nil
	Local aJson    := {}
	Local nPos     := 0
	Local cResp    := ""
	Local oResp    := Nil
	Local cId      := ""
	Local nAtual   := 0
	Local cCodSZ1  := ""
	Local dDtIni   := SToD(StrTran(cDtComp, "-", ""))
	Local dDtAtual := dDtIni
	Local cDtAtual := SubStr(DToS(dDtAtual), 1, 6)
	Local cDtMax   := SubStr(DToS(Date()), 1, 6)

	oRest := FwRest():New(cUrlAPI)

	oRest:SetPath(cPath)

	While (cDtMax >= cDtAtual)
		nPags  := U_ASPags(1, dDtAtual)
		nAtual := 0

		If !(Empty(nPags))
			cCodSZ1 := GetSxeNum("SZ1", "Z1_CODIGO")

			cChave := U_ASChvIde(1, dDtAtual)
			aDados := U_ASDados(1, dDtAtual)

			For nI := 1 To nPags
				aJson := {}

				For nX := 1 to nQuebra
					nAtual++

					If (nAtual <= Len(aDados))
						aAdd(aJson, JsonObject():New())
						nPos := Len(aJson)

						aJson[nPos]['MES']          := aDados[nAtual][1]
						aJson[nPos]['ANO']          := aDados[nAtual][2]
						aJson[nPos]['DATA']         := aDados[nAtual][3]
						aJson[nPos]['COD_UNIDADE']  := aDados[nAtual][4]
						aJson[nPos]['COD_CC']       := aDados[nAtual][5]
						aJson[nPos]['DESC_CC']      := aDados[nAtual][6]
						aJson[nPos]['COD_CONTA']    := aDados[nAtual][7]
						aJson[nPos]['DESC_CONTA']   := aDados[nAtual][8]
						aJson[nPos]['DOCUMENTO']    := aDados[nAtual][9]
						aJson[nPos]['NATUREZA']     := aDados[nAtual][10]
						aJson[nPos]['VALOR']        := aDados[nAtual][11]
						aJson[nPos]['HISTORICO']    := aDados[nAtual][12]
						aJson[nPos]['COD_PROJETO']  := aDados[nAtual][13]
						aJson[nPos]['GERADOR']      := aDados[nAtual][14]
						aJson[nPos]['COD_DIMENSAO'] := aDados[nAtual][15]
						aJson[nPos]['RATEIO']       := aDados[nAtual][16]
					Else
						EXIT
					Endif
				Next nX

				cToken := U_ASToken()

				oJson                     := JsonObject():New()
				oJson['AUTH_TOKEN']       := cToken
				oJson['CHAVE_INTEGRACAO'] := cChave
				oJson['PAGINA']           := nI
				oJson['IMPORTACAO']       := aJson

				oRest:SetPostParams(EncodeUTF8(NoAcento(oJson:ToJson())))

				If (oRest:Post())
					cResp := EncodeUTF8(NoAcento(oRest:GetResult()))

					FWJsonDeserialize(cResp, @oResp)

					If (ValType(oResp:status) == "N")
						nStatus := oResp:status
					Elseif (ValType(oResp:status) == "C")
						nStatus := Val(oResp:status)
					Endif

					If (nStatus > 0)
						grvLog("DRE", "1",  EncodeUTF8(NoAcento(oJson:ToJson())), cResp, cCodSZ1)

						If (nStatus == 1)
							If (ValType(oResp:CEPP_ID) == "C")
								cId := oResp:CEPP_ID
							Endif
						Endif
					Else
						grvLog("DRE", "2",  EncodeUTF8(NoAcento(oJson:ToJson())), cResp, cCodSZ1)
					Endif
				Else
					cResp := EncodeUTF8(NoAcento(oRest:GetLastError()))

					grvLog("DRE", "2",  EncodeUTF8(NoAcento(oJson:ToJson())), cResp, cCodSZ1)
				Endif
			Next nI

			ConfirmSX8()
		Endif

		dDtAtual := LastDay(dDtAtual) + 1
		cDtAtual := SubStr(DToS(dDtAtual), 1, 6)
	Enddo

	FreeObj(oJson)
	FreeObj(oResp)
	FreeObj(oRest)
Return(cId)

/*/{Protheus.doc} ASFluxo
Endpoint Fluxo de Caixa
@type function
@author TOTVS
@since XX/XX/XXXX
/*/

User Function ASFluxo()
	Local nStatus := 0
	Local cToken  := ""
	Local nPags   := 0
	Local cChave  := ""
	Local aDados  := {}
	Local nI      := 0
	Local oRest   := Nil
	Local cPath   := cFluxo
	Local nX      := 0
	Local oJson   := Nil
	Local aJson   := {}
	Local nPos    := 0
	Local cResp   := ""
	Local oResp   := Nil
	Local cId     := ""
	Local nAtual  := 0
	Local cCodSZ1 := ""
	Local dDtIni   := SToD(StrTran(cDtComp, "-", ""))
	Local dDtAtual := dDtIni
	Local cDtAtual := SubStr(DToS(dDtAtual), 1, 6)
	Local cDtMax   := SubStr(DToS(Date()), 1, 6)

	oRest := FwRest():New(cUrlAPI)

	oRest:SetPath(cPath)

	While (cDtMax >= cDtAtual)
		nPags  := U_ASPags(2, dDtAtual)
		nAtual := 0

		If !(Empty(nPags))
			cCodSZ1 := GetSxeNum("SZ1", "Z1_CODIGO")

			cChave := U_ASChvIde(2, dDtAtual)
			aDados := U_ASDados(2, dDtAtual)

			For nI := 1 To nPags
				aJson := {}

				For nX := 1 to nQuebra
					nAtual++

					If (nAtual <= Len(aDados))
						aAdd(aJson, JsonObject():New())
						nPos := Len(aJson)

						aJson[nPos]['MES']             := aDados[nAtual][1]
						aJson[nPos]['ANO']             := aDados[nAtual][2]
						aJson[nPos]['DATA_VENCIMENTO'] := aDados[nAtual][3]
						aJson[nPos]['COD_UNIDADE']     := aDados[nAtual][4]
						aJson[nPos]['COD_DIMENSAO']    := aDados[nAtual][5]
						aJson[nPos]['COD_CONTA']       := aDados[nAtual][6]
						aJson[nPos]['DESC_CONTA']      := aDados[nAtual][7]
						aJson[nPos]['DOCUMENTO']       := aDados[nAtual][8]
						aJson[nPos]['NATUREZA']        := aDados[nAtual][9]
						aJson[nPos]['VALOR']           := aDados[nAtual][10]
						aJson[nPos]['HISTORICO']       := aDados[nAtual][11]
						aJson[nPos]['COD_PROJETO']     := aDados[nAtual][12]
						aJson[nPos]['DATA_LIQUIDACAO'] := aDados[nAtual][13]
						aJson[nPos]['GERADOR']         := aDados[nAtual][14]
					Else
						EXIT
					Endif
				Next

				cToken := U_ASToken()

				oJson                     := JsonObject():New()
				oJson['AUTH_TOKEN']       := cToken
				oJson['CHAVE_INTEGRACAO'] := cChave
				oJson['PAGINA']           := nI
				oJson['IMPORTACAO']       := aJson

				oRest:SetPostParams(EncodeUTF8(NoAcento(oJson:ToJson())))

				If (oRest:Post())
					cResp := EncodeUTF8(NoAcento(oRest:GetResult()))

					FWJsonDeserialize(cResp, @oResp)

					If (ValType(oResp:status) == "N")
						nStatus := oResp:status
					Elseif (ValType(oResp:status) == "C")
						nStatus := Val(oResp:status)
					Endif

					If (nStatus > 0)
						grvLog("FLUXO", "1",  EncodeUTF8(NoAcento(oJson:ToJson())), cResp, cCodSZ1)

						If (nStatus == 1)
							If (ValType(oResp:CEPP_ID) == "C")
								cId := oResp:CEPP_ID
							Endif
						Endif
					Else
						grvLog("FLUXO", "2",  EncodeUTF8(NoAcento(oJson:ToJson())), cResp, cCodSZ1)
					Endif
				Else
					cResp := EncodeUTF8(NoAcento(oRest:GetLastError()))
					grvLog("FLUXO", "2",  EncodeUTF8(NoAcento(oJson:ToJson())), cResp, cCodSZ1)
				Endif
			Next nI

			ConfirmSX8()
		Endif

		dDtAtual := LastDay(dDtAtual) + 1
		cDtAtual := SubStr(DToS(dDtAtual), 1, 6)
	Enddo

	FreeObj(oJson)
	FreeObj(oResp)
	FreeObj(oRest)
Return(cId)

/*/{Protheus.doc} ASBal
Endpoint Balanço
@type function
@author TOTVS
@since XX/XX/XXXX
/*/

User Function ASBal()
	Local nStatus := 0
	Local cToken  := ""
	Local nPags   := 0
	Local cChave  := ""
	Local aDados  := {}
	Local nI      := 0
	Local oRest   := Nil
	Local cPath   := cBalanco
	Local nX      := 0
	Local oJson   := Nil
	Local aJson   := {}
	Local nPos    := 0
	Local cResp   := ""
	Local oResp   := Nil
	Local cId     := ""
	Local nAtual  := 0
	Local cCodSZ1 := ""
	Local dDtIni   := SToD(StrTran(cDtComp, "-", ""))
	Local dDtAtual := dDtIni
	Local cDtAtual := SubStr(DToS(dDtAtual), 1, 6)
	Local cDtMax   := SubStr(DToS(Date()), 1, 6)

	oRest := FwRest():New(cUrlAPI)

	oRest:SetPath(cPath)

	While (cDtMax >= cDtAtual)
		nPags  := U_ASPags(3, dDtAtual)
		nAtual := 0

		If !(Empty(nPags))
			cCodSZ1 := GetSxeNum("SZ1", "Z1_CODIGO")

			cChave := U_ASChvIde(3, dDtAtual)
			aDados := U_ASDados(3, dDtAtual)

			For nI := 1 To nPags
				aJson := {}

				For nX := 1 to nQuebra
					nAtual++

					If (nAtual <= Len(aDados))
						aAdd(aJson, JsonObject():New())
						nPos := Len(aJson)

						aJson[nPos]['MES']          := aDados[nAtual][1]
						aJson[nPos]['ANO']          := aDados[nAtual][2]
						aJson[nPos]['COD_UNIDADE']  := aDados[nAtual][3]
						aJson[nPos]['COD_DIMENSAO'] := aDados[nAtual][4]
						aJson[nPos]['COD_CONTA']    := aDados[nAtual][5]
						aJson[nPos]['SALDO']        := aDados[nAtual][6]
					Else
						EXIT
					Endif
				Next

				cToken := U_ASToken()

				oJson                     := JsonObject():New()
				oJson['AUTH_TOKEN']       := cToken
				oJson['CHAVE_INTEGRACAO'] := cChave
				oJson['PAGINA']           := nI
				oJson['IMPORTACAO']       := aJson

				oRest:SetPostParams(EncodeUTF8(NoAcento(oJson:ToJson())))

				If (oRest:Post())
					cResp := EncodeUTF8(NoAcento(oRest:GetResult()))

					FWJsonDeserialize(cResp, @oResp)

					If (ValType(oResp:status) == "N")
						nStatus := oResp:status
					Elseif (ValType(oResp:status) == "C")
						nStatus := Val(oResp:status)
					Endif

					If (nStatus > 0)
						grvLog("BALANCO", "1",  EncodeUTF8(NoAcento(oJson:ToJson())), cResp, cCodSZ1)

						If (nStatus == 1)
							If (ValType(oResp:CEPP_ID) == "C")
								cId := oResp:CEPP_ID
							Endif
						Endif
					Else
						grvLog("BALANCO", "2",  EncodeUTF8(NoAcento(oJson:ToJson())), cResp, cCodSZ1)
					Endif
				Else
					cResp := EncodeUTF8(NoAcento(oRest:GetLastError()))
					grvLog("BALANCO", "2",  EncodeUTF8(NoAcento(oJson:ToJson())), cResp, cCodSZ1)
				Endif
			Next nI

			ConfirmSX8()
		Endif

		dDtAtual := LastDay(dDtAtual) + 1
		cDtAtual := SubStr(DToS(dDtAtual), 1, 6)
	Enddo

	FreeObj(oJson)
	FreeObj(oResp)
	FreeObj(oRest)
Return(cId)

/*/{Protheus.doc} ASDados
Retorna Dados que serão enviados via integração
@type function
@author TOTVS
@since XX/XX/XXXX
/*/

User Function ASDados(nOpc, dDtAtual)
	Local aDados  := {}
	Local cQuery  := ""
	Local cTab    := ""

	Default nOpc := 0

	cQuery := "SELECT *" + CRLF
	cQuery += "FROM (" + CRLF

	If (nOpc == 1)
		cQuery += qryDRE(dDtAtual)
	Elseif (nOpc == 2)
		cQuery += qryFluxo(dDtAtual)
	Elseif (nOpc == 3)
		cQuery += qryBal(dDtAtual)
	Endif
	cQuery += "	) A" + CRLF

	cQuery := ChangeQuery(cQuery)

	cTab := MPSysOpenQuery(cQuery)

	DbSelectArea((cTab))
	(cTab)->(DbGoTop())

	If (nOpc == 1)
		While ((cTab)->(!Eof()))
			aAdd(aDados, {(cTab)->MES, (cTab)->ANO, (cTab)->DATA, (cTab)->COD_UNIDADE, (cTab)->COD_CC, (cTab)->DESC_CC, (cTab)->COD_CONTA,(cTab)->DESC_CONTA, ;
				(cTab)->DOCUMENTO, (cTab)->NATUREZA, (cTab)->VALOR, (cTab)->HISTORICO, (cTab)->COD_PROJETO, (cTab)->GERADOR, (cTab)->COD_DIMENSAO, (cTab)->RATEIO})

			(cTab)->(DbSkip())
		Enddo
	Elseif (nOpc == 2)
		While ((cTab)->(!Eof()))
			aAdd(aDados, {(cTab)->MES, (cTab)->ANO, (cTab)->DATA_VENCIMENTO, (cTab)->COD_UNIDADE, (cTab)->COD_DIMENSAO, (cTab)->COD_CONTA, (cTab)->DESC_CONTA,;
				(cTab)->DOCUMENTO, (cTab)->NATUREZA, (cTab)->VALOR, (cTab)->HISTORICO, (cTab)->COD_PROJETO, (cTab)->DATA_LIQUIDACAO, (cTab)->GERADOR})

			(cTab)->(DbSkip())
		Enddo
	Elseif (nOpc == 3)
		While ((cTab)->(!Eof()))
			aAdd(aDados, {(cTab)->MES, (cTab)->ANO, (cTab)->COD_UNIDADE, (cTab)->COD_DIMENSAO, (cTab)->COD_CONTA, (cTab)->SALDO})

			(cTab)->(DbSkip())
		Enddo
	Endif

	(cTab)->(DbCloseArea())
Return(aDados)

/*/{Protheus.doc} qryDRE
Retorna Query do DRE
@type function
@author TOTVS
@since XX/XX/XXXX
/*/

Static Function qryDRE(dDtAtual)
	Local cQuery  := ""

	Default dDtAtual := dDataBase

	cQuery := "SELECT SUBSTRING(T0.CT2_DATA, 5, 2) MES" + CRLF
	cQuery += "	,SUBSTRING(T0.CT2_DATA, 1, 4) ANO" + CRLF
	cQuery += "	,SUBSTRING(T0.CT2_DATA, 7, 2) || SUBSTRING(T0.CT2_DATA, 5, 2) || SUBSTRING(T0.CT2_DATA, 1, 4) DATA" + CRLF
	cQuery += "	,'010' COD_UNIDADE" + CRLF
	cQuery += "	,T0.CT2_CCD COD_CC" + CRLF
	cQuery += "	,T1.CTT_DESC01 DESC_CC" + CRLF
	cQuery += "	,T0.CT2_DEBITO COD_CONTA" + CRLF
	cQuery += "	,T2.CT1_DESC01 DESC_CONTA" + CRLF
	cQuery += "	,TRIM(T0.CT2_DOC) || '/' || TRIM(T0.CT2_LOTE) || '/' || TRIM(T0.CT2_SBLOTE) DOCUMENTO" + CRLF
	cQuery += "	,'D' NATUREZA" + CRLF
	cQuery += "	,T0.CT2_VALOR VALOR" + CRLF
	cQuery += "	,T0.CT2_HIST HISTORICO" + CRLF
	cQuery += "	,'' COD_PROJETO" + CRLF
	cQuery += "	,'' GERADOR" + CRLF
	cQuery += "	,'' COD_DIMENSAO" + CRLF
	cQuery += "	,'N' RATEIO" + CRLF
	cQuery += "FROM " + RetSQLName("CT2") + " T0" + CRLF
	cQuery += "LEFT OUTER JOIN " + RetSQLName("CTT") + " T1 ON (" + CRLF
	cQuery += "		(T1.CTT_FILIAL = '" + xFilial("CTT") + "')" + CRLF
	cQuery += "		AND (T1.CTT_CUSTO = T0.CT2_CCD)" + CRLF
	cQuery += "		AND (T1.D_E_L_E_T_ = '')" + CRLF
	cQuery += "		)" + CRLF
	cQuery += "LEFT OUTER JOIN " + RetSQLName("CT1") + " T2 ON (" + CRLF
	cQuery += "		(T2.CT1_FILIAL = '" + xFilial("CT1") + "')" + CRLF
	cQuery += "		AND (T2.CT1_CONTA = T0.CT2_DEBITO)" + CRLF
	cQuery += "		AND (T2.D_E_L_E_T_ = '')" + CRLF
	cQuery += "		)" + CRLF
	cQuery += "WHERE T0.CT2_DATA BETWEEN '" + DToS(dDtAtual) + "' AND '" + DToS(LastDay(dDtAtual)) + "'" + CRLF
	cQuery += "	AND SUBSTRING(T0.CT2_DEBITO, 1, 1) >= '3'" + CRLF
	cQuery += "	AND T0.CT2_TPSALD = '1'" + CRLF
	cQuery += "	AND T0.D_E_L_E_T_ = ''" + CRLF
	cQuery += "" + CRLF
	cQuery += "UNION ALL" + CRLF
	cQuery += "" + CRLF
	cQuery += "SELECT SUBSTRING(T0.CT2_DATA, 5, 2) MES" + CRLF
	cQuery += "	,SUBSTRING(T0.CT2_DATA, 1, 4) ANO" + CRLF
	cQuery += "	,SUBSTRING(T0.CT2_DATA, 7, 2) || SUBSTRING(T0.CT2_DATA, 5, 2) || SUBSTRING(T0.CT2_DATA, 1, 4) DATA" + CRLF
	cQuery += "	,'010' COD_UNIDADE" + CRLF
	cQuery += "	,T0.CT2_CCC COD_CC" + CRLF
	cQuery += "	,T1.CTT_DESC01 DESC_CC" + CRLF
	cQuery += "	,T0.CT2_CREDIT COD_CONTA" + CRLF
	cQuery += "	,T2.CT1_DESC01 DESC_CONTA" + CRLF
	cQuery += "	,TRIM(T0.CT2_DOC) || '/' || TRIM(T0.CT2_LOTE) || '/' || TRIM(T0.CT2_SBLOTE) DOCUMENTO" + CRLF
	cQuery += "	,'C' NATUREZA" + CRLF
	cQuery += "	,T0.CT2_VALOR VALOR" + CRLF
	cQuery += "	,T0.CT2_HIST HISTORICO" + CRLF
	cQuery += "	,'' COD_PROJETO" + CRLF
	cQuery += "	,'' GERADOR" + CRLF
	cQuery += "	,'' COD_DIMENSAO" + CRLF
	cQuery += "	,'N' RATEIO" + CRLF
	cQuery += "FROM " + RetSQLName("CT2") + " T0" + CRLF
	cQuery += "LEFT OUTER JOIN " + RetSQLName("CTT") + " T1 ON (" + CRLF
	cQuery += "		(T1.CTT_FILIAL = '" + xFilial("CTT") + "')" + CRLF
	cQuery += "		AND (T1.CTT_CUSTO = T0.CT2_CCC)" + CRLF
	cQuery += "		AND (T1.D_E_L_E_T_ = '')" + CRLF
	cQuery += "		)" + CRLF
	cQuery += "LEFT OUTER JOIN " + RetSQLName("CT1") + " T2 ON (" + CRLF
	cQuery += "		(T2.CT1_FILIAL = '" + xFilial("CT1") + "')" + CRLF
	cQuery += "		AND (T2.CT1_CONTA = T0.CT2_CREDIT)" + CRLF
	cQuery += "		AND (T2.D_E_L_E_T_ = '')" + CRLF
	cQuery += "		)" + CRLF
	cQuery += "WHERE T0.CT2_DATA BETWEEN '" + DToS(dDtAtual) + "' AND '" + DToS(LastDay(dDtAtual)) + "'" + CRLF
	cQuery += "	AND SUBSTRING(T0.CT2_CREDIT, 1, 1) >= '3'" + CRLF
	cQuery += "	AND T0.CT2_TPSALD = '1'" + CRLF
	cQuery += "	AND T0.D_E_L_E_T_ = ''" + CRLF
Return(cQuery)

/*/{Protheus.doc} qryFluxo
Retorna Query do Fluxo de Caixa
@type function
@author TOTVS
@since XX/XX/XXXX
/*/

Static Function qryFluxo(dDtAtual)
	Local cQuery  := ""

	Default dDtAtual := dDataBase

	cQuery := "SELECT SUBSTRING(T1.E1_VENCREA, 5, 2) MES" + CRLF
	cQuery += "	,SUBSTRING(T1.E1_VENCREA, 1, 4) ANO" + CRLF
	cQuery += "	,SUBSTRING(T1.E1_VENCREA, 7, 2) || '/' || SUBSTRING(T1.E1_VENCREA, 5, 2) || '/' || SUBSTRING(T1.E1_VENCREA, 1, 4) DATA_VENCIMENTO" + CRLF
	cQuery += "	,'010' COD_UNIDADE" + CRLF
	cQuery += "	,'' COD_DIMENSAO" + CRLF
	cQuery += "	,T0.E5_NATUREZ COD_CONTA" + CRLF
	cQuery += "	,T2.ED_DESCRIC DESC_CONTA" + CRLF
	cQuery += "	,T0.E5_PREFIXO || '/' || T0.E5_NUMERO || '/' || T0.E5_PARCELA DOCUMENTO" + CRLF
	cQuery += "	,'C' NATUREZA" + CRLF
	cQuery += "	,T0.E5_VALOR VALOR" + CRLF
	cQuery += "	,T0.E5_HISTOR HISTORICO" + CRLF
	cQuery += "	,'' COD_PROJETO" + CRLF
	cQuery += "	,SUBSTRING(T0.E5_DTDIGIT, 7, 2) || '/' || SUBSTRING(T0.E5_DTDIGIT, 5, 2) || '/' || SUBSTRING(T0.E5_DTDIGIT, 1, 4) DATA_LIQUIDACAO" + CRLF
	cQuery += "	,T0.E5_CLIFOR || ' ' || T0.E5_LOJA || ' ' || T0.E5_BENEF GERADOR" + CRLF
	cQuery += "FROM " + RetSQLName("SE5") + " T0" + CRLF
	cQuery += "INNER JOIN " + RetSQLName("SE1") + " T1 ON (" + CRLF
	cQuery += "		(T1.E1_FILIAL = T0.E5_FILIAL)" + CRLF
	cQuery += "		AND (T1.E1_CLIENTE = T0.E5_CLIFOR)" + CRLF
	cQuery += "		AND (T1.E1_LOJA = T0.E5_LOJA)" + CRLF
	cQuery += "		AND (T1.E1_PREFIXO = T0.E5_PREFIXO)" + CRLF
	cQuery += "		AND (T1.E1_NUM = T0.E5_NUMERO)" + CRLF
	cQuery += "		AND (T1.E1_PARCELA = T0.E5_PARCELA)" + CRLF
	cQuery += "		AND (T1.E1_TIPO = T0.E5_TIPO)" + CRLF
	cQuery += "		AND (T1.D_E_L_E_T_ = '')" + CRLF
	cQuery += "		)" + CRLF
	cQuery += "LEFT OUTER JOIN " + RetSQLName("SED") + " T2 ON (" + CRLF
	cQuery += "		(T2.ED_FILIAL = T0.E5_FILIAL)" + CRLF
	cQuery += "		AND (T2.ED_CODIGO = T0.E5_NATUREZ)" + CRLF
	cQuery += "		AND (T2.D_E_L_E_T_ = '')" + CRLF
	cQuery += "		)" + CRLF
	cQuery += "WHERE T0.D_E_L_E_T_ = ''" + CRLF
	cQuery += "	AND T0.E5_DTDIGIT BETWEEN '" + DToS(dDtAtual) + "' AND '" + DToS(LastDay(dDtAtual)) + "'" + CRLF
	cQuery += "	AND T0.E5_VALOR > 0" + CRLF
	cQuery += "	AND T0.E5_RECPAG = 'R'" + CRLF
	cQuery += "	AND T0.E5_DTCANBX = ''" + CRLF
	cQuery += "	AND T0.E5_TIPODOC IN (" + CRLF
	cQuery += "		'PA'" + CRLF
	cQuery += "		,'VL'" + CRLF
	cQuery += "		,'RA'" + CRLF
	cQuery += "		)" + CRLF
	cQuery += "" + CRLF
	cQuery += "UNION ALL" + CRLF
	cQuery += "" + CRLF
	cQuery += "SELECT SUBSTRING(T1.E2_VENCREA, 5, 2) MES" + CRLF
	cQuery += "	,SUBSTRING(T1.E2_VENCREA, 1, 4) ANO" + CRLF
	cQuery += "	,SUBSTRING(T1.E2_VENCREA, 7, 2) || '/' || SUBSTRING(T1.E2_VENCREA, 5, 2) || '/' || SUBSTRING(T1.E2_VENCREA, 1, 4) DATA_VENCIMENTO" + CRLF
	cQuery += "	,'010' COD_UNIDADE" + CRLF
	cQuery += "	,'' COD_DIMENSAO" + CRLF
	cQuery += "	,T0.E5_NATUREZ COD_CONTA" + CRLF
	cQuery += "	,T2.ED_DESCRIC DESC_CONTA" + CRLF
	cQuery += "	,T0.E5_PREFIXO || '/' || T0.E5_NUMERO || '/' || T0.E5_PARCELA DOCUMENTO" + CRLF
	cQuery += "	,'D' NATUREZA" + CRLF
	cQuery += "	,T0.E5_VALOR VALOR" + CRLF
	cQuery += "	,T0.E5_HISTOR HISTORICO" + CRLF
	cQuery += "	,'' COD_PROJETO" + CRLF
	cQuery += "	,SUBSTRING(T0.E5_DTDIGIT, 7, 2) || '/' || SUBSTRING(T0.E5_DTDIGIT, 5, 2) || '/' || SUBSTRING(T0.E5_DTDIGIT, 1, 4) DATA_LIQUIDACAO" + CRLF
	cQuery += "	,T0.E5_CLIFOR || ' ' || T0.E5_LOJA || ' ' || T0.E5_BENEF GERADOR" + CRLF
	cQuery += "FROM " + RetSQLName("SE5") + " T0" + CRLF
	cQuery += "INNER JOIN " + RetSQLName("SE2") + " T1 ON (" + CRLF
	cQuery += "		(T1.E2_FILIAL = T0.E5_FILIAL)" + CRLF
	cQuery += "		AND (T1.E2_FORNECE = T0.E5_CLIFOR)" + CRLF
	cQuery += "		AND (T1.E2_LOJA = T0.E5_LOJA)" + CRLF
	cQuery += "		AND (T1.E2_PREFIXO = T0.E5_PREFIXO)" + CRLF
	cQuery += "		AND (T1.E2_NUM = T0.E5_NUMERO)" + CRLF
	cQuery += "		AND (T1.E2_PARCELA = T0.E5_PARCELA)" + CRLF
	cQuery += "		AND (T1.E2_TIPO = T0.E5_TIPO)" + CRLF
	cQuery += "		AND (T1.D_E_L_E_T_ = '')" + CRLF
	cQuery += "		)" + CRLF
	cQuery += "LEFT OUTER JOIN " + RetSQLName("SED") + " T2 ON (" + CRLF
	cQuery += "		(T2.ED_FILIAL = T0.E5_FILIAL)" + CRLF
	cQuery += "		AND (T2.ED_CODIGO = T0.E5_NATUREZ)" + CRLF
	cQuery += "		AND (T2.D_E_L_E_T_ = '')" + CRLF
	cQuery += "		)" + CRLF
	cQuery += "WHERE T0.D_E_L_E_T_ = ''" + CRLF
	cQuery += "	AND T0.E5_DTDIGIT BETWEEN '" + DToS(dDtAtual) + "' AND '" + DToS(LastDay(dDtAtual)) + "'" + CRLF
	cQuery += "	AND T0.E5_VALOR > 0" + CRLF
	cQuery += "	AND T0.E5_RECPAG = 'P'" + CRLF
	cQuery += "	AND T0.E5_DTCANBX = ''" + CRLF
	cQuery += "	AND T0.E5_TIPODOC IN (" + CRLF
	cQuery += "		'PA'" + CRLF
	cQuery += "		,'VL'" + CRLF
	cQuery += "		,'RA'" + CRLF
	cQuery += "		)" + CRLF
	cQuery += "" + CRLF
	cQuery += "UNION ALL" + CRLF
	cQuery += "" + CRLF
	cQuery += "SELECT SUBSTRING(T0.E5_DTDIGIT, 5, 2) MES" + CRLF
	cQuery += "	,SUBSTRING(T0.E5_DTDIGIT, 1, 4) ANO" + CRLF
	cQuery += "	,SUBSTRING(T0.E5_DTDIGIT, 7, 2) || '/' || SUBSTRING(T0.E5_DTDIGIT, 5, 2) || '/' || SUBSTRING(T0.E5_DTDIGIT, 1, 4) DATA_VENCIMENTO" + CRLF
	cQuery += "	,'010' COD_UNIDADE" + CRLF
	cQuery += "	,'' COD_DIMENSAO" + CRLF
	cQuery += "	,T0.E5_NATUREZ COD_CONTA" + CRLF
	cQuery += "	,T1.ED_DESCRIC DESC_CONTA" + CRLF
	cQuery += "	,T0.E5_PREFIXO || '/' || T0.E5_NUMERO || '/' || T0.E5_PARCELA DOCUMENTO" + CRLF
	cQuery += "	,CASE " + CRLF
	cQuery += "		WHEN T0.E5_RECPAG = 'R'" + CRLF
	cQuery += "			THEN 'C'" + CRLF
	cQuery += "		ELSE 'D'" + CRLF
	cQuery += "		END NATUREZA" + CRLF
	cQuery += "	,T0.E5_VALOR VALOR" + CRLF
	cQuery += "	,T0.E5_HISTOR HISTORICO" + CRLF
	cQuery += "	,'' COD_PROJETO" + CRLF
	cQuery += "	,SUBSTRING(T0.E5_DTDIGIT, 7, 2) || '/' || SUBSTRING(T0.E5_DTDIGIT, 5, 2) || '/' || SUBSTRING(T0.E5_DTDIGIT, 1, 4) DATA_LIQUIDACAO" + CRLF
	cQuery += "	,'' GERADOR" + CRLF
	cQuery += "FROM " + RetSQLName("SE5") + " T0" + CRLF
	cQuery += "LEFT OUTER JOIN " + RetSQLName("SED") + " T1 ON (" + CRLF
	cQuery += "		(T1.ED_FILIAL = T0.E5_FILIAL)" + CRLF
	cQuery += "		AND (T1.ED_CODIGO = T0.E5_NATUREZ)" + CRLF
	cQuery += "		AND (T1.D_E_L_E_T_ = '')" + CRLF
	cQuery += "		)" + CRLF
	cQuery += "WHERE T0.D_E_L_E_T_ = ''" + CRLF
	cQuery += "	AND T0.E5_DTDIGIT BETWEEN '" + DToS(dDtAtual) + "' AND '" + DToS(LastDay(dDtAtual)) + "'" + CRLF
	cQuery += "	AND T0.E5_VALOR > 0" + CRLF
	cQuery += "	AND T0.E5_DOCUMEN <> ''" + CRLF
	cQuery += "	AND T0.E5_DTCANBX = ''" + CRLF
	cQuery += "	AND T0.E5_ORIGEM = 'FINA100'" + CRLF
Return(cQuery)

/*/{Protheus.doc} qryBal
Retorna Query do Balanço
@type function
@author TOTVS
@since XX/XX/XXXX
/*/

Static Function qryBal(dDtAtual)
	Local cQuery  := ""

	Default dDtAtual := dDataBase

	cQuery := "SELECT SUBSTRING(T0.CQ0_DATA, 5, 2) MES" + CRLF
	cQuery += "	,SUBSTRING(T0.CQ0_DATA, 1, 4) ANO" + CRLF
	cQuery += "	,'010' COD_UNIDADE" + CRLF
	cQuery += "	,'' COD_DIMENSAO" + CRLF
	cQuery += "	,T0.CQ0_CONTA COD_CONTA" + CRLF
	cQuery += "	,SUM(T0.CQ0_CREDIT - T0.CQ0_DEBITO) SALDO" + CRLF
	cQuery += "FROM " + RetSQLName("CQ0") + " T0" + CRLF
	cQuery += "WHERE T0.D_E_L_E_T_ = ''" + CRLF
	cQuery += "	AND T0.CQ0_DATA BETWEEN '" + DToS(dDtAtual) + "' AND '" + DToS(LastDay(dDtAtual)) + "'" + CRLF
	cQuery += "	AND T0.CQ0_MOEDA = '01'" + CRLF
	cQuery += "	AND SUBSTRING(T0.CQ0_CONTA, 1, 1) IN (" + CRLF
	cQuery += "		'1'" + CRLF
	cQuery += "		,'2'" + CRLF
	cQuery += "		)" + CRLF
	cQuery += "GROUP BY T0.CQ0_DATA" + CRLF
	cQuery += "	,T0.CQ0_CONTA" + CRLF
Return(cQuery)

/*/{Protheus.doc} GrvLog
Gravação do Log
@type function
@author TOTVS
@since XX/XX/XXXX
/*/

Static Function grvLog(cInteg, cStatus, cEnvio, cRetorno, cCodSZ1)
	Local lRet := .T.

	Default cInteg   := ""
	Default cStatus  := ""
	Default cEnvio   := ""
	Default cRetorno := ""
	Default cCodSZ1  := ""

	RecLock("SZ1", .T.)
	SZ1->Z1_FILIAL  := xFilial("SZ1")
	SZ1->Z1_CODIGO  := cCodSZ1
	SZ1->Z1_DATA 	:= Date()
	SZ1->Z1_HORA 	:= GetRmtTime()
	SZ1->Z1_DESCRI 	:= cInteg
	SZ1->Z1_STATUS	:= cStatus
	SZ1->Z1_ENVIO	:= cEnvio
	SZ1->Z1_RETORNO	:= cRetorno
	SZ1->(MsUnlock())
Return(lRet)
