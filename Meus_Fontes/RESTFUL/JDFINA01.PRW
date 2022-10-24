#Include "Protheus.ch"
#Include "FWMVCDef.ch"


User Function JDFINA01() //
	Local oBrowse := Nil
	
	oBrowse		:= BrowseDef()
	oBrowse:Activate()

Return()

Static Function BrowseDef()
	Local oBrowse := Nil

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("SZ1")
	oBrowse:SetDescription(OemToAnsi("Logs"))
	oBrowse:AddLegend("Z1_STATUS == '1'", "BR_VERDE"  , "Importado")
	oBrowse:AddLegend("Z1_STATUS == '2'", "BR_VERMELHO", "Falha na Integração")
	oBrowse:AddLegend("Z1_STATUS == '3'", "BR_AZUL"    , "Integrado")
	oBrowse:Activate()

Return (oBrowse)

Static Function MenuDef()
	Local aRotina := {}
		Add Option aRotina Title OemToAnsi("Visualizar")   Action "VIEWDEF.JDFINA01M" Operation 2 Access 0

Return aRotina

Static Function ModelDef()
	Local oModel := Nil
	Local oSZ1   := Nil

	oSZ1 := FWFormStruct(1, "SZ1")

	oModel := MPFormModel():New("JDFINA01M", /*bPre*/, /*bPost*/, )

	oModel:AddFields("SZ1MASTER",, oSZ1)
	oModel:SetPrimaryKey({"Z1_FILIAL", "Z1_BORDERO", "Z1_PREFIXO", "Z1_NUM", "Z1_PARCELA", "Z1_TIPO", "Z1_FORNECE", "Z1_LOJA"})
	oModel:SetDescription(OemToAnsi("Logs"))
Return (oModel)

Static Function ViewDef()
	Local oModel := Nil
	Local oView := Nil
	Local oSZ1 := Nil


	oModel := ModelDef()
	oView  := FWFormView():New()
	oSZ1   := FWFormStruct(2, "SZ1")

	oView:SetModel(oModel)
	oView:AddField("FIELD_SZ1", oSZ1, "SZ1MASTER")
	oView:CreateHorizontalBox("TELA01", 100)
	oView:SetOwnerView("FIELD_SZ1", "TELA01")
Return (oView)

/*	SZ1->Z1_FILIAL  := xFilial("SZ1")
	SZ1->Z1_CODIGO  := GetSxeNum("SZ1", "Z1_CODIGO") 
	SZ1->Z1_DATA 	:= Date() // função que retorna data Date()
	SZ1->Z1_HORA 	:= GetRmtTime() // função que retorna hora GetRmtTime()
	SZ1->Z1_DESCRI 	:= cInteg
	SZ1->Z1_STATUS	:= cStatus
	SZ1->Z1_ENVIO	:= cEnvio
	SZ1->Z1_RETORNO	:= cRetorno*/
