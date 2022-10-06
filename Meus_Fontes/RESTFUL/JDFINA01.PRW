#Include "Protheus.ch"
#Include "FWMVCDef.ch"


User Function JDFINA01() //
	Local oBrowseSZ1 := Nil

	oBrowseSZ1 := FwmBrowse():New()
	oBrowseSZ1:SetAlias("SZ1")
	oBrowseSZ1:SetDescription("LOGS") //
	oBrowseSZ1:Activate()

	oBrowse:AddLegend("Z1_STATUS == '1'", "BR_VERDE"  , "Importado")
	oBrowse:AddLegend("Z1_STATUS == '2'", "BR_VERMELHO", "Falha na Integração")

Return()

Static Function MenuDef()
	Local aRotina := {}
	Add Option aRotina Title OemToAnsi("Visualizar") Action "VIEWDEF.JDFINA01" Operation 2 Access 0
Return (aRotina)

Static Function ModelDef()
	Local oModel:= Nil
	Local oSZ1	:= Nil

	oSZ1 := FWFormStruct(1, "SZ1")

	oModel := MPFormModel():New("JDFINA01M", ,)
	oModel:AddFields("SZ1MASTER", , oSZ1)
	oModel:GetModel("SZ1MASTER"):SetDescription(OemToAnsi("LOGS")) //
Return (oModel)

Static Function ViewDef()
	Local oModel := Nil
	Local oView := Nil
	Local oSZ1 := Nil

	oModel := ModelDef()
	oSZ1 := FWFormStruct(2, "SZ1")

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("VIEW_SZ1", oSZ1, "SZ1MASTER")
	oView:CreateHorizontalBox( "TELA" , 100)
	oView:SetOwnerView( "VIEW_SZ1", "TELA" )

Return (oView)

/*	SZ1->Z1_FILIAL  := xFilial("SZ1")
	SZ1->Z1_CODIGO  := GetSxeNum("SZ1", "Z1_CODIGO") 
	SZ1->Z1_DATA 	:= Date() // função que retorna data Date()
	SZ1->Z1_HORA 	:= GetRmtTime() // função que retorna hora GetRmtTime()
	SZ1->Z1_DESCRI 	:= cInteg
	SZ1->Z1_STATUS	:= cStatus
	SZ1->Z1_ENVIO	:= cEnvio
	SZ1->Z1_RETORNO	:= cRetorno*/
