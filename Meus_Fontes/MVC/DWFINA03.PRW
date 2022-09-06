#Include "Protheus.ch"
#Include "FWMVCDef.ch"

/*/{Protheus.doc} DWFINA03
Rotina de Grupos de Aprovação.
@type function
@author Felipe Alves
@since 11/06/2021
/*/

User Function DWFINA03()
	Local oBrowse := Nil

	oBrowse := BrowseDef()
	oBrowse:Activate()
Return()

/*/{Protheus.doc} BrowseDef
Rotina de Grupos de Aprovação.
@type function
@author Felipe Alves
@since 11/06/2021
/*/

Static Function BrowseDef()
	Local oBrowse := Nil

	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription(OemToAnsi("Grupos de Aprovação"))
	oBrowse:SetAlias("SZ7")
Return(oBrowse)

/*/{Protheus.doc} MenuDef
Rotina de Grupos de Aprovação.
@type function
@author Felipe Alves
@since 11/06/2021
/*/

Static Function MenuDef()
	Local aRotina := {}

	Add Option aRotina Title OemToAnsi("Visualizar") Action "VIEWDEF.DWFINA03" Operation 2 Access 0
	Add Option aRotina Title OemToAnsi("Incluir")    Action "VIEWDEF.DWFINA03" Operation 3 Access 0
	Add Option aRotina Title OemToAnsi("Alterar")    Action "VIEWDEF.DWFINA03" Operation 4 Access 0
	Add Option aRotina Title OemToAnsi("Excluir")    Action "VIEWDEF.DWFINA03" Operation 5 Access 0
Return(aRotina)

/*/{Protheus.doc} ModelDef
Rotina de Grupos de Aprovação.
@type function
@author Felipe Alves
@since 11/06/2021
/*/

Static Function ModelDef()
	Local oModel := Nil
	Local oSZ7 := Nil
	Local oSZ8 := Nil

	oSZ7 := FWFormStruct(1, "SZ7")
	oSZ8 := FWFormStruct(1, "SZ8")

	oModel := MPFormModel():New("FINA03GRP", /*bPre*/, {|oModel| FINA03Ok(oModel)}/*bPost*/)

	{ | oModel | JOK01CTRM( oModel ) }

	oModel:AddFields("SZ7MASTER", , oSZ7)
	oModel:AddGrid("SZ8DETAIL", "SZ7MASTER", oSZ8)
	oModel:SetPrimaryKey({"Z7_FILIAL", "Z7_COD", "Z7_CCUSTO", "Z7_NATUREZ", "Z7_TIPO"})
	oModel:GetModel("SZ8DETAIL"):SetUniqueLine({"Z8_CODAPR"})
	oModel:SetRelation("SZ8DETAIL", {{"Z8_FILIAL", "xFilial('SZ7')"}, {"Z8_COD", "Z7_COD"}}, SZ8->(IndexKey(1)))
	oModel:SetDescription(OemToAnsi("Grupos de Aprovação"))
	oModel:GetModel("SZ7MASTER"):SetDescription(OemToAnsi("Grupos de Aprovação"))
	oModel:GetModel("SZ8DETAIL"):SetDescription(OemToAnsi("Aprovadores"))
Return(oModel)

/*/{Protheus.doc} ViewDef
Rotina de Grupos de Aprovação.
@type function
@author Felipe Alves
@since 11/06/2021
/*/

Static Function ViewDef()
	Local oModel := Nil
	Local oView := Nil
	Local oSZ7 := Nil
	Local oSZ8 := Nil

	oModel := ModelDef()
	oView := FWFormView():New()
	oSZ7 := FWFormStruct(2, "SZ7")
	oSZ8 := FWFormStruct(2, "SZ8", {|x| !(AllTrim(x) $ "Z8_FILIAL|Z8_COD|")})

	oView:SetModel(oModel)
	oView:AddField("FIELD_SZ7", oSZ7, "SZ7MASTER")
	oView:AddGrid("GRID_SZ8", oSZ8, "SZ8DETAIL")
	oView:CreateHorizontalBox("TELA01", 20)
	oView:CreateHorizontalBox("TELA02", 80)
	oView:SetOwnerView("FIELD_SZ7", "TELA01")
	oView:SetOwnerView("GRID_SZ8", "TELA02")
	oView:AddIncrementField("GRID_SZ8", "Z8_ITEM")
Return(oView)

/*/{Protheus.doc} FINA03Ok
Rotina de Grupos de Aprovação.
@type function
@author Felipe Alves
@since 11/06/2021
/*/

Static Function FINA03Ok(oModel)
	Local lRet := .T.
	Local oModelSZ7 := oModel:GetModel("SZ7MASTER")
	Local nOper := oModel:GetOperation()
	Local aArea := GetArea()
	Local aAreaSZ7 := SZ7->(GetArea())

	If (nOper == MODEL_OPERATION_INSERT)
		lRet := ExistChav("SZ7", oModelSZ7:GetValue("Z7_CCUSTO") + oModelSZ7:GetValue("Z7_NATUREZ") + oModelSZ7:GetValue("Z7_TIPO"), 3)
	Endif

	RestArea(aAreaSZ7)
	RestArea(aArea)
Return(lRet)
