#Include "Protheus.ch"
#Include "FWMVCDef.ch"

Static nQuebra  := GetNewPar("MV_XQBRPAG", 100)
Static cUrlTOK  := GetNewPar("MV_XASTOK", "https://auth.planoparasuaempresa.com.br")
Static cUrlAPI  := GetNewPar("MV_XASAPI", "https://api.planoparasuaempresa.com.br")
Static cUser    := GetNewPar("MV_XTOKUSR", "integrador.1023@allstrategy.com.br")
Static cPass    := GetNewPar("MV_XTOKPAS", "3jcZ5SgW")
Static cDtComp  := GetNewPar("MV_XDTCOMP", "2022-01-01")
Static cDRE     := GetNewPar("MV_XASDRE" , "/realizado/v2/dre")
Static cFluxo   := GetNewPar("MV_XASFLX" , "/realizado/v2/fluxodecaixa")
Static cBalanco := GetNewPar("MV_XASBAL" , "/realizado/v2/balanco")

/*/{Protheus.doc} JDFINA01
Tela de Logs
@type function
@author TOTVS
@since XX/XX/XXXX
/*/

User Function JDFINA01()
	Local oBrowse := Nil

	oBrowse	:= BrowseDef()
	oBrowse:Activate()
Return()

/*/{Protheus.doc} BrowseDef
Tela de Logs
@type function
@author TOTVS
@since XX/XX/XXXX
/*/

Static Function BrowseDef()
	Local oBrowse := Nil

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("SZ1")
	oBrowse:SetDescription(OemToAnsi("Logs"))
	oBrowse:AddLegend("Z1_STATUS == '1'", "BR_VERDE"  , "Integrado")
	oBrowse:AddLegend("Z1_STATUS == '2'", "BR_VERMELHO", "Falha na Integração")
Return (oBrowse)

/*/{Protheus.doc} MenuDef
Tela de Logs
@type function
@author TOTVS
@since XX/XX/XXXX
/*/

Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina Title 'Visualizar'    Action 'VIEWDEF.JDFINA01' OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title 'Proc. Manual'  Action 'U_FINA01Prc()' OPERATION 3 ACCESS 0
	ADD OPTION aRotina Title 'Reproc. Erros' Action 'U_FINA01Rep()' OPERATION 3 ACCESS 0
Return aRotina

/*/{Protheus.doc} ModelDef
Tela de Logs
@type function
@author TOTVS
@since XX/XX/XXXX
/*/

Static Function ModelDef()
	Local oModel := Nil
	Local oSZ1   := Nil

	oSZ1   := FWFormStruct(1, "SZ1")
	oModel := MPFormModel():New("FINA01LOG")
	oModel:AddFields("SZ1MASTER",, oSZ1)
	oModel:SetPrimaryKey({"Z1_FILIAL", "Z1_CODIGO"})
	oModel:SetDescription(OemToAnsi("Logs"))
Return (oModel)

/*/{Protheus.doc} ViewDef
Tela de Logs
@type function
@author TOTVS
@since XX/XX/XXXX
/*/

Static Function ViewDef()
	Local oModel := Nil
	Local oView := Nil
	Local oSZ1 := Nil

	oModel := ModelDef()
	oView  := FWFormView():New()

	oSZ1 := FWFormStruct(2, "SZ1")

	oView:SetModel(oModel)
	oView:AddField("FIELD_SZ1", oSZ1, "SZ1MASTER")
	oView:CreateHorizontalBox("TELA01", 100)
	oView:SetOwnerView("FIELD_SZ1", "TELA01")
Return (oView)

/*/{Protheus.doc} FINA01Prc
Processamento Manual
@type function
@author TOTVS
@since XX/XX/XXXX
/*/

User Function FINA01Prc()
	Local lRet := .T.

	Processa({|| U_ASDRE()}, "Aguarde..", "Processando DRE..", .T.)
	Processa({|| U_ASFluxo()}, "Aguarde..", "Processando Fluxo de Caixa..", .T.)
	Processa({|| U_ASBal()}, "Aguarde..", "Processando Balanço..", .T.)
Return(lRet)

/*/{Protheus.doc} FINA01Rep
Reprocessamento dos Erros
@type function
@author TOTVS
@since XX/XX/XXXX
/*/

User Function FINA01Rep()
	Local lRet 		:= .T.
	Local nRECNO 	:= 0
	Local cQuery 	:= ""
	Local cTab 		:= ""
	Local cPath		:= ""
	Local cToken  	:= U_ASToken()
	Local oJson    	:= Nil
	Local oResp 	:= Nil
	Local oRest 	:= Nil

	cQuery := "SELECT Z1_DESCRI "+ CRLF
	cQuery += ",Z1_STATUS " + CRLF
	cQuery += ",R_E_C_N_O_ FROM " + RetSQLName("SZ1") + "" + CRLF
	cQuery += "WHERE Z1_STATUS = '2' " + CRLF

	cTab := MPSysOpenQuery(cQuery)
	DbSelectArea((cTab))
	(cTab)->(DbGoTop())

	While ((cTab)->(!Eof()))
		If (ALLTRIM(SZ1->Z1_DESCRI) == 'DRE') // false -> debugar e ver oq tem no SZ1->Z1_DESCRI
			cPath   := cDRE
		Elseif (ALLTRIM(SZ1->Z1_DESCRI) == 'FLUXO') // false
			cPath   := cFluxo
		Elseif (ALLTRIM(SZ1->Z1_DESCRI) == 'BALANCO') // false
			cPath   := cBalanco
		Endif

		nRECNO := (cTab)->R_E_C_N_O_
		DbSelectArea("SZ1")
		SZ1->(DbGoto(nRECNO))

		oRest := FwRest():New(cUrlAPI)
		oRest:SetPath(cPath)
		oJson := JsonObject():new()
		oJson:FromJson(SZ1->Z1_ENVIO)
		cToken := U_ASToken()

		oJson                     := JsonObject():New()
		oJson['AUTH_TOKEN']       := cToken
		oRest:SetPostParams(EncodeUTF8(NoAcento(oJson:ToJson())))

		If (oRest:Post())
			cResp := EncodeUTF8(NoAcento(oRest:GetResult()))
			FWJsonDeserialize(cResp, @oResp)

			If (ValType(oResp:status) == "N")
				nStatus := oResp:status
			Elseif (ValType(oResp:status) == "C")
				nStatus := Val(oResp:status)
			Endif

			If (nStatus > 0) // ->1,2,3
				RecLock("SZ1", .F.)
				SZ1->Z1_STATUS := "1" 
				SZ1->Z1_RETORNO := cResp 
				SZ1->(MsUnlock())

				If (nStatus == 1)
					If (ValType(oResp:CEPP_ID) == "C")
						cId := oResp:CEPP_ID
					Endif
				Endif
			Else
				RecLock("SZ1", .F.)
				SZ1->Z1_RETORNO := cResp
				SZ1->(MsUnlock())
			Endif
		Else
			cResp := EncodeUTF8(NoAcento(oRest:GetLastError()))
			RecLock("SZ1", .F.)
			SZ1->Z1_RETORNO := cResp
			SZ1->(MsUnlock())
		Endif
		(cTab)->(DbSkip())
	Enddo

	FreeObj(oJson)
	FreeObj(oResp)
	FreeObj(oRest)

Return(lRet)

