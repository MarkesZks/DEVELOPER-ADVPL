#Include "Protheus.ch"
#Include "FWMVCDef.ch"

/*/{Protheus.doc} MVCOMA01
Rotina de Grupos de Aprovação.
@type function
@author Felipe Alves
@since 11/06/2021
/*/

User Function MVCOMA01()
	Local oBrowse := Nil

	oBrowse := BrowseDef()
	oBrowse:Activate()
Return()

Static Function BrowseDef()
	Local oBrowse := Nil

	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription(OemToAnsi("Grupos de Aprovação"))
	oBrowse:SetAlias("SZ1")
Return(oBrowse)



Static Function MenuDef()
	Local aRotina := {}

	Add Option aRotina Title OemToAnsi("Visualizar") Action "VIEWDEF.MVCOMA01" Operation 2 Access 0
	Add Option aRotina Title OemToAnsi("Incluir")    Action "VIEWDEF.MVCOMA01" Operation 3 Access 0
	Add Option aRotina Title OemToAnsi("Alterar")    Action "VIEWDEF.MVCOMA01" Operation 4 Access 0
	Add Option aRotina Title OemToAnsi("Excluir")    Action "VIEWDEF.MVCOMA01" Operation 5 Access 0
Return(aRotina)


Static Function ModelDef()
	Local oModel := Nil
	Local oSZ1 := Nil
	Local oSZ2 := Nil

	oSZ1 := FWFormStruct(1, "SZ7")
	oSZ2 := FWFormStruct(1, "SZ8")

	oModel := MPFormModel():New("FINA03GRP", /*bPre*/, {|oModel| FINA03Ok(oModel)}/*bPost*/)

	{ | oModel | JOK01CTRM( oModel ) }

	oModel:AddFields("SZ7MASTER", , oSZ1)
	oModel:AddGrid("SZ8DETAIL", "SZ7MASTER", oSZ2)
	oModel:SetPrimaryKey({"Z7_FILIAL", "Z7_COD", "Z7_CCUSTO", "Z7_NATUREZ", "Z7_TIPO"})
	oModel:GetModel("SZ8DETAIL"):SetUniqueLine({"Z8_CODAPR"})
	oModel:SetRelation("SZ8DETAIL", {{"Z8_FILIAL", "xFilial('SZ7')"}, {"Z8_COD", "Z7_COD"}}, oSZ8->(IndexKey(1)))
	oModel:SetDescription(OemToAnsi("Grupos de Aprovação"))
	oModel:GetModel("SZ7MASTER"):SetDescription(OemToAnsi("Grupos de Aprovação"))
	oModel:GetModel("SZ8DETAIL"):SetDescription(OemToAnsi("Aprovadores"))
Return(oModel)



Static Function ViewDef()
	Local oModel := Nil
	Local oView := Nil
	Local oSZ1 := Nil
	Local oSZ2 := Nil

	oModel := ModelDef()
	oView := FWFormView():New()
	oSZ1 := FWFormStruct(2, "SZ1")
	oSZ2 := FWFormStruct(2, "SZ2", {|x| !(AllTrim(x) $ "Z8_FILIAL|Z8_COD|")})

	oView:SetModel(oModel)
	oView:AddField("FIELD_SZ7", oSZ1, "SZ7MASTER")
	oView:AddGrid("GRID_SZ8", oSZ2, "SZ8DETAIL")
	oView:CreateHorizontalBox("TELA01", 20)
	oView:CreateHorizontalBox("TELA02", 80)
	oView:SetOwnerView("FIELD_SZ7", "TELA01")
	oView:SetOwnerView("GRID_SZ8", "TELA02")
	oView:AddIncrementField("GRID_SZ8", "Z8_ITEM")
Return(oView)



Static Function FINA03Ok(oModel)
	Local lRet := .T.
	Local oModelSZ7 := oModel:GetModel("SZ7MASTER")
	Local nOper := oModel:GetOperation()
	Local aArea := GetArea()
	Local aAreaSZ7 := oSZ7->(GetArea())

	If (nOper == MODEL_OPERATION_INSERT)
		lRet := ExistChav("SZ1", oModelSZ7:GetValue("Z7_CCUSTO") + oModelSZ7:GetValue("Z7_NATUREZ") + oModelSZ7:GetValue("Z7_TIPO"), 3)
	Endif

	RestArea(aAreaSZ7)
	RestArea(aArea)
Return(lRet)

